import 'package:geb/math/rules.dart';

const List<Rule> ruleDefinitions = [
  joiningRule,
  separationRule,
  doubleTildeRule,
  fantasyRule,
  carryOverRule,
  detachmentRule,
  contrapositiveRule,
  deMorgansRule,
  switcherooRule
];

const Rule joiningRule = JoiningRule();

const Rule separationRule = SeparationRule();

const Rule doubleTildeRule = DoubleTildeRule();

const Rule fantasyRule = UnimplementedRule('fantasy',
    'If y can be derived when x is assumed to be a theorem, then <x⊃y> is a theorem.');

const Rule carryOverRule = UnimplementedRule('carry-over',
    'Inside a fantasy, any theorem from the "reality" one level higher can be brought in and used.');

const Rule detachmentRule = UnimplementedRule(
    'detachment', 'If x and <x⊃y> are both theorems, then y is a theorem.');

const Rule contrapositiveRule = UnimplementedRule(
    'contrapositive', '<x⊃y and <~y⊃~x> are interchangeable.');

const Rule deMorgansRule =
    UnimplementedRule('de morgan', '<~x∧~y> and ~<x∨y> are interchangeable.');

const Rule switcherooRule =
    UnimplementedRule('switcheroo', '<x∨y> and <~x⊃y> are interchangeable.');
