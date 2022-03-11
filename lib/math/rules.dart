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

class ContrapositiveRule extends FullLineStepRule {
  const ContrapositiveRule()
      : super._('contrapositive', '<x⊃y> and <~y⊃~x> are interchangeable.',
            count: 1);

  @override
  void apply(DerivationState derivation, List<Formula> formulas) {
    var x = formulas.single as Implies;
    if (x.leftOperand is Not && x.rightOperand is Not) {
      derivation.contrapositiveReverse(x);
    } else {
      derivation.contrapositiveForward(x);
    }
  }

  @override
  String preview(List<Formula> formulas) => '<~y⊃~x>';

  @override
  bool _isLineSelectable(
          DerivationLine line, List<DerivationLine> selectedLines) =>
      line is Implies;
}

class DeMorgansRule extends FullLineStepRule {
  const DeMorgansRule()
      : super._('de morgan', '<~x∧~y> and ~<x∨y> are interchangeable.',
            count: 1);

  @override
  void apply(DerivationState derivation, List<Formula> formulas) {
    derivation.deMorgan(formulas.single);
  }

  @override
  String preview(List<Formula> formulas) => '';

  @override
  bool _isLineSelectable(
          DerivationLine line, List<DerivationLine> selectedLines) =>
      line is And && line.leftOperand is Not && line.rightOperand is Not ||
      line is Not && line.operand is Or;
}

abstract class DerivationRegionInfo {
  StepRegionInfo? operator [](int index);
}

class DetachmentRule extends FullLineStepRule {
  const DetachmentRule()
      : super._('detachment',
            'If x and <x⊃y> are both theorems, then y is a theorem.',
            count: 2);

  @override
  void apply(DerivationState derivation, List<Formula> formulas) {
    var x = formulas[0];
    var y = formulas[1];
    if (x is Implies && x.leftOperand == y) {
      derivation.detach(x);
    } else {
      derivation.detach(y);
    }
  }

  @override
  String preview(List<Formula> regions) {
    if (regions.isEmpty) return '';
    var line = regions[0];
    if (line is Implies) {
      return line.rightOperand.toString();
    } else {
      return '';
    }
  }

  @override
  bool _isLineSelectable(
      DerivationLine line, List<DerivationLine> selectedLines) {
    if (line is! Formula) return false;
    if (selectedLines.isEmpty) return true;
    var selectedLine = selectedLines[0];
    if (selectedLine is Implies && line == selectedLine.leftOperand) {
      return true;
    }
    if (line is Implies && selectedLine == line.leftOperand) {
      return true;
    }
    return false;
  }
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
  final int _count;

  const FullLineStepRule._(String name, String description,
      {required int count})
      : _count = count,
        super._(name, description);

  @override
  SelectLines activate(FullState state, DerivationState derivation) {
    var lines = derivation.lines;
    var availableFlags = derivation.getAvailableFlags();
    return SelectLines(
        (index, selectedLines) =>
            availableFlags[index] &&
            _isLineSelectable(
                lines[index], [for (var index in selectedLines) lines[index]]),
        this,
        count: _count);
  }

  void apply(DerivationState derivation, List<Formula> formulas);

  List<bool> computeIsSelectable(DerivationState derivation) {
    var availableFlags = derivation.getAvailableFlags();
    var lines = derivation.lines;
    return [
      for (int i = 0; i < availableFlags.length; i++)
        availableFlags[i] && _isLineSelectable(lines[i], [])
    ];
  }

  String preview(List<Formula> regions);

  bool _isLineSelectable(
      DerivationLine line, List<DerivationLine> selectedLines);
}

class JoiningRule extends FullLineStepRule {
  const JoiningRule()
      : super._('joining', 'If x and y are theorems, then <x∧y> is a theorem',
            count: 2);

  @override
  void apply(DerivationState derivation, List<Formula> formulas) {
    derivation.join(formulas[0], formulas[1]);
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
  bool _isLineSelectable(
          DerivationLine line, List<DerivationLine> selectedLines) =>
      line is Formula;
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

class SwitcherooRule extends FullLineStepRule {
  const SwitcherooRule()
      : super._('switcheroo', '<x∨y> and <~x⊃y> are interchangeable.',
            count: 1);

  @override
  void apply(DerivationState derivation, List<Formula> formulas) {
    derivation.switcheroo(formulas.single);
  }

  @override
  String preview(List<Formula> formulas) => '';

  @override
  bool _isLineSelectable(
          DerivationLine line, List<DerivationLine> selectedLines) =>
      line is Or || line is Implies && line.leftOperand is Not;
}

class UnimplementedRule extends Rule {
  const UnimplementedRule(String name, String description)
      : super._(name, description);
}
