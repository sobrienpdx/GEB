import 'ast.dart';
import 'rules.dart';

class DerivationLineInfo {
  final FullState _state;

  final int _index;

  DerivationLineInfo._(this._state, this._index);

  bool get isSelectable => _state._interactiveState.isLineSelectable(_index);

  bool get isSelected => _state._interactiveState.isLineSelected(_index);

  DerivationLine get line => _state._derivation[_index];

  void select() {
    if (isSelectable) {
      _state._interactiveState.select(_state, _index);
    } else {
      assert(false, "Tried to select a line that wasn't selectable");
    }
  }

  @override
  String toString() {
    var parts = [
      line,
      if (isSelectable) 'selectable',
      if (isSelected) 'selected'
    ];
    return 'ProofLine(${parts.join(', ')})';
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
}

abstract class _InteractiveState {
  String get message;

  String? get previewLine => null;

  bool isLineSelectable(int index) => false;

  bool isLineSelected(int index) => false;

  void select(FullState state, int index) {}
}

class _Quiescent extends _InteractiveState {
  @override
  final String message;

  _Quiescent({this.message = ''});
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
      state._derivation.addAll(rule.apply(
          regions[selectedLinesList[0]]!, regions[selectedLinesList[1]]!));
      state._interactiveState = _Quiescent(message: 'Applied rule "$rule"');
    }
  }
}
