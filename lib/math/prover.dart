import 'ast.dart';
import 'kernel.dart';

Theorem? rewrite(Theorem x, Formula goal) {
  {
    var result = trivialRewrite(x, goal);
    if (result != null) return result;
  }
  if (x.formula is Or) {
    x = switcheroo(x, reversed: false)!;
  }
  Theorem Function(Theorem) continuation;
  if (goal is Or) {
    goal = switcheroo(assume(null, goal), reversed: false)!.formula;
    continuation = (theorem) => switcheroo(theorem, reversed: true)!;
  } else {
    continuation = (theorem) => theorem;
  }
  {
    var result = trivialRewrite(x, goal);
    if (result != null) return continuation(result);
  }
  var xFormula = x.formula;
  if (xFormula is Implies && goal is Implies) {
    var p1Goal = xFormula.leftOperand;
    var q1Goal = xFormula.rightOperand;
    var p2Goal = goal.leftOperand;
    var q2Goal = goal.rightOperand;
    var p2 = assume(x.assumptions, p2Goal);
    var p1 = rewrite(p2, p1Goal);
    if (p1 == null) return null;
    var q1 = detachment(p1, x);
    if (q1 == null) return null;
    assert(q1.formula == q1Goal);
    var q2 = rewrite(q1, q2Goal);
    if (q2 == null) return null;
    var result = popFantasy(q2);
    if (result == null) return null;
    return continuation(result);
  }
  return null;
}

Theorem? trivialRewrite(Theorem x, Formula goal) {
  if (x.formula == goal) return x;
  // TODO(paul): trivial rewrites with double tilde
  return null;
}
