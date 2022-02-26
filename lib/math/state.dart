import 'ast.dart';
import 'rules.dart';

class FullState {
  _InteractiveState _interactiveState = _Quiescent();

  final List<Formula> _derivation = [];

  FullState() {
    _interactiveState = _Quiescent();
  }

  String get message => _interactiveState.message;

  List<ProofLine> get proofLines =>
      [for (int i = 0; i < _derivation.length; i++) ProofLine._(this, i)];

  void activateRule(Rule<StepRegionInfo> rule) {
    try {
      if (rule is FullLineStepRule) {
        _interactiveState =
            _SelectMultipleLines(rule.getRegions(_derivation), rule);
      } else {
        throw UnimplementedError(
            '''activateRule doesn't know how to handle the rule "$rule"''');
      }
    } on UnimplementedError catch (e) {
      _interactiveState = _Quiescent(message: 'Unimplemented: ${e.message}');
    }
  }

  void addFormula(Formula formula) {
    _derivation.add(formula);
    _interactiveState = _Quiescent();
  }
}

class ProofLine {
  final FullState _state;

  final int _index;

  ProofLine._(this._state, this._index);

  Formula get formula => _state._derivation[_index];

  bool get isSelectable => _state._interactiveState.isLineSelectable(_index);

  bool get isSelected => _state._interactiveState.isLineSelected(_index);

  void toggleSelection() {
    if (isSelectable) {
      _state._interactiveState.toggleLineSelection(_state, _index);
    } else {
      assert(false, "Tried to select a line that wasn't selectable");
    }
  }

  @override
  String toString() {
    var parts = [
      formula,
      if (isSelectable) 'selectable',
      if (isSelected) 'selected'
    ];
    return 'ProofLine(${parts.join(', ')})';
  }
}

abstract class _InteractiveState {
  String get message;

  bool isLineSelectable(int index) => false;

  bool isLineSelected(int index) => false;

  void toggleLineSelection(FullState state, int index) {}
}

class _Quiescent extends _InteractiveState {
  @override
  final String message;

  _Quiescent({this.message = ''});
}

class _SelectMultipleLines extends _InteractiveState {
  final FullLineStepRule rule;

  final List<FullLineStepRegionInfo?> regions;

  final Set<int> selectedLines = {};

  _SelectMultipleLines(this.regions, this.rule);

  @override
  String get message => 'Select 2 lines for $rule';

  @override
  bool isLineSelectable(int index) => regions[index] != null;

  @override
  bool isLineSelected(int index) => selectedLines.contains(index);

  @override
  void toggleLineSelection(FullState state, int index) {
    if (selectedLines.contains(index)) {
      selectedLines.remove(index);
    } else {
      selectedLines.add(index);
      if (selectedLines.length == 2) {
        var selectedLinesList = selectedLines.toList();
        state._derivation.addAll(rule.apply(
            regions[selectedLinesList[0]]!, regions[selectedLinesList[1]]!));
        state._interactiveState = _Quiescent(message: 'Applied rule "$rule"');
      }
    }
  }
}
