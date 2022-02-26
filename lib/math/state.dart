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

  DerivationLine get line => _state._derivation[_index];

  @override
  String toString() => 'ProofLine($line)';
}

class DoubleTildePrinter extends _InteractiveTextPrinter {
  final FullState state;

  final Proof proof;

  DoubleTildePrinter(this.state, this.proof);

  @override
  void dispatchDerivationLine(
      DerivationLine node, DerivationLineContext context) {
    flush();
    if (node is Formula) {
      result.add(_SelectableText(middleDot, select: () {
        state._finishRule(
            doubleTildeRule, [proof.introduceDoubleTilde(context)()]);
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
        state
            ._finishRule(doubleTildeRule, [proof.removeDoubleTilde(context)()]);
      }));
      dispatchDerivationLine(operand.operand, context.operand.operand);
    } else {
      super.visitNot(node, context);
    }
  }

  static List<InteractiveText> run(
      FullState state, Proof proof, DerivationLine line) {
    var printer = DoubleTildePrinter(state, proof);
    printer.dispatchDerivationLine(line, DerivationLineContext(line));
    printer.flush();
    return printer.result;
  }
}

class FullState {
  InteractiveState _interactiveState = _Quiescent();

  final List<DerivationLine> _derivation = [];

  FullState() {
    _interactiveState = _Quiescent();
  }

  List<DerivationLineInfo> get derivationLines => [
        for (int i = 0; i < _derivation.length; i++)
          DerivationLineInfo._(this, i)
      ];

  bool get isSelectionNeeded => _interactiveState.isSelectionNeeded;

  String get message => _interactiveState.message;

  String? get previewLine => _interactiveState.previewLine;

  void activateRule(Rule rule) {
    try {
      _interactiveState = rule.activate(this, _derivation);
    } on UnimplementedError catch (e) {
      _interactiveState = _Quiescent(message: 'Unimplemented: ${e.message}');
    }
  }

  void addDerivationLine(DerivationLine line) {
    _derivation.add(line);
    _interactiveState = _Quiescent();
  }

  void _finishRule(Rule rule, List<DerivationLine> lines) {
    _derivation.addAll(lines);
    _interactiveState = _Quiescent(message: 'Applied rule "$rule"');
  }
}

abstract class InteractiveState {
  InteractiveState._();

  bool get isSelectionNeeded;

  String get message;

  String? get previewLine => null;

  List<InteractiveText> decorateLine(
      FullState state, DerivationLine line, int index);
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

  final List<FullLineStepRegionInfo?> regions;

  final List<int> selectedLines = [];

  SelectTwoLines(this.regions, this.rule) : super._();

  @override
  bool get isSelectionNeeded => true;

  @override
  String get message => 'Select 2 lines for $rule';

  @override
  String get previewLine =>
      rule.preview([for (var index in selectedLines) regions[index]!]);

  List<InteractiveText> decorateLine(
      FullState state, DerivationLine line, int index) {
    var text = line.toString();
    return [
      regions[index] != null
          ? _SelectableText(text,
              select: () {
                selectedLines.add(index);
                if (selectedLines.length == 2) {
                  var selectedLinesList = selectedLines.toList();
                  state._finishRule(
                      rule,
                      rule.apply(regions[selectedLinesList[0]]!,
                          regions[selectedLinesList[1]]!));
                }
              },
              isSelected: () => selectedLines.contains(index))
          : _SimpleText(text)
    ];
  }
}

class _InteractiveTextPrinter extends PrettyPrinterBase {
  final List<InteractiveText> result = [];

  StringBuffer? _accumulator;

  void flush() {
    var accumulator = _accumulator;
    if (accumulator != null) {
      result.add(_SimpleText(accumulator.toString()));
      _accumulator = null;
    }
  }

  @override
  void write(String text) {
    (_accumulator ??= StringBuffer()).write(text);
  }
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

class _SimpleText extends InteractiveText {
  _SimpleText(String text) : super(text);

  @override
  bool get isSelectable => false;

  @override
  bool get isSelected => false;

  @override
  void select() {
    assert(false, 'Not selectable');
  }

  String toString() => '_SimpleText(${json.encode(text)})';
}
