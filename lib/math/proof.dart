import 'ast.dart';
import 'context.dart';

class Proof {
  _ProofState _state = _TopLevelState();

  Formula introduceDoubleTilde(FormulaContext context) =>
      _rule([context.top], () => context.substitute(Not(Not(context.formula))));

  bool isTheorem(Formula x) => _state.isTheorem(x);

  Formula join(Formula x, Formula y) => _rule([x, y], () => And(x, y));

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

  final Set<Formula> localTheorems;

  _FantasyState(this.parent, Formula premise) : localTheorems = {premise};

  @override
  void addTheorem(Formula x) {
    localTheorems.add(x);
  }

  @override
  bool isTheorem(Formula x) => localTheorems.contains(x) || parent.isTheorem(x);
}

abstract class _ProofState {
  void addTheorem(Formula x);

  bool isTheorem(Formula x);
}

class _TopLevelState extends _ProofState {
  final Set<Formula> theorems = {};

  @override
  void addTheorem(Formula x) {
    theorems.add(x);
  }

  @override
  bool isTheorem(Formula x) => theorems.contains(x);
}
