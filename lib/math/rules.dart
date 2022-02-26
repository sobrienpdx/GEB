import 'ast.dart';

class Derivation {
  final List<DerivationStep> _steps;

  Derivation(Iterable<DerivationStep> steps)
      : this._(steps.toList(growable: false));

  Derivation._(this._steps);

  DerivationStep operator [](int index) => _steps[index];
}

abstract class DerivationReginInfo {
  StepRegionInfo? operator [](int index);
}

abstract class DerivationStep {}

class FormulaStep extends DerivationStep {
  final Formula formula;

  FormulaStep(this.formula);
}

class FullLineStepRegionInfo extends StepRegionInfo {
  final Formula _formula;

  FullLineStepRegionInfo._(this._formula);
}

class JoiningRule extends Rule<FullLineStepRegionInfo> {
  const JoiningRule()
      : super._('joining', 'If x and y are theorems, then <x∧y> is a theorem');

  List<DerivationStep> apply(
          FullLineStepRegionInfo x, FullLineStepRegionInfo y) =>
      [FormulaStep(And(x._formula, y._formula))];

  FullLineStepRegionInfo? _getRegionsForLine(Derivation derivation, int line) {
    var step = derivation[line];
    if (step is FormulaStep) {
      return FullLineStepRegionInfo._(step.formula);
    } else {
      return null;
    }
  }
}

class PartialLineStepRegionInfo {
  final Formula _formula;

  PartialLineStepRegionInfo(this._formula);
}

abstract class Rule<Info extends StepRegionInfo> {
  final String name;

  final String description;

  const Rule._(this.name, this.description);

  List<Info?> getRegions(Derivation derivation) => [
        for (int i = 0; i < derivation._steps.length; i++)
          _getRegionsForLine(derivation, i)
      ];

  Info? _getRegionsForLine(Derivation derivation, int line);
}

class SeparationRule extends Rule<SubexpressionsStepRegionInfo> {
  const SeparationRule()
      : super._('separation',
            'If <x∧y> is a theorum, then both x and y are theorems. ');

  List<DerivationStep> apply(PartialLineStepRegionInfo x) =>
      [FormulaStep(x._formula)];

  SubexpressionsStepRegionInfo? _getRegionsForLine(
      Derivation derivation, int line) {
    var step = derivation[line];
    if (step is FormulaStep) {
      var formula = step.formula;
      if (formula is And) {
        return SubexpressionsStepRegionInfo([
          PartialLineStepRegionInfo(formula.leftOperand),
          PartialLineStepRegionInfo(formula.rightOperand)
        ]);
      }
    }
    return null;
  }
}

abstract class StepRegionInfo {}

class SubexpressionsStepRegionInfo extends StepRegionInfo {
  final List<PartialLineStepRegionInfo> _subexpressions;

  SubexpressionsStepRegionInfo(this._subexpressions);
}

class UnimplementedRule extends Rule<StepRegionInfo> {
  const UnimplementedRule(String name, String description)
      : super._(name, description);

  @override
  Never _getRegionsForLine(Derivation derivation, int line) =>
      throw UnimplementedError();
}
