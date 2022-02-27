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

const Rule contrapositiveRule = ContrapositiveRule();

const Rule deMorgansRule = DeMorgansRule();

const Rule switcherooRule = SwitcherooRule();
