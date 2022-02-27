import 'ast.dart';
import 'context.dart';

class DerivationState {
  _ProofStackEntry _stack = _ProofStackEntry();

  final List<DerivationLine> lines = [];

  DerivationState();

  bool get isFantasyInProgress => _stack is _FantasyStackEntry;

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

  Formula carryOver(Formula x) {
    var state = _stack;
    if (state is! _FantasyStackEntry) _invalidProofStep();
    if (!state.parent.isTheorem(x)) _invalidProofStep();
    return _ordinaryProofStep(x);
  }

  Formula contrapositiveForward(DerivationLineContext context) {
    var formula = context.derivationLine;
    if (formula is! Implies) _invalidProofStep();
    return _rule(
        [context.top as Formula],
        context.substitute(
            Implies(Not(formula.rightOperand), Not(formula.leftOperand))));
  }

  Formula contrapositiveReverse(DerivationLineContext context) {
    var formula = context.derivationLine;
    if (formula is! Implies) _invalidProofStep();
    var leftOperand = formula.leftOperand;
    if (leftOperand is! Not) _invalidProofStep();
    var rightOperand = formula.rightOperand;
    if (rightOperand is! Not) _invalidProofStep();
    return _rule([context.top as Formula],
        context.substitute(Implies(rightOperand.operand, leftOperand.operand)));
  }

  Formula deMorgan(DerivationLineContext context) {
    var formula = context.derivationLine;
    Formula replacement;
    if (formula is And) {
      var leftOperand = formula.leftOperand;
      if (leftOperand is! Not) _invalidProofStep();
      var rightOperand = formula.rightOperand;
      if (rightOperand is! Not) _invalidProofStep();
      replacement = Not(Or(leftOperand.operand, rightOperand.operand));
    } else if (formula is Not) {
      var operand = formula.operand;
      if (operand is! Or) _invalidProofStep();
      replacement = And(Not(operand.leftOperand), Not(operand.rightOperand));
    } else {
      _invalidProofStep();
    }
    return _rule([context.top as Formula], context.substitute(replacement));
  }

  Formula detach(Formula x) => x is Implies
      ? _rule([x.leftOperand, x], x.rightOperand)
      : _invalidProofStep();

  Formula introduceDoubleTilde(DerivationLineContext context) => _rule(
      [context.top as Formula],
      context.substitute(Not(Not(context.derivationLine as Formula))));

  bool isTheorem(Formula x) => _stack.isTheorem(x);

  Formula join(Formula x, Formula y) => _rule([x, y], And(x, y));

  Formula popFantasy() {
    var state = _stack;
    if (state is! _FantasyStackEntry) _invalidProofStep();
    return _popFantasyProofStep(state);
  }

  Formula pushFantasy(Formula premise) => _pushFantasyProofStep(premise);

  Formula removeDoubleTilde(DerivationLineContext context) {
    var formula = context.derivationLine;
    if (formula is! Not) _invalidProofStep();
    var operand = formula.operand;
    if (operand is! Not) _invalidProofStep();
    return _rule([context.top as Formula], context.substitute(operand.operand));
  }

  Formula separate(Formula x, Side side) =>
      x is And ? _rule([x], x.getOperand(side)) : _invalidProofStep();

  Formula switcheroo(DerivationLineContext context) {
    var formula = context.derivationLine;
    Formula replacement;
    if (formula is Or) {
      replacement = Implies(Not(formula.leftOperand), formula.rightOperand);
    } else if (formula is Implies) {
      var leftOperand = formula.leftOperand;
      if (leftOperand is! Not) _invalidProofStep();
      replacement = Or(leftOperand.operand, formula.rightOperand);
    } else {
      _invalidProofStep();
    }
    return _rule([context.top as Formula], context.substitute(replacement));
  }

  Never _invalidProofStep() => throw MathError();

  Formula _ordinaryProofStep(Formula theorem) {
    _stack.addTheorem(theorem);
    lines.add(theorem);
    return theorem;
  }

  Formula _popFantasyProofStep(_FantasyStackEntry innerState) {
    _stack = innerState.parent;
    var theorem = Implies(innerState.premise, innerState.conclusion);
    lines.add(PopFantasy());
    return _ordinaryProofStep(theorem);
  }

  Formula _pushFantasyProofStep(Formula premise) {
    _stack = _FantasyStackEntry(_stack)..addTheorem(premise);
    return premise;
  }

  Formula _rule(List<Formula> premises, Formula theorem) {
    for (var premise in premises) {
      if (!isTheorem(premise)) _invalidProofStep();
    }
    return _ordinaryProofStep(theorem);
  }
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

class _ProofStackEntry {
  final Set<Formula> theorems = {};

  void addTheorem(Formula x) {
    theorems.add(x);
  }

  bool isTheorem(Formula x) => theorems.contains(x);
}
