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

class JoiningRegionInfo extends RegionInfo<FullLineStepRegionInfo> {
  final Derivation _derivation;

  JoiningRegionInfo(this._derivation);

  FullLineStepRegionInfo? operator [](int index) {
    var step = _derivation[index];
    if (step is FormulaStep) {
      return FullLineStepRegionInfo._(step.formula);
    } else {
      return null;
    }
  }
}

class JoiningRule extends Rule {
  factory JoiningRule() => const JoiningRule._();

  const JoiningRule._() : super('joining');

  List<DerivationStep> apply(
          FullLineStepRegionInfo x, FullLineStepRegionInfo y) =>
      [FormulaStep(And(x._formula, y._formula))];

  JoiningRegionInfo getRegions(Derivation derivation) =>
      JoiningRegionInfo(derivation);
}

abstract class RegionInfo<StepInfo extends StepRegionInfo> {
  StepInfo? operator [](int index);
}

abstract class Rule {
  final String name;

  const Rule(this.name);
}

abstract class StepRegionInfo {}
