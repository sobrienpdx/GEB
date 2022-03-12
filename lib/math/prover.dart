import 'ast.dart';
import 'kernel.dart';

const ContinuationStrategy rewrite = const ApplyEverywhere(trivialRewrite);

const ContinuationStrategy trivialRewrite = const TrivialRewrite();

class ApplyEverywhere extends ContinuationStrategy {
  final ContinuationStrategy strategy;

  const ApplyEverywhere(this.strategy);

  @override
  Theorem? _continueFrom(ProverState state, Theorem theorem, Formula goal) {
    var result = strategy._continueFrom(state, theorem, goal);
    if (result != null) {
      assert(result.formula == goal);
      return result;
    }
    Theorem Function(Theorem) continuation;
    if (theorem.formula is Or && goal is Or) {
      theorem = switcheroo(theorem)!;
      continuation = (theorem) => reverseSwitcheroo(theorem)!;
    } else {
      continuation = (theorem) => theorem;
    }
    var formula = theorem.formula;
    if (formula is Implies && goal is Implies) {
      // Given <P1->Q1>, form <P2->Q2> as follows:
      //   [         push fantasy
      //     P2      premise
      //     P1      recursion
      //     Q1      detachment
      //     Q2      recursion
      //   ]         pop fantasy
      //   <P2->Q2>  conclusion
      var p1Formula = formula.leftOperand;
      var q1Formula = formula.rightOperand;
      var p2Formula = goal.leftOperand;
      var q2Formula = goal.rightOperand;
      var p2 = assume(theorem.assumptions, p2Formula);
      var p1 = _continueFrom(state, p2, p1Formula);
      if (p1 == null) return null;
      assert(p1.formula == p1Formula);
      var q1 = detachment(p1, theorem)!;
      assert(q1.formula == q1Formula);
      var q2 = _continueFrom(state, q1, q2Formula);
      if (q2 == null) return null;
      assert(q2.formula == q2Formula);
      var result = popFantasy(q2)!;
      return continuation(result);
    }
    return fail('rewrite', 'no rule to rewrite $formula to $goal');
  }
}

class BoundContinuationStrategy extends BoundStrategy {
  final ContinuationStrategy strategy;
  final Formula goal;

  BoundContinuationStrategy._(this.strategy, this.goal);

  @override
  void run(ProverState state) {
    for (int i = 0; i < state._theorems.length; i++) {
      var result = strategy._continueFrom(state, state._theorems[i], goal);
      if (result != null) {
        state.addTheorem(result);
        if (result.formula == goal) return;
      }
    }
  }
}

abstract class BoundStrategy {
  const BoundStrategy();

  void run(ProverState state);

  Strategy then(Strategy strategy) => _SequenceStrategy(this, strategy);
}

abstract class ContinuationStrategy extends Strategy {
  const ContinuationStrategy();

  BoundContinuationStrategy to(Formula goal) =>
      BoundContinuationStrategy._(this, goal);

  Theorem? _continueFrom(ProverState state, Theorem theorem, Formula goal);
}

class Fantasy extends Strategy {
  final Strategy strategy;

  const Fantasy({this.strategy = const NullStrategy()});

  @override
  BoundStrategy to(Formula goal) => _BoundFantasy(strategy, goal);
}

class NullStrategy extends Strategy {
  const NullStrategy();

  @override
  BoundStrategy to(Formula goal) => const _BoundNullStrategy();
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

  BoundStrategy to(Formula goal);
}

class TrivialRewrite extends ContinuationStrategy {
  const TrivialRewrite();

  @override
  Theorem? _continueFrom(ProverState state, Theorem theorem, Formula goal) {
    const rules = [switcheroo, reverseSwitcheroo];
    for (var rule in rules) {
      var result = rule(theorem);
      if (result != null && result.formula == goal) return result;
    }
    return null;
  }
}

class _BoundFantasy extends BoundStrategy {
  final Strategy strategy;

  final Formula goal;

  _BoundFantasy(this.strategy, this.goal);

  @override
  void run(ProverState state) {
    var goal = this.goal;
    if (goal is! Implies) return;
    var premise = assume(state.assumptions, goal.leftOperand);
    var nestedState = ProverState.nest(state, premise);
    strategy.to(goal.rightOperand).run(nestedState);
    var conclusion = nestedState.getTheorem(goal.rightOperand);
    if (conclusion != null) {
      state.addTheorem(popFantasy(conclusion)!);
    }
  }
}

class _BoundNullStrategy extends BoundStrategy {
  const _BoundNullStrategy();

  @override
  void run(ProverState state) {}
}

class _BoundSequenceStrategy extends BoundStrategy {
  final BoundStrategy first;
  final BoundStrategy second;

  _BoundSequenceStrategy(this.first, this.second);

  @override
  void run(ProverState state) {
    first.run(state);
    second.run(state);
  }
}

class _SequenceStrategy extends Strategy {
  final BoundStrategy first;
  final Strategy second;

  _SequenceStrategy(this.first, this.second);

  @override
  BoundStrategy to(Formula goal) =>
      _BoundSequenceStrategy(first, second.to(goal));
}
