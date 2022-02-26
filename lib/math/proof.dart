import 'ast.dart';
import 'context.dart';

class DerivationState {
  _ProofStackEntry _stack = _ProofStackEntry();

  final List<DerivationLine> lines = [];

  DerivationState();

  void addLine(DerivationLine line) {
    if (line is Formula) {
      _stack.addTheorem(line);
    } else if (line is PushFantasy) {
      _stack = _FantasyStackEntry(_stack);
    } else if (line is PopFantasy) {
      var stack = _stack;
      if (stack is _FantasyStackEntry) {
        _stack = stack.parent;
      }
    } else {
      assert(
          false, 'Unrecognized kind of derivation line: ${line.runtimeType}');
    }
    lines.add(line);
  }

  ProofStep carryOver(Formula x) {
    var state = _stack;
    if (state is! _FantasyStackEntry) return InvalidProofStep();
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

  bool isTheorem(Formula x) => _stack.isTheorem(x);

  ProofStep join(Formula x, Formula y) => _rule([x, y], And(x, y));

  ProofStep popFantasy() {
    var state = _stack;
    if (state is! _FantasyStackEntry) return InvalidProofStep();
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

class InvalidProofStep extends ProofStep {
  @override
  bool get isValid => false;

  @override
  Never call() => throw MathError();
}

abstract class ProofStep {
  bool get isValid;

  Formula call();
}

abstract class ValidProofStep extends ProofStep {
  @override
  bool get isValid => true;
}

class _FantasyStackEntry extends _ProofStackEntry {
  final _ProofStackEntry parent;

  Formula? _premise;

  Formula? _conclusion;

  _FantasyStackEntry(this.parent);

  Formula get conclusion => _conclusion!;

  Formula get premise => _premise!;

  @override
  void addTheorem(Formula x) {
    super.addTheorem(x);
    _premise ??= x;
    _conclusion = x;
  }
}

class _OrdinaryProofStep extends ValidProofStep {
  final DerivationState _proof;

  final Formula _theorem;

  _OrdinaryProofStep(this._proof, this._theorem);

  @override
  Formula call() {
    _proof._stack.addTheorem(_theorem);
    _proof.lines.add(_theorem);
    return _theorem;
  }
}

class _PopFantasyProofStep extends _OrdinaryProofStep {
  final _ProofStackEntry _outerState;

  _PopFantasyProofStep(DerivationState proof, _FantasyStackEntry innerState)
      : _outerState = innerState.parent,
        super(proof, Implies(innerState.premise, innerState.conclusion));

  @override
  Formula call() {
    _proof._stack = _outerState;
    return super.call();
  }
}

class _ProofStackEntry {
  final Set<Formula> theorems = {};

  void addTheorem(Formula x) {
    theorems.add(x);
  }

  bool isTheorem(Formula x) => theorems.contains(x);
}

class _PushFantasyProofStep extends ValidProofStep {
  final DerivationState _proof;

  final Formula _premise;

  _PushFantasyProofStep(this._proof, this._premise);

  @override
  Formula call() {
    _proof._stack = _FantasyStackEntry(_proof._stack)..addTheorem(_premise);
    return _premise;
  }
}
