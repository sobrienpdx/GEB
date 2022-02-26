import 'ast.dart';

abstract class DerivationRegionInfo {
  StepRegionInfo? operator [](int index);
}

class FullLineStepRegionInfo extends StepRegionInfo {
  final Formula _formula;

  FullLineStepRegionInfo._(this._formula);
}

abstract class FullLineStepRule extends Rule<FullLineStepRegionInfo> {
  const FullLineStepRule._(String name, String description)
      : super._(name, description);

  List<Formula> apply(FullLineStepRegionInfo x, FullLineStepRegionInfo y);
}

class JoiningRule extends FullLineStepRule {
  const JoiningRule()
      : super._('joining', 'If x and y are theorems, then <x∧y> is a theorem');

  @override
  List<Formula> apply(FullLineStepRegionInfo x, FullLineStepRegionInfo y) =>
      [And(x._formula, y._formula)];

  FullLineStepRegionInfo? _getRegionsForLine(
          List<Formula> derivation, int line) =>
      FullLineStepRegionInfo._(derivation[line]);
}

class PartialLineStepRegionInfo {
  final Formula formula;

  PartialLineStepRegionInfo(this.formula);
}

abstract class Rule<Info extends StepRegionInfo> {
  final String name;

  final String description;

  const Rule._(this.name, this.description);

  List<Info?> getRegions(List<Formula> derivation) => [
        for (int i = 0; i < derivation.length; i++)
          _getRegionsForLine(derivation, i)
      ];

  @override
  String toString() => name;

  Info? _getRegionsForLine(List<Formula> derivation, int line);
}

class SeparationRule extends Rule<SubexpressionsStepRegionInfo> {
  const SeparationRule()
      : super._('separation',
            'If <x∧y> is a theorem, then both x and y are theorems. ');

  List<Formula> apply(PartialLineStepRegionInfo x) => [x.formula];

  SubexpressionsStepRegionInfo? _getRegionsForLine(
      List<Formula> derivation, int line) {
    var formula = derivation[line];
    if (formula is And) {
      return SubexpressionsStepRegionInfo([
        PartialLineStepRegionInfo(formula.leftOperand),
        PartialLineStepRegionInfo(formula.rightOperand)
      ]);
    }
    return null;
  }
}

abstract class StepRegionInfo {}

class SubexpressionsStepRegionInfo extends StepRegionInfo {
  final List<PartialLineStepRegionInfo> _subexpressions;

  SubexpressionsStepRegionInfo(this._subexpressions);

  Iterable<PartialLineStepRegionInfo> get subexpressions => _subexpressions;
}

class UnimplementedRule extends Rule<StepRegionInfo> {
  const UnimplementedRule(String name, String description)
      : super._(name, description);

  @override
  Never _getRegionsForLine(List<Formula> derivation, int line) =>
      throw UnimplementedError();
}
