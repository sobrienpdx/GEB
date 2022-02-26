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

  List<InteractiveText> get decorated {
    var text = line.toString();
    return [
      _isSelectable ? _SelectableText(text, select: _select) : _SimpleText(text)
    ];
  }

  DerivationLine get line => _state._derivation[_index];

  bool get _isSelectable => _state._interactiveState.isLineSelectable(_index);

  bool get _isSelected => _state._interactiveState.isLineSelected(_index);

  @override
  String toString() {
    var parts = [
      line,
      if (_isSelectable) 'selectable',
      if (_isSelected) 'selected'
    ];
    return 'ProofLine(${parts.join(', ')})';
  }

  void _select() {
    if (_isSelectable) {
      _state._interactiveState.select(_state, _index);
    } else {
      assert(false, "Tried to select a line that wasn't selectable");
    }
  }
}

class FullState {
  _InteractiveState _interactiveState = _Quiescent();

  final List<DerivationLine> _derivation = [];

  FullState() {
    _interactiveState = _Quiescent();
  }

  List<DerivationLineInfo> get derivationLines => [
        for (int i = 0; i < _derivation.length; i++)
          DerivationLineInfo._(this, i)
      ];

  String get message => _interactiveState.message;

  String? get previewLine => _interactiveState.previewLine;

  void activateRule(Rule<StepRegionInfo> rule) {
    try {
      if (rule is FullLineStepRule) {
        _interactiveState = _SelectTwoLines(rule.getRegions(_derivation), rule);
      } else {
        throw UnimplementedError(
            '''activateRule doesn't know how to handle the rule "$rule"''');
      }
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

abstract class InteractiveText {
  final String text;

  InteractiveText(this.text);

  bool get isSelectable;

  bool get isSelected;

  void select();
}

class _DoubleTildePrinter extends _InteractiveTextPrinter {
  final FullState state;

  final Proof proof;

  _DoubleTildePrinter(this.state, this.proof);

  @override
  void dispatchFormula(Formula node, DerivationLineContext context) {
    flush();
    result.add(_SelectableText(middleDot, select: () {
      state._finishRule(
          doubleTildeRule, [proof.introduceDoubleTilde(context)()]);
    }));
    super.dispatchFormula(node, context);
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
      dispatchFormula(operand.operand, context.operand.operand);
    } else {
      super.visitNot(node, context);
    }
  }
}

abstract class _InteractiveState {
  String get message;

  String? get previewLine => null;

  bool isLineSelectable(int index) => false;

  bool isLineSelected(int index) => false;

  void select(FullState state, int index) {}
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

class _Quiescent extends _InteractiveState {
  @override
  final String message;

  _Quiescent({this.message = ''});
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

class _SelectTwoLines extends _InteractiveState {
  final FullLineStepRule rule;

  final List<FullLineStepRegionInfo?> regions;

  final List<int> selectedLines = [];

  _SelectTwoLines(this.regions, this.rule);

  @override
  String get message => 'Select 2 lines for $rule';

  @override
  String get previewLine =>
      rule.preview([for (var index in selectedLines) regions[index]!]);

  @override
  bool isLineSelectable(int index) => regions[index] != null;

  @override
  bool isLineSelected(int index) => selectedLines.contains(index);

  @override
  void select(FullState state, int index) {
    selectedLines.add(index);
    if (selectedLines.length == 2) {
      var selectedLinesList = selectedLines.toList();
      state._finishRule(
          rule,
          rule.apply(
              regions[selectedLinesList[0]]!, regions[selectedLinesList[1]]!));
    }
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
    assert(false, 'Not selectable');
  }
}
