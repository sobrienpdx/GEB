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

    test('remove double-tilde', () {
      var notNotP = Formula('~~P');
      checkValidStep([notNotP],
          (proof) => proof.removeDoubleTilde(FormulaContext(notNotP)), P);
      checkInvalidStep(
          [], (proof) => proof.removeDoubleTilde(FormulaContext(notNotP)));
      checkInvalidStep(
          [P], (proof) => proof.removeDoubleTilde(FormulaContext(P)));
      var notP = Formula('~P');
      checkInvalidStep(
          [notP], (proof) => proof.removeDoubleTilde(FormulaContext(notP)));
      var notNotPandQ = Formula('<~~P&Q>');
      checkValidStep(
          [notNotPandQ],
          (proof) =>
              proof.removeDoubleTilde(FormulaContext(notNotPandQ).leftOperand),
          Formula('<P&Q>'));
    });

    test('fantasy', () {
      checkValidStep([], (proof) {
        proof.pushFantasy(P)();
        return proof.popFantasy();
      }, Formula('<P->P>'));
      // ignore: non_constant_identifier_names
      var PandQ = And(P, Q);
      checkValidStep([], (proof) {
        proof.pushFantasy(PandQ)();
        proof.separate(PandQ, Side.left)();
        return proof.popFantasy();
      }, Formula('<<P&Q>->P>'));
      checkInvalidStep([], (proof) => proof.popFantasy());
    });

    test('carry-over', () {
      checkValidStep([P], (proof) {
        proof.pushFantasy(Q)();
        return proof.carryOver(P);
      }, P);
      checkInvalidStep([P], (proof) => proof.carryOver(P));
      checkInvalidStep([P], (proof) {
        proof.pushFantasy(Q)();
        return proof.carryOver(R);
      });
    });

    test('detach', () {
      // ignore: non_constant_identifier_names
      var PimpliesQ = Formula('<P->Q>');
      checkValidStep([P, PimpliesQ], (proof) => proof.detach(PimpliesQ), Q);
      checkInvalidStep([P], (proof) => proof.detach(PimpliesQ));
      checkInvalidStep([PimpliesQ], (proof) => proof.detach(PimpliesQ));
      // ignore: non_constant_identifier_names
      var PandQ = Formula('<P&Q>');
      checkInvalidStep([P, PandQ], (proof) => proof.detach(PandQ));
    });

    test('contrapositive forward', () {
      // ignore: non_constant_identifier_names
      var PimpliesQ = Formula('<P->Q>');
      checkValidStep(
          [PimpliesQ],
          (proof) => proof.contrapositiveForward(FormulaContext(PimpliesQ)),
          Formula('<~Q->~P>'));
      checkInvalidStep([],
          (proof) => proof.contrapositiveForward(FormulaContext(PimpliesQ)));
      var notPimpliesQ = Formula('~<P->Q>');
      checkValidStep(
          [notPimpliesQ],
          (proof) =>
              proof.contrapositiveForward(FormulaContext(notPimpliesQ).operand),
          Formula('~<~Q->~P>'));
    });

    test('contrapositive reverse', () {
      var notPimpliesNotQ = Formula('<~P->~Q>');
      checkValidStep(
          [notPimpliesNotQ],
          (proof) =>
              proof.contrapositiveReverse(FormulaContext(notPimpliesNotQ)),
          Formula('<Q->P>'));
      checkInvalidStep(
          [],
          (proof) =>
              proof.contrapositiveReverse(FormulaContext(notPimpliesNotQ)));
      var notPandNotQ = Formula('<~P&~Q>');
      checkInvalidStep([notPandNotQ],
          (proof) => proof.contrapositiveReverse(FormulaContext(notPandNotQ)));
      // ignore: non_constant_identifier_names
      var PimpliesNotQ = Formula('<P->~Q>');
      checkInvalidStep([PimpliesNotQ],
          (proof) => proof.contrapositiveReverse(FormulaContext(PimpliesNotQ)));
      var notPimpliesQ = Formula('<~P->Q>');
      checkInvalidStep([notPimpliesQ],
          (proof) => proof.contrapositiveReverse(FormulaContext(notPimpliesQ)));
    });
  });
}

final a = Variable('a');

final P = PropositionalAtom('P');

final Q = PropositionalAtom('Q');

final R = PropositionalAtom('R');

void checkInvalidStep(
    List<Formula> premises, ProofStep Function(Proof) action) {
  var proof = Proof();
  var proofStep = _prepareStep(proof, premises, action);
  expect(proofStep, TypeMatcher<InvalidProofStep>());
  expect(proofStep.isValid, false);
  expect(proofStep.call, throwsA(TypeMatcher<MathError>()));
}

void checkValidStep(List<Formula> premises, ProofStep Function(Proof) action,
    Formula expectedResult) {
  var proof = Proof();
  var proofStep = _prepareStep(proof, premises, action);
  expect(proofStep, TypeMatcher<ValidProofStep>());
  expect(proofStep.isValid, true);
  var result = proofStep();
  expect(result, expectedResult);
  expect(proof.isTheorem(result), true);
}

ProofStep _prepareStep(
    Proof proof, List<Formula> premises, ProofStep Function(Proof) action) {
  for (int i = 0; i < premises.length; i++) {
    proof.pushFantasy(premises[i])();
    for (int j = 0; j < i; j++) {
      proof.carryOver(premises[j])();
    }
  }
  return action(proof);
}
