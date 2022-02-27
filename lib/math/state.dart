import 'dart:convert';

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

  DerivationLineInfo._(this._state, this._index);

  List<InteractiveText> get decorated =>
      _state._interactiveState.decorateLine(_state, line, _index);

  DerivationLine get line => _state._derivation.lines[_index];

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
      result.add(_SelectableText(star, select: () {
        derivation.introduceDoubleTilde(context);
        state._finishRule(doubleTildeRule);
      }));
    }
    super.dispatchDerivationLine(node, context);
  }

  @override
  void visitNot(Not node, DerivationLineContext context) {
    var operand = node.operand;
    if (operand is Not) {
      flush();
      result.add(_SelectableText('~~', select: () {
        derivation.removeDoubleTilde(context);
        state._finishRule(doubleTildeRule);
      }));
      dispatchDerivationLine(operand.operand, context.operand.operand);
    } else {
      super.visitNot(node, context);
    }
  }
}

class FullState {
  InteractiveState _interactiveState = _Quiescent();
  List<String> rulesImplemented = [];

  final _derivation = DerivationState();

  FullState() {
    _interactiveState = _Quiescent();
  }

  List<DerivationLineInfo> get derivationLines => [
        for (int i = 0; i < _derivation.lines.length; i++)
          DerivationLineInfo._(this, i)
      ];

  bool get isSelectionNeeded => _interactiveState.isSelectionNeeded;

  String get message => _interactiveState.message;

  String? get previewLine => _interactiveState.previewLine(_derivation.lines);

  void activateRule(Rule rule) {
    try {
      _interactiveState = rule.activate(this, _derivation);
    } on UnimplementedError catch (e) {
      _interactiveState = _Quiescent(message: 'Unimplemented: ${e.message}');
    }
  }

  void addDerivationLine(DerivationLine line) {
    _derivation.addLine(line);
    _interactiveState = _Quiescent();
  }

  void _finishRule(Rule rule) {
    rulesImplemented.add('Applied rule "$rule"');
    _interactiveState = _Quiescent(message: 'Applied rule "$rule"');
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

class SelectTwoLines extends InteractiveState {
  final FullLineStepRule rule;

  final List<bool> isSelectable;

  final List<int> selectedLines = [];

  SelectTwoLines(this.isSelectable, this.rule) : super._();

  @override
  bool get isSelectionNeeded => true;

  @override
  String get message => 'Select 2 lines for $rule';

  List<InteractiveText> decorateLine(
      FullState state, DerivationLine line, int index) {
    var text = line.toString();
    return [
      isSelectable[index]
          ? _SelectableText(text,
              select: () {
                selectedLines.add(index);
                if (selectedLines.length == 2) {
                  var selectedLinesList = selectedLines.toList();
                  rule.apply(
                      state._derivation,
                      state._derivation.lines[selectedLinesList[0]] as Formula,
                      state._derivation.lines[selectedLinesList[1]] as Formula);
                  state._finishRule(rule);
                }
              },
              isSelected: () => selectedLines.contains(index))
          : _SimpleText(text)
    ];
  }

  @override
  String previewLine(List<DerivationLine> derivation) => rule
      .preview([for (var index in selectedLines) derivation[index] as Formula]);
}

class SeparationPrinter extends _SelectionPrinter {
  SeparationPrinter(FullState state, DerivationState derivation)
      : super(state, derivation);

  @override
  void dispatchDerivationLine(
      DerivationLine node, DerivationLineContext context) {
    if (context.depth == 1 && context.top is And) {
      withDecorator(
          (text) => _SelectableText(text, select: () {
                derivation.addLine(node);
                state._finishRule(separationRule);
              }),
          () => super.dispatchDerivationLine(node, context));
    } else {
      super.dispatchDerivationLine(node, context);
    }
  }
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

  static InteractiveText _defaultDecorator(String text) => _SimpleText(text);
}

class _Quiescent extends InteractiveState {
  @override
  final String message;

  _Quiescent({this.message = ''}) : super._();

  @override
  bool get isSelectionNeeded => false;

  List<InteractiveText> decorateLine(
      FullState state, DerivationLine line, int index) {
    var text = line.toString();
    return [_SimpleText(text)];
  }
}

class _SelectableText extends InteractiveText {
  final bool Function() _isSelected;

  final void Function() _select;

  _SelectableText(String text,
      {bool Function() isSelected = _alwaysFalse,
      required void Function() select})
      : _isSelected = isSelected,
        _select = select,
        super(text);

  @override
  bool get isSelectable => true;

  @override
  bool get isSelected => _isSelected();

  void select() {
    _select();
  }

  static bool _alwaysFalse() => false;
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

class _SimpleText extends InteractiveText {
  _SimpleText(String text) : super(text);

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
