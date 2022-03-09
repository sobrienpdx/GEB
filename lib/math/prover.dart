import 'package:geb/math/ast.dart';
import 'package:geb/math/proof.dart';

class ProofSketchFrame {
  final Set<Formula> availableTheorems = {};
  final Set<Formula> usedTheorems = {};
  final List<void Function(DerivationState)> steps = [];
}

class Prover {
  ProofSketchFrame _frame = ProofSketchFrame();

  Prover(Iterable<Formula> initialLines) {
    _frame.availableTheorems.addAll(initialLines);
  }

  void execute(DerivationState derivationState) {
    for (var step in _frame.steps) {
      step(derivationState);
    }
  }

  void prove(Formula goal) {
    if (goal is Implies) {
      var leftOperand = goal.leftOperand;
      var rightOperand = goal.rightOperand;
      if (leftOperand is Not) {
        var previousGoal = Or(leftOperand.operand, rightOperand);
        if (_frame.availableTheorems.contains(previousGoal)) {
          _frame.usedTheorems.add(previousGoal);
          _frame.steps.add((derivationState) {
            derivationState.switcheroo(previousGoal);
          });
          _frame.availableTheorems.add(goal);
          return;
        }
      }
    }
    throw ProverFailed();
  }
}

class ProverFailed {}
