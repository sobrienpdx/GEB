import 'ast.dart';
import 'context.dart';
import 'rule_definitions.dart';
import 'rules.dart';

class DerivationState {
  _ProofStackEntry _stack = _ProofStackEntry();

  final List<_DerivationStep> _steps = [];

  DerivationState();

  List<String> get explanations => [for (var step in _steps) step.explanation];

  bool get isFantasyInProgress => _stack is _FantasyStackEntry;

  /// TODO(paul): probably most callers of this are misusing it--it doesn't
  /// filter down to just the accessible theorems.
  List<DerivationLine> get lines => [for (var step in _steps) step.line];

  void addLine(DerivationLine line, {String? explanation}) {
    if (line is Formula) {
      _stack.addTheorem(line);
      explanation ??= 'User supplied premise';
    } else if (line is PushFantasy) {
      _stack = _FantasyStackEntry(_stack);
      explanation ??= 'Applied rule "push fantasy"';
    } else if (line is PopFantasy) {
      var stack = _stack;
      if (stack is _FantasyStackEntry) {
        _stack = stack.parent;
      }
      explanation ??= 'Applied rule "$popFantasyRule"';
    } else {
      assert(
          false, 'Unrecognized kind of derivation line: ${line.runtimeType}');
    }
    _steps.add(_DerivationStep(line, explanation!));
  }

  Formula carryOver(Formula x) {
    var state = _stack;
    if (state is! _FantasyStackEntry) _invalidProofStep();
    if (!state.parent.isTheorem(x)) _invalidProofStep();
    return _ordinaryProofStep(x, 'Applied rule "$carryOverRule');
  }

  Formula contrapositiveForward(DerivationLineContext context) {
    var formula = context.derivationLine;
    if (formula is! Implies) _invalidProofStep();
    return _rule(
        [context.top as Formula],
        context.substitute(
            Implies(Not(formula.rightOperand), Not(formula.leftOperand))),
        contrapositiveRule);
  }

  Formula contrapositiveReverse(DerivationLineContext context) {
    var formula = context.derivationLine;
    if (formula is! Implies) _invalidProofStep();
    var leftOperand = formula.leftOperand;
    if (leftOperand is! Not) _invalidProofStep();
    var rightOperand = formula.rightOperand;
    if (rightOperand is! Not) _invalidProofStep();
    return _rule(
        [context.top as Formula],
        context.substitute(Implies(rightOperand.operand, leftOperand.operand)),
        contrapositiveRule);
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
    return _rule([context.top as Formula], context.substitute(replacement),
        deMorgansRule);
  }

  Formula detach(Formula x) => x is Implies
      ? _rule([x.leftOperand, x], x.rightOperand, detachmentRule)
      : _invalidProofStep();

  DerivationLine getLine(int index) => _steps[index].line;

  Formula introduceDoubleTilde(DerivationLineContext context) => _rule(
      [context.top as Formula],
      context.substitute(Not(Not(context.derivationLine as Formula))),
      doubleTildeRule);

  bool isTheorem(Formula x) => _stack.isTheorem(x);

  Formula join(Formula x, Formula y) => _rule([x, y], And(x, y), joiningRule);

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
    return _rule([context.top as Formula], context.substitute(operand.operand),
        doubleTildeRule);
  }

  Formula separate(Formula x, Side side) => x is And
      ? _rule([x], x.getOperand(side), separationRule)
      : _invalidProofStep();

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
    return _rule([context.top as Formula], context.substitute(replacement),
        switcherooRule);
  }

  Never _invalidProofStep() => throw MathError();

  Formula _ordinaryProofStep(Formula theorem, String explanation) {
    _stack.addTheorem(theorem);
    _steps.add(_DerivationStep(theorem, explanation));
    return theorem;
  }

  Formula _popFantasyProofStep(_FantasyStackEntry innerState) {
    _stack = innerState.parent;
    var theorem = Implies(innerState.premise, innerState.conclusion);
    _steps.add(_DerivationStep(PopFantasy(), 'Applied rule "$popFantasyRule"'));
    return _ordinaryProofStep(theorem, 'Resulting new theorem');
  }

  Formula _pushFantasyProofStep(Formula premise) {
    _stack = _FantasyStackEntry(_stack)..addTheorem(premise);
    return premise;
  }

  Formula _rule(List<Formula> premises, Formula theorem, Rule rule) {
    for (var premise in premises) {
      if (!isTheorem(premise)) _invalidProofStep();
    }
    return _ordinaryProofStep(theorem, 'Applied rule "$rule"');
  }
}

class _DerivationStep {
  final DerivationLine line;

  final String explanation;

  _DerivationStep(this.line, this.explanation);
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
