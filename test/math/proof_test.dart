import 'package:geb/math/ast.dart';
import 'package:geb/math/proof.dart';
import 'package:test/test.dart';

main() {
  group('propositional calculus', () {
    test('join', () {
      checkValidStep([P, Q], (proof) => proof.join(P, Q), Formula('<P&Q>'));
      checkInvalidStep([R, Q], (proof) => proof.join(P, Q));
      checkInvalidStep([P, R], (proof) => proof.join(P, Q));
    });

    test('separate', () {
      var premise = And(P, Q);
      checkValidStep(
          [premise], (proof) => proof.separate(premise, Side.left), P);
      checkInvalidStep([], (proof) => proof.separate(premise, Side.left));
      checkValidStep(
          [premise], (proof) => proof.separate(premise, Side.right), Q);
      checkInvalidStep([], (proof) => proof.separate(premise, Side.right));
    });
  });
}

final P = PropositionalAtom('P');

final Q = PropositionalAtom('Q');

final R = PropositionalAtom('R');

void checkInvalidStep(
    List<Formula> premises, Formula Function(Proof) proofStep) {
  var proof = Proof();
  for (var premise in premises) {
    proof.pushFantasy(premise);
  }
  expect(() => proofStep(proof), throwsA(TypeMatcher<MathError>()));
}

void checkValidStep(List<Formula> premises, Formula Function(Proof) proofStep,
    Formula expectedResult) {
  var proof = Proof();
  for (var premise in premises) {
    proof.pushFantasy(premise);
  }
  var result = proofStep(proof);
  expect(result, expectedResult);
  expect(proof.isTheorem(result), true);
}
