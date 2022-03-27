import 'dart:convert';

import 'package:geb/math/challenges.dart';
import 'package:geb/math/rule_definitions.dart';

import 'ast.dart';
import 'context.dart';
import 'pretty_print.dart';
import 'proof.dart';
import 'rules.dart';
import 'symbols.dart';

class DerivationLineInfo {
  final FullState _state;

  final int _index;

  final int indentation;

  DerivationLineInfo._(this._state, this._index, this.indentation);

  List<InteractiveText> get decorated =>
      _state._interactiveState.decorateLine(_state, line, _index);

  DerivationLine get line => _state._derivation.getLine(_index);

  @override
  String toString() => 'ProofLine($line)';
}

class DoubleTildePrinter extends _SelectionPrinter {
  DoubleTildePrinter(FullState state, DerivationState derivation)
      : super(state, derivation);

  @override
  void dispatchDerivationLine(
      DerivationLine node, DerivationLineContext context) {
    if (node is Formula) {
      flush();
      result.add(SelectableText(star, select: () {
        derivation.introduceDoubleTilde(context);
        state.finishRule(doubleTildeRule);
      }));
    }
    super.dispatchDerivationLine(node, context);
  }

  @override
  void visitNot(Not node, DerivationLineContext context) {
    var operand = node.operand;
    if (operand is Not) {
      flush();
      result.add(SelectableText('~~', select: () {
        derivation.removeDoubleTilde(context);
        state.finishRule(doubleTildeRule);
      }));
      dispatchDerivationLine(operand.operand, context.operand.operand);
    } else {
      super.visitNot(node, context);
    }
  }
}

class FullState {
  InteractiveState _interactiveState = Quiescent();

  final _derivation = DerivationState();

  Challenge? _challenge;

  final bool permissive;

  void Function()? onGoalSatisfied;

  FullState({this.permissive = true}) {
    _interactiveState = Quiescent();
    _derivation.onTheorem = (x) {
      if (isGoalSatisfied) {
        onGoalSatisfied?.call();
      }
    };
  }

  Challenge? get challenge => _challenge;

  set challenge(Challenge? challenge) {
    _derivation.clear();
    if (challenge != null) {
      _derivation.setupChallenge(challenge);
    }
    _challenge = challenge;
    _interactiveState = Quiescent();
  }

  List<DerivationLineInfo> get derivationLines {
    List<DerivationLineInfo> result = [];
    int indentation = 0;
    for (int i = 0; i < _derivation.lines.length; i++) {
      var line = _derivation.lines[i];
      if (line is PopFantasy && i > 0) {
        i--;
      }
      result.add(DerivationLineInfo._(this, i, indentation));
      if (line is PushFantasy) {
        i++;
      }
    }
    return result;
  }

  List<String> get explanations => _derivation.explanations;

  bool get isGoalSatisfied {
    var challenge = _challenge;
    return challenge != null && _derivation.isGoalSatisfied(challenge.goal);
  }

  bool get isPremiseExpected =>
      (permissive && _challenge == null) || _derivation.isPremiseExpected;

  bool get isSelectionNeeded => _interactiveState.isSelectionNeeded;

  String get message => _interactiveState.message;

  String? get previewLine => _interactiveState.previewLine(_derivation.lines);

  void activateRule(Rule rule) {
    if (_derivation.lines.isNotEmpty &&
        _derivation.lines.last is PushFantasy &&
        rule is! PopFantasyRule) {
      _derivation.undo(minLines: _challenge?.initialLines.length ?? 0);
    }
    try {
      _interactiveState = rule.activate(this, _derivation);
    } on UnimplementedError catch (e) {
      _interactiveState = Quiescent(message: 'Unimplemented: ${e.message}');
    }
  }

  void addDerivationLine(DerivationLine line) {
    _derivation.addLine(line);
    _interactiveState = Quiescent();
  }

  void finishRule(Rule rule) {
    _interactiveState = Quiescent(message: 'Applied rule "$rule".');
  }

  void undo() {
    if (_interactiveState is Quiescent) {
      _interactiveState = Quiescent(
          message:
              _derivation.undo(minLines: _challenge?.initialLines.length ?? 0));
    } else {
      _interactiveState = Quiescent();
    }
  }
}

abstract class InteractiveState {
  InteractiveState._();

  bool get isSelectionNeeded;

  String get message;

  List<InteractiveText> decorateLine(
      FullState state, DerivationLine line, int index);

  String? previewLine(List<DerivationLine> derivation) => null;
}

abstract class InteractiveText {
  final String text;

  InteractiveText(this.text);

  bool get isSelectable;

  bool get isSelected;

  void select();
}

