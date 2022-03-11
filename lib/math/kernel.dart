import 'ast.dart';

Theorem assume(Assumption? outerAssumptions, Formula formula) =>
    Theorem._(Assumption(outerAssumptions, formula), formula, [], 'assume');

Theorem? carryOver(Assumption assumptions, Theorem theorem) {
  if (!identical(assumptions.outerAssumptions, theorem.assumptions)) {
    return null;
  }
  return Theorem._(assumptions, theorem.formula, [theorem], 'carry over');
}

Theorem? contrapositive(Theorem x, {required bool reversed}) {
  var xFormula = x.formula;
  if (xFormula is! Implies) return null;
  var leftOperand = xFormula.leftOperand;
  var rightOperand = xFormula.rightOperand;
  Formula formula;
  if (reversed) {
    if (leftOperand is! Not) return null;
    if (rightOperand is! Not) return null;
    formula = Implies(rightOperand.operand, leftOperand.operand);
  } else {
    formula = Implies(Not(rightOperand), Not(leftOperand));
  }
  return Theorem._(x.assumptions, formula, [x], 'contrapositive');
}

Theorem? deMorgans(Theorem x, {required bool reversed}) {
  var xFormula = x.formula;
  Formula formula;
  if (reversed) {
    if (xFormula is! Not) return null;
    var operand = xFormula.operand;
    if (operand is! Or) return null;
    formula = And(Not(operand.leftOperand), Not(operand.rightOperand));
  } else {
    if (xFormula is! And) return null;
    var leftOperand = xFormula.leftOperand;
    if (leftOperand is! Not) return null;
    var rightOperand = xFormula.rightOperand;
    if (rightOperand is! Not) return null;
    formula = Not(Or(leftOperand.operand, rightOperand.operand));
  }
  return Theorem._(x.assumptions, formula, [x], 'De Morgan');
}

Theorem? detachment(Theorem x, Theorem xImpliesY) {
  if (!identical(x.assumptions, xImpliesY.assumptions)) return null;
  var xImpliesYFormula = xImpliesY.formula;
  if (xImpliesYFormula is! Implies) return null;
  if (xImpliesYFormula.leftOperand != x.formula) return null;
  return Theorem._(x.assumptions, xImpliesYFormula.rightOperand, [x, xImpliesY],
      'detachment');
}

Theorem? joining(Theorem x, Theorem y) {
  if (!identical(x.assumptions, y.assumptions)) return null;
  return Theorem._(x.assumptions, And(x.formula, y.formula), [x, y], 'joining');
}

Theorem? popFantasy(Theorem conclusion) {
  var conclusionAssumptions = conclusion.assumptions;
  if (conclusionAssumptions == null) return null;
  return Theorem._(
      conclusionAssumptions.outerAssumptions,
      Implies(conclusionAssumptions.formula, conclusion.formula),
      [conclusion],
      'pop fantasy');
}

Theorem? separation(Theorem x, Side side) {
  var xFormula = x.formula;
  if (xFormula is! And) return null;
  Formula formula;
  switch (side) {
    case Side.left:
      formula = xFormula.leftOperand;
      break;
    case Side.right:
      formula = xFormula.rightOperand;
      break;
  }
  return Theorem._(x.assumptions, formula, [x], 'separation');
}

Theorem? switcheroo(Theorem x, {required bool reversed}) {
  var xFormula = x.formula;
  Formula formula;
  if (reversed) {
    if (xFormula is! Implies) return null;
    var leftOperand = xFormula.leftOperand;
    if (leftOperand is! Not) return null;
    var rightOperand = xFormula.rightOperand;
    formula = Or(leftOperand.operand, rightOperand);
  } else {
    if (xFormula is! Or) return null;
    formula = Implies(Not(xFormula.leftOperand), xFormula.rightOperand);
  }
  return Theorem._(x.assumptions, formula, [x], 'switcheroo');
}

class Assumption {
  final Assumption? outerAssumptions;

  final Formula formula;

  Assumption(this.outerAssumptions, this.formula);
}

class Theorem {
  final Assumption? assumptions;

  final Formula formula;

  /// TODO(paul): replace with something better
  final String explanation;

  final List<Theorem> _prerequisites;

  Theorem._(
      this.assumptions, this.formula, this._prerequisites, this.explanation);

  Iterable<Theorem> get prerequisites sync* {
    yield* _prerequisites;
  }
}
