import 'ast.dart';
import 'context.dart';
import 'rule_definitions.dart';
import 'rules.dart';

class DerivationState {
  final List<_DerivationStep> _steps = [];

  DerivationState();

  List<String> get explanations => [for (var step in _steps) step.explanation];

  bool get isFantasyInProgress => _findFantasyStart(lastNonPopIndex) >= 0;

  int get lastNonPopIndex {
    var index = _steps.length - 1;
    if (index >= 0) {
      var step = _steps[index];
      if (step.line is PopFantasy) {
        index = _findFantasyStart(step.previousIndex);
        if (index >= 0) index--;
      }
    }
    return index;
  }

  /// TODO(paul): probably most callers of this are misusing it--it doesn't
  /// filter down to just the accessible theorems.
  List<DerivationLine> get lines => [for (var step in _steps) step.line];

  void addLine(DerivationLine line, {String? explanation}) {
    if (line is Formula) {
      explanation ??= 'User supplied premise';
    } else if (line is PushFantasy) {
      explanation ??= 'Applied rule "push fantasy"';
    } else if (line is PopFantasy) {
      explanation ??= 'Applied rule "$popFantasyRule"';
    } else {
      throw StateError(
          'Unrecognized kind of derivation line: ${line.runtimeType}');
    }
    _steps.add(_DerivationStep(line, explanation, lastNonPopIndex));
  }

  Formula carryOver(Formula x) {
    int startingIndex = _popFantasyIndex(lastNonPopIndex);
    if (startingIndex < 0 || !isTheorem(x, startingIndex: startingIndex)) {
      _invalidProofStep();
    }
    return _ordinaryProofStep(x, 'Applied rule "$carryOverRule"');
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

  List<bool> getAvailableFlags({bool carryOver = false}) {
    var result = List<bool>.filled(_steps.length, false);
    var index = lastNonPopIndex;
    if (carryOver) {
      index = _popFantasyIndex(index);
    }
    while (index >= 0) {
      var step = _steps[index];
      var line = step.line;
      if (line is PushFantasy) {
        break;
      } else if (line is Formula) {
        result[index] = true;
      }
      index = step.previousIndex;
    }
    return result;
  }

  DerivationLine getLine(int index) => _steps[index].line;

  Formula introduceDoubleTilde(DerivationLineContext context) => _rule(
      [context.top as Formula],
      context.substitute(Not(Not(context.derivationLine as Formula))),
      doubleTildeRule);

  bool isGoalSatisfied(Formula goal) {
    var index = lastNonPopIndex;
    while (true) {
      var fantasyStart = _findFantasyStart(index);
      if (fantasyStart >= 0) {
        index = fantasyStart - 1;
      } else {
        break;
      }
    }
    while (index >= 0) {
      var step = _steps[index];
      if (step.line == goal) return true;
      index = step.previousIndex;
    }
    return false;
  }

  bool isTheorem(Formula x, {int? startingIndex}) {
    var index = startingIndex ?? lastNonPopIndex;
    while (index >= 0) {
      var step = _steps[index];
      var line = step.line;
      if (line is PushFantasy) return false;
      if (line == x) return true;
      index = step.previousIndex;
    }
    return false;
  }

  Formula join(Formula x, Formula y) => _rule([x, y], And(x, y), joiningRule);

  Formula popFantasy() {
    var fantasyStart = _findFantasyStart(lastNonPopIndex);
    if (fantasyStart < 0 || fantasyStart + 1 >= _steps.length) {
      _invalidProofStep();
    }
    return _popFantasyProofStep(fantasyStart);
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

  String undo() {
    if (_steps.isEmpty) return 'Nothing to undo!';
    _steps.removeLast();
    if (_steps.isEmpty) return '';
    var lastStep = _steps.last;
    if (lastStep.line is PushFantasy || lastStep.line is PopFantasy) {
      _steps.removeLast();
    }
    return '';
  }

  int _findFantasyStart(int index) {
    while (index >= 0) {
      var step = _steps[index];
      if (step.line is PushFantasy) break;
      index = step.previousIndex;
    }
    return index;
  }

  Never _invalidProofStep() => throw MathError();

  Formula _ordinaryProofStep(Formula theorem, String explanation) {
    _steps.add(_DerivationStep(theorem, explanation, lastNonPopIndex));
    return theorem;
  }

  int _popFantasyIndex(int index) {
    var startingIndex = _findFantasyStart(index);
    if (startingIndex >= 0) startingIndex--;
    return startingIndex;
  }

  Formula _popFantasyProofStep(int fantasyStart) {
    var premise = _steps[fantasyStart + 1].line;
    if (premise is! Formula) _invalidProofStep();
    var conclusion = _steps.last.line;
    if (conclusion is! Formula) _invalidProofStep();
    var theorem = Implies(premise, conclusion);
    _steps.add(_DerivationStep(
        PopFantasy(), 'Applied rule "$popFantasyRule"', lastNonPopIndex));
    _steps.add(
        _DerivationStep(theorem, 'Resulting new theorem', fantasyStart - 1));
    return theorem;
  }

  Formula _pushFantasyProofStep(Formula premise) {
    _steps.add(_DerivationStep(
        PushFantasy(), 'Applied rule "push fantasy"', lastNonPopIndex));
    _steps.add(
        _DerivationStep(premise, 'User supplied premise', lastNonPopIndex));
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

  final int previousIndex;

  _DerivationStep(this.line, this.explanation, this.previousIndex);
}
