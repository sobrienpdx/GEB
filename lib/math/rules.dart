import 'package:geb/math/rule_definitions.dart';
import 'package:geb/math/symbols.dart';

import 'ast.dart';
import 'proof.dart';
import 'state.dart';

class CarryOverRule extends Rule {
  const CarryOverRule()
      : super._(
            'carry-over',
            'Inside a fantasy, any theorem from the "reality" one level higher '
                'can be brought in and used.');

  @override
  SelectRegion activate(FullState state, DerivationState derivation) =>
      _makeSelectRegion(
          derivation,
          (line) => [
                SelectableText(line.toString(), select: () {
                  derivation.carryOver(line);
                  state.finishRule(this);
                })
              ],
          carryOver: true);
}

abstract class DerivationRegionInfo {
  StepRegionInfo? operator [](int index);
}

class DoubleTildeRule extends Rule {
  const DoubleTildeRule()
      : super._(
            'double tilde',
            "The string '~~' can be deleted from any theorem. "
                "It can also be inserted into any theorem, provided that the "
                "resulting string is itself well formed.");

  @override
  SelectRegion activate(FullState state, DerivationState derivation) =>
      _makeSelectRegion(derivation,
          (line) => DoubleTildePrinter(state, derivation).run(line));
}

abstract class FullLineStepRule extends Rule {
  const FullLineStepRule._(String name, String description)
      : super._(name, description);

  @override
  SelectTwoLines activate(FullState state, DerivationState derivation) =>
      SelectTwoLines(computeIsSelectable(derivation), this);

  void apply(DerivationState derivation, Formula x, Formula y);

  List<bool> computeIsSelectable(DerivationState derivation) {
    var availableFlags = derivation.getAvailableFlags();
    var lines = derivation.lines;
    return [
      for (int i = 0; i < availableFlags.length; i++)
        availableFlags[i] && _isLineSelectable(lines[i])
    ];
  }

  String preview(List<Formula> regions);

  bool _isLineSelectable(DerivationLine line);
}

class JoiningRule extends FullLineStepRule {
  const JoiningRule()
      : super._('joining', 'If x and y are theorems, then <x∧y> is a theorem');

  @override
  void apply(DerivationState derivation, Formula x, Formula y) {
    derivation.join(x, y);
  }

  @override
  String preview(List<Formula> formulas) => [
        '<',
        formulas.length > 0 ? formulas[0] : 'x',
        and,
        formulas.length > 1 ? formulas[1] : 'y',
        '>'
      ].join();

  @override
  bool _isLineSelectable(DerivationLine line) => line is Formula;
}

class PartialLineStepRegionInfo {
  final Formula formula;

  PartialLineStepRegionInfo(this.formula);
}

class PopFantasyRule extends Rule {
  const PopFantasyRule()
      : super._(
            'pop fantasy',
            'If y can be derived when x is assumed to be a theorem, then <x⊃y> '
                'is a theorem.');

  @override
  Quiescent activate(FullState state, DerivationState derivation) {
    var lines = derivation.lines;
    if (derivation.isFantasyInProgress) {
      if (lines.last is Formula) {
        derivation.popFantasy();
        return Quiescent(message: 'Applied rule "$popFantasyRule".');
      }
    }
    return Quiescent(message: 'Cannot pop a fantasy right now.');
  }
}

class PushFantasyRule extends Rule {
  const PushFantasyRule()
      : super._('push fantasy', 'Begin a fantasy, assuming x is a theorem.');

  @override
  Quiescent activate(FullState state, DerivationState derivation) {
    derivation.addLine(PushFantasy());
    return Quiescent(message: 'Starting a fantasy,  Please enter the premise.');
  }
}

abstract class Rule {
  final String name;

  final String description;

  const Rule._(this.name, this.description);

  InteractiveState activate(FullState state, DerivationState derivation) {
    throw UnimplementedError(
        '''activateRule doesn't know how to handle the rule "$this"''');
  }

  @override
  String toString() => name;

  SelectRegion _makeSelectRegion(DerivationState derivation,
      List<InteractiveText> Function(Formula) callback,
      {bool carryOver = false}) {
    var availableFlags = derivation.getAvailableFlags(carryOver: carryOver);
    var lines = derivation.lines;
    return SelectRegion(this, [
      for (int i = 0; i < availableFlags.length; i++)
        availableFlags[i]
            ? callback(lines[i] as Formula)
            : [SimpleText(lines[i].toString())]
    ]);
  }
}

class SeparationRule extends Rule {
  const SeparationRule()
      : super._('separation',
            'If <x∧y> is a theorem, then both x and y are theorems.');

  @override
  SelectRegion activate(FullState state, DerivationState derivation) =>
      _makeSelectRegion(
          derivation, (line) => SeparationPrinter(state, derivation).run(line));
}

abstract class StepRegionInfo {}

class SubexpressionsStepRegionInfo extends StepRegionInfo {
  final List<PartialLineStepRegionInfo> _subexpressions;

  SubexpressionsStepRegionInfo(this._subexpressions);

  Iterable<PartialLineStepRegionInfo> get subexpressions => _subexpressions;
}

class UnimplementedRule extends Rule {
  const UnimplementedRule(String name, String description)
      : super._(name, description);
}
