import 'package:geb/math/ast.dart';
import 'package:geb/math/context.dart';
import 'package:geb/math/proof.dart';

class Prover {
  final DerivationState _derivationState;

  Prover(this._derivationState);

  void prove(Formula goal) {
    if (goal is Implies) {
      var leftOperand = goal.leftOperand;
      var rightOperand = goal.rightOperand;
      if (leftOperand is Not) {
        var previousGoal = Or(leftOperand.operand, rightOperand);
        if (_derivationState.isTheorem(previousGoal)) {
          _derivationState.switcheroo(DerivationLineContext(previousGoal));
          return;
        }
      }
    }
    throw ProverFailed();
  }
}

class ProverFailed {}
