import 'ast.dart';
import 'kernel.dart';

Theorem? _rewrite(Theorem x, Formula goal) {
  {
    var result = _trivialRewrite(x, goal);
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
    var result = _trivialRewrite(x, goal);
    if (result != null) return continuation(result);
  }
  var xFormula = x.formula;
  if (xFormula is Implies && goal is Implies) {
    var p1Goal = xFormula.leftOperand;
    var q1Goal = xFormula.rightOperand;
    var p2Goal = goal.leftOperand;
    var q2Goal = goal.rightOperand;
    var p2 = assume(x.assumptions, p2Goal);
    var p1 = _rewrite(p2, p1Goal);
    if (p1 == null) return null;
    var q1 = detachment(p1, x);
    if (q1 == null) return null;
    assert(q1.formula == q1Goal);
    var q2 = _rewrite(q1, q2Goal);
    if (q2 == null) return null;
    var result = popFantasy(q2);
    if (result == null) return null;
    return continuation(result);
  }
  return fail('rewrite', 'no rule to rewrite $xFormula to $goal');
}

Theorem? _trivialRewrite(Theorem x, Formula goal) {
  if (x.formula == goal) return x;
  // TODO(paul): trivial rewrites with double tilde
  return null;
}

abstract class ContinuationStrategy extends Strategy {
  const ContinuationStrategy();

  Theorem? continueFrom(ProverState state, Theorem theorem, Formula goal);

  @override
  void run(ProverState state, Formula goal) {
    for (int i = 0; i < state._theorems.length; i++) {
      var result = continueFrom(state, state._theorems[i], goal);
      if (result != null) {
        state.addTheorem(result);
        if (result.formula == goal) return;
      }
    }
  }
}

class Fantasy extends Strategy {
  final Strategy strategy;

  const Fantasy({this.strategy = const NullStrategy()});

  @override
  void run(ProverState state, Formula goal) {
    if (goal is! Implies) return;
    var premise = assume(state.assumptions, goal.leftOperand);
    var nestedState = ProverState.nest(state, premise);
    strategy.thenRewrite().run(nestedState, goal.rightOperand);
    var conclusion = nestedState.getTheorem(goal.rightOperand);
    if (conclusion != null) {
      state.addTheorem(popFantasy(conclusion)!);
    }
  }
}

class NullStrategy extends Strategy {
  const NullStrategy();

  @override
  void run(ProverState state, Formula goal) {}
}

class ProverState {
  final Map<Formula, Theorem> _formulaToTheorem = {};

  final List<Theorem> _theorems = [];

  final Assumption? assumptions;

  ProverState() : assumptions = null;

  ProverState.nest(ProverState outerState, Theorem premise)
      : assumptions = premise.assumptions {
    addTheorem(premise);
    for (var theorem in outerState._theorems) {
      addTheorem(carryOver(premise.assumptions!, theorem)!);
    }
  }

  void addTheorem(Theorem theorem) {
    if (!identical(theorem.assumptions, assumptions)) {
      throw 'assumptions mismatch';
    }
    var previousTheorem = _formulaToTheorem[theorem.formula];
    if (previousTheorem == null) {
      _formulaToTheorem[theorem.formula] ??= theorem;
      _theorems.add(theorem);
    }
  }

  Theorem? getTheorem(Formula formula) => _formulaToTheorem[formula];
}

abstract class Strategy {
  const Strategy();

  void run(ProverState state, Formula goal);

  Strategy thenRewrite() => _SequenceStrategy(this, const _RewriteStrategy());
}

class SubGoal extends Strategy {
  final Formula subGoal;

  final Strategy strategy;

  SubGoal(this.subGoal, {this.strategy = const NullStrategy()});

  @override
  void run(ProverState state, Formula goal) {
    strategy.thenRewrite().run(state, subGoal);
  }
}

class _RewriteStrategy extends ContinuationStrategy {
  const _RewriteStrategy();

  @override
  Theorem? continueFrom(ProverState state, Theorem theorem, Formula goal) =>
      _rewrite(theorem, goal);
}

class _SequenceStrategy extends Strategy {
  final Strategy first;
  final ContinuationStrategy second;

  const _SequenceStrategy(this.first, this.second);

  void run(ProverState state, Formula goal) {
    first.run(state, goal);
    second.run(state, goal);
  }
}
