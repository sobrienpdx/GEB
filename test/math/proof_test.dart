import 'package:geb/math/ast.dart';
import 'package:geb/math/context.dart';
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

    test('introduce double-tilde', () {
      // ignore: non_constant_identifier_names
      var PandQ = And(P, Q);
      checkValidStep(
          [PandQ],
          (proof) => proof.introduceDoubleTilde(FormulaContext(PandQ)),
          Formula('~~<P&Q>'));
      checkInvalidStep(
          [], (proof) => proof.introduceDoubleTilde(FormulaContext(PandQ)));
      checkValidStep(
          [PandQ],
          (proof) =>
              proof.introduceDoubleTilde(FormulaContext(PandQ).leftOperand),
          Formula('<~~P&Q>'));
      checkValidStep(
          [PandQ],
          (proof) =>
              proof.introduceDoubleTilde(FormulaContext(PandQ).rightOperand),
          Formula('<P&~~Q>'));
      // ignore: non_constant_identifier_names
      var PorQ = Or(P, Q);
      checkValidStep(
          [PorQ],
          (proof) =>
              proof.introduceDoubleTilde(FormulaContext(PorQ).leftOperand),
          Formula('<~~P|Q>'));
      checkValidStep(
          [PorQ],
          (proof) =>
              proof.introduceDoubleTilde(FormulaContext(PorQ).rightOperand),
          Formula('<P|~~Q>'));
      // ignore: non_constant_identifier_names
      var PimpliesQ = Implies(P, Q);
      checkValidStep(
          [PimpliesQ],
          (proof) =>
              proof.introduceDoubleTilde(FormulaContext(PimpliesQ).leftOperand),
          Formula('<~~P->Q>'));
      checkValidStep(
          [PimpliesQ],
          (proof) => proof
              .introduceDoubleTilde(FormulaContext(PimpliesQ).rightOperand),
          Formula('<P->~~Q>'));
      var notP = Not(P);
      checkValidStep(
          [notP],
          (proof) => proof.introduceDoubleTilde(FormulaContext(notP).operand),
          Formula('~~~P'));
      var forall = Forall(a, Equation(a, a));
      checkValidStep(
          [forall],
          (proof) => proof.introduceDoubleTilde(FormulaContext(forall).operand),
          Formula('!a:~~a=a'));
      var exists = Exists(a, Equation(a, a));
      checkValidStep(
          [exists],
          (proof) => proof.introduceDoubleTilde(FormulaContext(exists).operand),
          Formula('?a:~~a=a'));
    });
  });
}

final a = Variable('a');

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
