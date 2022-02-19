import 'package:geb/math/ast.dart';
import 'package:geb/math/proof.dart';
import 'package:test/test.dart';

main() {
  group('propositional calculus', () {
    test('join', () {
      checkProofStep([P, Q], (proof) => proof.join(P, Q), Formula('<P&Q>'),
          isValid: true);
      checkProofStep([R, Q], (proof) => proof.join(P, Q), Formula('<P&Q>'),
          isValid: false);
      checkProofStep([P, R], (proof) => proof.join(P, Q), Formula('<P&Q>'),
          isValid: false);
    });
  });
}

final P = PropositionalAtom('P');

final Q = PropositionalAtom('Q');

final R = PropositionalAtom('R');

void checkProofStep(List<PropositionalAtom> suppositions,
    Formula Function(Proof) proofStep, Formula expectedResult,
    {required bool isValid}) {
  var proof = Proof();
  for (var supposition in suppositions) {
    proof.pushFantasy(supposition);
  }
  if (isValid) {
    var result = proofStep(proof);
    expect(result, expectedResult);
    expect(proof.isTheorem(result), true);
  } else {
    expect(() => proofStep(proof), throwsA(TypeMatcher<MathError>()));
  }
}
