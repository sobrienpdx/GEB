import 'ast.dart';

String? latestFailureMessage;

Theorem assume(Assumption? outerAssumptions, Formula formula) {
  var assumption = Assumption(outerAssumptions, formula);
  var theorem = Theorem._(assumption, formula, [], 'assume');
  assumption.asTheorem = theorem;
  return theorem;
}

Theorem? carryOver(Assumption assumptions, Theorem theorem) {
  if (!identical(assumptions.outerAssumptions, theorem.assumptions)) {
    return fail('carry over', 'mismatched assumptions');
  }
  return CarryOverTheorem._(assumptions, theorem);
}

Theorem? contrapositive(Theorem x, {required bool reversed}) {
  var xFormula = x.formula;
  if (xFormula is! Implies) {
    return mismatch('contrapositive', '<x⊃y>', xFormula);
  }
  var leftOperand = xFormula.leftOperand;
  var rightOperand = xFormula.rightOperand;
  Formula formula;
  if (reversed) {
    if (leftOperand is! Not) {
      return mismatch('reverse contrapositive', '<~x⊃~y>', xFormula);
    }
    if (rightOperand is! Not) {
      return mismatch('reverse contrapositive', '<~x⊃~y>', xFormula);
    }
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
    if (xFormula is! Not) {
      return mismatch('reverse De Morgan', '~<x∨y>', xFormula);
    }
    var operand = xFormula.operand;
    if (operand is! Or) {
      return mismatch('reverse De Morgan', '~<x∨y>', xFormula);
    }
    formula = And(Not(operand.leftOperand), Not(operand.rightOperand));
  } else {
    if (xFormula is! And) {
      return mismatch('De Morgan', '<~x∧~y>', xFormula);
    }
    var leftOperand = xFormula.leftOperand;
    if (leftOperand is! Not) {
      return mismatch('De Morgan', '<~x∧~y>', xFormula);
    }
    var rightOperand = xFormula.rightOperand;
    if (rightOperand is! Not) {
      return mismatch('De Morgan', '<~x∧~y>', xFormula);
    }
    formula = Not(Or(leftOperand.operand, rightOperand.operand));
  }
  return Theorem._(x.assumptions, formula, [x], 'De Morgan');
}

Theorem? detachment(Theorem x, Theorem xImpliesY) {
  if (!identical(x.assumptions, xImpliesY.assumptions)) {
    return fail('detachment', 'mismatched assumptions');
  }
  var xImpliesYFormula = xImpliesY.formula;
  if (xImpliesYFormula is! Implies) {
    return mismatch('detachment', '<x⊃y>', xImpliesYFormula);
  }
  if (xImpliesYFormula.leftOperand != x.formula) {
    return fail('detachment', 'mismatched premise');
  }
  return Theorem._(x.assumptions, xImpliesYFormula.rightOperand, [x, xImpliesY],
      'detachment');
}

Null fail(String trying, String message) {
  latestFailureMessage = '$trying: $message';
  return null;
}

Theorem given(Formula formula) => Theorem._(null, formula, [], 'given');

Theorem? joining(Theorem x, Theorem y) {
  if (!identical(x.assumptions, y.assumptions)) {
    return fail('joining', 'mismatched assumptions');
  }
  return Theorem._(x.assumptions, And(x.formula, y.formula), [x, y], 'joining');
}

Null mismatch(String trying, String pattern, Formula got) =>
    fail(trying, 'requires $pattern, got $got');

Theorem? popFantasy(Theorem conclusion) {
  var conclusionAssumptions = conclusion.assumptions;
  if (conclusionAssumptions == null) {
    return fail('pop fantasy', 'no assumptions');
  }
  return PopFantasyTheorem._(conclusionAssumptions,
      Implies(conclusionAssumptions.formula, conclusion.formula), conclusion);
}

Theorem? reverseSwitcheroo(Theorem x) {
  var xFormula = x.formula;
  if (xFormula is! Implies) {
    return mismatch('reverse switcheroo', '<~x⊃y>', xFormula);
  }
  var leftOperand = xFormula.leftOperand;
  if (leftOperand is! Not) {
    return mismatch('reverse switcheroo', '<~x⊃y>', xFormula);
  }
  return Theorem._(x.assumptions,
      Or(leftOperand.operand, xFormula.rightOperand), [x], 'switcheroo');
}

Theorem? separation(Theorem x, Side side) {
  var xFormula = x.formula;
  if (xFormula is! And) {
    return mismatch('separation', '<x∧y>', xFormula);
  }
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

Theorem? switcheroo(Theorem x) {
  var xFormula = x.formula;
  if (xFormula is! Or) {
    return mismatch('switcheroo', '<x∨y>', xFormula);
  }
  return Theorem._(
      x.assumptions,
      Implies(Not(xFormula.leftOperand), xFormula.rightOperand),
      [x],
      'switcheroo');
}

class Assumption {
  final Assumption? outerAssumptions;

  final Formula formula;

  late final Theorem asTheorem;

  Assumption(this.outerAssumptions, this.formula);
}

class CarryOverTheorem extends Theorem {
  final Theorem outer;

  CarryOverTheorem._(Assumption assumptions, this.outer)
      : super._(assumptions, outer.formula, [], 'carry over');
}

class PopFantasyTheorem extends Theorem {
  final Assumption premise;

  final Theorem conclusion;

  PopFantasyTheorem._(this.premise, Implies formula, this.conclusion)
      : super._(
            premise.outerAssumptions,
            formula,
            _computePrerequisites(premise.outerAssumptions, conclusion),
            'pop fantasy');

  static List<Theorem> _computePrerequisites(
      Assumption? outerAssumptions, Theorem conclusion) {
    Set<Theorem> seenTheorems = {};
    List<Theorem> prerequisites = [];
    void visit(Theorem theorem) {
      if (seenTheorems.add(theorem)) {
        if (theorem is CarryOverTheorem) {
          prerequisites.add(theorem.outer);
        }
        for (var prerequisite in theorem.prerequisites) {
          visit(prerequisite);
        }
      }
    }

    visit(conclusion);
    return prerequisites;
  }
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