class Quiescent extends InteractiveState {
  @override
  final String message;

  Quiescent({this.message = ''}) : super._();

  @override
  bool get isSelectionNeeded => false;

  List<InteractiveText> decorateLine(
      FullState state, DerivationLine line, int index) {
    var text = line.toString();
    return [SimpleText(text)];
  }
}

class SelectableText extends InteractiveText {
  final bool Function() _isSelectable;

  final bool Function() _isSelected;

  final void Function() _select;

  SelectableText(String text,
      {bool Function() isSelectable = _alwaysTrue,
      bool Function() isSelected = _alwaysFalse,
      required void Function() select})
      : _isSelectable = isSelectable,
        _isSelected = isSelected,
        _select = select,
        super(text);

  @override
  bool get isSelectable => _isSelectable();

  @override
  bool get isSelected => _isSelected();

  void select() {
    if (isSelectable) {
      _select();
    }
  }

  static bool _alwaysFalse() => false;

  static bool _alwaysTrue() => true;
}

class SelectLines extends InteractiveState {
  final FullLineStepRule rule;

  final bool Function(int, List<int>) isSelectable;

  final List<int> selectedLines = [];

  final int count;

  SelectLines(this.isSelectable, this.rule, {required this.count}) : super._();

  @override
  bool get isSelectionNeeded => true;

  @override
  String get message => 'Select $count line${count == 1 ? '' : 's'} for $rule';

  List<InteractiveText> decorateLine(
      FullState state, DerivationLine line, int index) {
    var text = line.toString();
    return [
      SelectableText(text,
          select: () {
            selectedLines.add(index);
            if (selectedLines.length >= count) {
              var selectedLinesList = selectedLines.toList();
              var lines = state._derivation.lines;
              rule.apply(state._derivation, [
                for (var index in selectedLinesList) lines[index] as Formula
              ]);
              state.finishRule(rule);
            }
          },
          isSelectable: () => isSelectable(index, selectedLines),
          isSelected: () => selectedLines.contains(index))
    ];
  }

  @override
  String previewLine(List<DerivationLine> derivation) => rule
      .preview([for (var index in selectedLines) derivation[index] as Formula]);
}

class SelectRegion extends InteractiveState {
  final Rule _rule;

  final List<List<InteractiveText>> _interactiveLines;

  SelectRegion(this._rule, this._interactiveLines) : super._();

  @override
  bool get isSelectionNeeded => true;

  @override
  String get message => 'Select a region for $_rule';

  @override
  List<InteractiveText> decorateLine(
          FullState state, DerivationLine line, int index) =>
      _interactiveLines[index];
}

class SeparationPrinter extends _SelectionPrinter {
  SeparationPrinter(FullState state, DerivationState derivation)
      : super(state, derivation);

  @override
  void dispatchDerivationLine(
      DerivationLine node, DerivationLineContext context) {
    if (context.depth == 1 && context.top is And) {
      withDecorator(
          (text) => SelectableText(text, select: () {
                derivation.addLine(node,
                    explanation: 'Applied rule "$separationRule"');
                state.finishRule(separationRule);
              }),
          () => super.dispatchDerivationLine(node, context));
    } else {
      super.dispatchDerivationLine(node, context);
    }
  }
}

class SimpleText extends InteractiveText {
  SimpleText(String text) : super(text);

  @override
  bool get isSelectable => false;

  @override
  bool get isSelected => false;

  @override
  void select() {
    assert(false, 'Not selectable: $this');
  }

  String toString() => '_SimpleText(${json.encode(text)})';
}

class _InteractiveTextPrinter extends PrettyPrinterBase {
  final List<InteractiveText> result = [];

  InteractiveText Function(String) _decorator = _defaultDecorator;

  StringBuffer? _accumulator;

  void flush() {
    var accumulator = _accumulator;
    if (accumulator != null) {
      result.add(_decorator(accumulator.toString()));
      _accumulator = null;
    }
  }

  T withDecorator<T>(
      InteractiveText Function(String) decorator, T Function() callback) {
    flush();
    var previousDecorator = _decorator;
    _decorator = decorator;
    var result = callback();
    flush();
    _decorator = previousDecorator;
    return result;
  }

  @override
  void write(String text) {
    (_accumulator ??= StringBuffer()).write(text);
  }

  static InteractiveText _defaultDecorator(String text) => SimpleText(text);
}

class _SelectionPrinter extends _InteractiveTextPrinter {
  final FullState state;

  final DerivationState derivation;

  _SelectionPrinter(this.state, this.derivation);

  List<InteractiveText> run(DerivationLine line) {
    dispatchDerivationLine(line, DerivationLineContext(line));
    flush();
    return result;
  }
}
