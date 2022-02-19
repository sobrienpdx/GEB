import 'ast.dart';
import 'context.dart';

class Proof {
  _ProofState _state = _ProofState();

  Formula carryOver(Formula x) {
    var state = _state;
    if (state is! _FantasyState) throw MathError();
    if (!state.parent.isTheorem(x)) throw MathError();
    _state.addTheorem(x);
    return x;
  }

  Formula introduceDoubleTilde(FormulaContext context) =>
      _rule([context.top], () => context.substitute(Not(Not(context.formula))));

  bool isTheorem(Formula x) => _state.isTheorem(x);

  Formula join(Formula x, Formula y) => _rule([x, y], () => And(x, y));

  Formula popFantasy() {
    var state = _state;
    if (state is! _FantasyState) throw MathError();
    _state = state.parent;
    var result = Implies(state.premise, state.conclusion);
    _state.addTheorem(result);
    return result;
  }

  void pushFantasy(Formula premise) {
    _state = _FantasyState(_state, premise);
  }

  Formula removeDoubleTilde(FormulaContext context) {
    var formula = context.formula;
    if (formula is! Not) throw MathError();
    var operand = formula.operand;
    if (operand is! Not) throw MathError();
    return _rule([context.top], () => context.substitute(operand.operand));
  }

  Formula separate(Formula x, Side side) =>
      _rule([x], () => x is And ? x.getOperand(side) : throw MathError());

  Formula _rule(List<Formula> premises, Formula createNewTheorem()) {
    for (var premise in premises) {
      if (!isTheorem(premise)) throw MathError();
    }
    var result = createNewTheorem();
    _state.addTheorem(result);
    return result;
  }
}

class _FantasyState extends _ProofState {
  final _ProofState parent;

  final Formula premise;

  Formula conclusion;

  _FantasyState(this.parent, this.premise) : conclusion = premise {
    super.addTheorem(premise);
  }

  @override
  void addTheorem(Formula x) {
    super.addTheorem(x);
    conclusion = x;
  }
}

class _ProofState {
  final Set<Formula> theorems = {};

  void addTheorem(Formula x) {
    theorems.add(x);
  }

  bool isTheorem(Formula x) => theorems.contains(x);
}
