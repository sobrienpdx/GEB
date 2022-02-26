import 'ast.dart';
import 'context.dart';

class InvalidProofStep extends ProofStep {
  @override
  bool get isValid => false;

  @override
  Never call() => throw MathError();
}

class Proof {
  _ProofState _state = _ProofState();

  Proof();

  Proof.fromDerivation(List<DerivationLine> derivation) {
    // TODO(paul): just use Derivation directly rather than having a silly
    // ProofState object.
    for (int i = 0; i < derivation.length; i++) {
      var line = derivation[i];
      if (line is Formula) {
        _state.addTheorem(line);
      } else if (line is PushFantasy) {
        var premise = i + 1 < derivation.length ? derivation[i + 1] : null;
        if (premise is Formula) {
          pushFantasy(premise);
          i++;
        }
      } else if (line is PopFantasy) {
        var state = _state;
        if (state is _FantasyState) {
          _state = state.parent;
        }
      } else {
        assert(
            false, 'Unrecognized kind of derivation line: ${line.runtimeType}');
      }
    }
  }

  ProofStep carryOver(Formula x) {
    var state = _state;
    if (state is! _FantasyState) return InvalidProofStep();
    if (!state.parent.isTheorem(x)) return InvalidProofStep();
    return _OrdinaryProofStep(this, x);
  }

  ProofStep contrapositiveForward(DerivationLineContext context) {
    var formula = context.derivationLine;
    if (formula is! Implies) return InvalidProofStep();
    return _rule(
        [context.top as Formula],
        context.substitute(
            Implies(Not(formula.rightOperand), Not(formula.leftOperand))));
  }

  ProofStep contrapositiveReverse(DerivationLineContext context) {
    var formula = context.derivationLine;
    if (formula is! Implies) return InvalidProofStep();
    var leftOperand = formula.leftOperand;
    if (leftOperand is! Not) return InvalidProofStep();
    var rightOperand = formula.rightOperand;
    if (rightOperand is! Not) return InvalidProofStep();
    return _rule([context.top as Formula],
        context.substitute(Implies(rightOperand.operand, leftOperand.operand)));
  }

  ProofStep deMorgan(DerivationLineContext context) {
    var formula = context.derivationLine;
    Formula replacement;
    if (formula is And) {
      var leftOperand = formula.leftOperand;
      if (leftOperand is! Not) return InvalidProofStep();
      var rightOperand = formula.rightOperand;
      if (rightOperand is! Not) return InvalidProofStep();
      replacement = Not(Or(leftOperand.operand, rightOperand.operand));
    } else if (formula is Not) {
      var operand = formula.operand;
      if (operand is! Or) return InvalidProofStep();
      replacement = And(Not(operand.leftOperand), Not(operand.rightOperand));
    } else {
      return InvalidProofStep();
    }
    return _rule([context.top as Formula], context.substitute(replacement));
  }

  ProofStep detach(Formula x) => x is Implies
      ? _rule([x.leftOperand, x], x.rightOperand)
      : InvalidProofStep();

  ProofStep introduceDoubleTilde(DerivationLineContext context) => _rule(
      [context.top as Formula],
      context.substitute(Not(Not(context.derivationLine as Formula))));

  bool isTheorem(Formula x) => _state.isTheorem(x);

  ProofStep join(Formula x, Formula y) => _rule([x, y], And(x, y));

  ProofStep popFantasy() {
    var state = _state;
    if (state is! _FantasyState) return InvalidProofStep();
    return _PopFantasyProofStep(this, state);
  }

  ProofStep pushFantasy(Formula premise) =>
      _PushFantasyProofStep(this, premise);

  ProofStep removeDoubleTilde(DerivationLineContext context) {
    var formula = context.derivationLine;
    if (formula is! Not) return InvalidProofStep();
    var operand = formula.operand;
    if (operand is! Not) return InvalidProofStep();
    return _rule([context.top as Formula], context.substitute(operand.operand));
  }

  ProofStep separate(Formula x, Side side) =>
      x is And ? _rule([x], x.getOperand(side)) : InvalidProofStep();

  ProofStep switcheroo(DerivationLineContext context) {
    var formula = context.derivationLine;
    Formula replacement;
    if (formula is Or) {
      replacement = Implies(Not(formula.leftOperand), formula.rightOperand);
    } else if (formula is Implies) {
      var leftOperand = formula.leftOperand;
      if (leftOperand is! Not) return InvalidProofStep();
      replacement = Or(leftOperand.operand, formula.rightOperand);
    } else {
      return InvalidProofStep();
    }
    return _rule([context.top as Formula], context.substitute(replacement));
  }

  ProofStep _rule(List<Formula> premises, Formula theorem) {
    for (var premise in premises) {
      if (!isTheorem(premise)) return InvalidProofStep();
    }
    return _OrdinaryProofStep(this, theorem);
  }
}

abstract class ProofStep {
  bool get isValid;

  Formula call();
}

abstract class ValidProofStep extends ProofStep {
  @override
  bool get isValid => true;
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

class _OrdinaryProofStep extends ValidProofStep {
  final Proof _proof;

  final Formula _theorem;

  _OrdinaryProofStep(this._proof, this._theorem);

  @override
  Formula call() {
    _proof._state.addTheorem(_theorem);
    return _theorem;
  }
}

class _PopFantasyProofStep extends _OrdinaryProofStep {
  final _ProofState _outerState;

  _PopFantasyProofStep(Proof proof, _FantasyState innerState)
      : _outerState = innerState.parent,
        super(proof, Implies(innerState.premise, innerState.conclusion));

  @override
  Formula call() {
    _proof._state = _outerState;
    return super.call();
  }
}

class _ProofState {
  final Set<Formula> theorems = {};

  void addTheorem(Formula x) {
    theorems.add(x);
  }

  bool isTheorem(Formula x) => theorems.contains(x);
}

class _PushFantasyProofStep extends ValidProofStep {
  final Proof _proof;

  final Formula _premise;

  _PushFantasyProofStep(this._proof, this._premise);

  @override
  Formula call() {
    _proof._state = _FantasyState(_proof._state, _premise);
    return _premise;
  }
}
