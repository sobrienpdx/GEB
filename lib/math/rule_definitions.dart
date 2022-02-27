import 'package:geb/math/rules.dart';

const List<Rule> ruleDefinitions = [
  joiningRule,
  separationRule,
  doubleTildeRule,
  pushFantasyRule,
  popFantasyRule,
  carryOverRule,
  detachmentRule,
  contrapositiveRule,
  deMorgansRule,
  switcherooRule
];

const Rule joiningRule = JoiningRule();

const Rule separationRule = SeparationRule();

const Rule doubleTildeRule = DoubleTildeRule();

const Rule pushFantasyRule = PushFantasyRule();

const Rule popFantasyRule = PopFantasyRule();

const Rule carryOverRule = CarryOverRule();

const Rule detachmentRule = DetachmentRule();

const Rule contrapositiveRule = UnimplementedRule(
    'contrapositive', '<x⊃y and <~y⊃~x> are interchangeable.');

const Rule deMorgansRule =
    UnimplementedRule('de morgan', '<~x∧~y> and ~<x∨y> are interchangeable.');

const Rule switcherooRule =
    UnimplementedRule('switcheroo', '<x∨y> and <~x⊃y> are interchangeable.');
