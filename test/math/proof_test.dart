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
          (proof) => proof.introduceDoubleTilde(DerivationLineContext(PandQ)),
          Formula('~~<P&Q>'));
      checkInvalidStep([],
          (proof) => proof.introduceDoubleTilde(DerivationLineContext(PandQ)));
      checkValidStep(
          [PandQ],
          (proof) => proof
              .introduceDoubleTilde(DerivationLineContext(PandQ).leftOperand),
          Formula('<~~P&Q>'));
      checkValidStep(
          [PandQ],
          (proof) => proof
              .introduceDoubleTilde(DerivationLineContext(PandQ).rightOperand),
          Formula('<P&~~Q>'));
      // ignore: non_constant_identifier_names
      var PorQ = Or(P, Q);
      checkValidStep(
          [PorQ],
          (proof) => proof
              .introduceDoubleTilde(DerivationLineContext(PorQ).leftOperand),
          Formula('<~~P|Q>'));
      checkValidStep(
          [PorQ],
          (proof) => proof
              .introduceDoubleTilde(DerivationLineContext(PorQ).rightOperand),
          Formula('<P|~~Q>'));
      // ignore: non_constant_identifier_names
      var PimpliesQ = Implies(P, Q);
      checkValidStep(
          [PimpliesQ],
          (proof) => proof.introduceDoubleTilde(
              DerivationLineContext(PimpliesQ).leftOperand),
          Formula('<~~P->Q>'));
      checkValidStep(
          [PimpliesQ],
          (proof) => proof.introduceDoubleTilde(
              DerivationLineContext(PimpliesQ).rightOperand),
          Formula('<P->~~Q>'));
      var notP = Not(P);
      checkValidStep(
          [notP],
          (proof) =>
              proof.introduceDoubleTilde(DerivationLineContext(notP).operand),
          Formula('~~~P'));
      var forall = Forall(a, Equation(a, a));
      checkValidStep(
          [forall],
          (proof) =>
              proof.introduceDoubleTilde(DerivationLineContext(forall).operand),
          Formula('!a:~~a=a'));
      var exists = Exists(a, Equation(a, a));
      checkValidStep(
          [exists],
          (proof) =>
              proof.introduceDoubleTilde(DerivationLineContext(exists).operand),
          Formula('?a:~~a=a'));
    });

    test('remove double-tilde', () {
      var notNotP = Formula('~~P');
      checkValidStep(
          [notNotP],
          (proof) => proof.removeDoubleTilde(DerivationLineContext(notNotP)),
          P);
      checkInvalidStep([],
          (proof) => proof.removeDoubleTilde(DerivationLineContext(notNotP)));
      checkInvalidStep(
          [P], (proof) => proof.removeDoubleTilde(DerivationLineContext(P)));
      var notP = Formula('~P');
      checkInvalidStep([notP],
          (proof) => proof.removeDoubleTilde(DerivationLineContext(notP)));
      var notNotPandQ = Formula('<~~P&Q>');
      checkValidStep(
          [notNotPandQ],
          (proof) => proof.removeDoubleTilde(
              DerivationLineContext(notNotPandQ).leftOperand),
          Formula('<P&Q>'));
    });

    test('fantasy', () {
      checkValidStep([], (proof) {
        proof.pushFantasy(P);
        return proof.popFantasy();
      }, Formula('<P->P>'));
      // ignore: non_constant_identifier_names
      var PandQ = And(P, Q);
      checkValidStep([], (proof) {
        proof.pushFantasy(PandQ);
        proof.separate(PandQ, Side.left);
        return proof.popFantasy();
      }, Formula('<<P&Q>->P>'));
      checkInvalidStep([], (proof) => proof.popFantasy());
    });

    test('carry-over', () {
      checkValidStep([P], (proof) {
        proof.pushFantasy(Q);
        return proof.carryOver(P);
      }, P);
      checkInvalidStep([P], (proof) => proof.carryOver(P));
      checkInvalidStep([P], (proof) {
        proof.pushFantasy(Q);
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
          (proof) => proof.contrapositiveForward(PimpliesQ),
          Formula('<~Q->~P>'));
      checkInvalidStep([], (proof) => proof.contrapositiveForward(PimpliesQ));
    });

    test('contrapositive reverse', () {
      var notPimpliesNotQ = Formula('<~P->~Q>');
      checkValidStep(
          [notPimpliesNotQ],
          (proof) => proof.contrapositiveReverse(notPimpliesNotQ),
          Formula('<Q->P>'));
      checkInvalidStep(
          [], (proof) => proof.contrapositiveReverse(notPimpliesNotQ));
      var notPandNotQ = Formula('<~P&~Q>');
      checkInvalidStep(
          [notPandNotQ], (proof) => proof.contrapositiveReverse(notPandNotQ));
      // ignore: non_constant_identifier_names
      var PimpliesNotQ = Formula('<P->~Q>');
      checkInvalidStep(
          [PimpliesNotQ], (proof) => proof.contrapositiveReverse(PimpliesNotQ));
      var notPimpliesQ = Formula('<~P->Q>');
      checkInvalidStep(
          [notPimpliesQ], (proof) => proof.contrapositiveReverse(notPimpliesQ));
    });

    test('de morgan', () {
      var notPandNotQ = Formula('<~P&~Q>');
      // ignore: non_constant_identifier_names
      var not_PorQ = Formula('~<P|Q>');
      checkValidStep(
          [notPandNotQ], (proof) => proof.deMorgan(notPandNotQ), not_PorQ);
      checkInvalidStep([], (proof) => proof.deMorgan(notPandNotQ));
      // ignore: non_constant_identifier_names
      var PandNotQ = Formula('<P&~Q>');
      checkInvalidStep([PandNotQ], (proof) => proof.deMorgan(PandNotQ));
      var notPandQ = Formula('<~P&Q>');
      checkInvalidStep([notPandQ], (proof) => proof.deMorgan(notPandQ));
      checkValidStep(
          [not_PorQ], (proof) => proof.deMorgan(not_PorQ), notPandNotQ);
      checkInvalidStep([], (proof) => proof.deMorgan(not_PorQ));
      // ignore: non_constant_identifier_names
      var not_PandQ = Formula('~<P&Q>');
      checkInvalidStep([not_PandQ], (proof) => proof.deMorgan(not_PandQ));
    });

    test('Switcheroo', () {
      // ignore: non_constant_identifier_names
      var PorQ = Formula('<P|Q>');
      var notPimpliesQ = Formula('<~P->Q>');
      checkValidStep([PorQ], (proof) => proof.switcheroo(PorQ), notPimpliesQ);
      checkInvalidStep([], (proof) => proof.switcheroo(PorQ));
      // ignore: non_constant_identifier_names
      var PandQ = Formula('<P&Q>');
      checkInvalidStep([PandQ], (proof) => proof.switcheroo(PandQ));
      checkValidStep(
          [notPimpliesQ], (proof) => proof.switcheroo(notPimpliesQ), PorQ);
      checkInvalidStep([], (proof) => proof.switcheroo(notPimpliesQ));
      // ignore: non_constant_identifier_names
      var PimpliesQ = Formula('<P->Q>');
      checkInvalidStep([PimpliesQ], (proof) => proof.switcheroo(PimpliesQ));
    });

    test("Ganto's Ax", () {
      var proof = DerivationState();
      var step2 = proof.pushFantasy(Formula('<<P->Q>&<~P->Q>>'));
      var step3 = proof.separate(step2, Side.left);
      expect(step3, Formula('<P->Q>'));
      var step4 = proof.contrapositiveForward(step3);
      var step5 = proof.separate(step2, Side.right);
      var step6 = proof.contrapositiveForward(step5);
      var step8 = proof.pushFantasy(Formula('~Q'));
      expect(step8, Formula('~Q'));
      var step9 = proof.carryOver(step4);
      var step10 = proof.detach(step9);
      var step11 = proof.carryOver(step6);
      var step12 = proof.detach(step11);
      var step13 = proof.join(step10, step12);
      var step14 = proof.deMorgan(step13);
      expect(step14, Formula('~<P|~P>'));
      var step16 = proof.popFantasy();
      var step17 = proof.contrapositiveReverse(step16);
      var step19 = proof.pushFantasy(Formula('~P'));
      expect(step19, Formula('~P'));
      var step21 = proof.popFantasy();
      var step22 = proof.switcheroo(step21);
      expect(step22, Formula('<P|~P>'));
      var step23 = proof.detach(step17);
      expect(step23, Formula('Q'));
    });
  });

  group('isGoalSatisfied', () {
    test('Empty derivation', () {
      var derivation = _makeDerivation([]);
      expect(derivation.isGoalSatisfied(Formula('P')), false);
      expect(derivation.isGoalSatisfied(Formula('Q')), false);
      expect(derivation.isGoalSatisfied(Formula('<Q->Q>')), false);
    });

    test('Success', () {
      var derivation = _makeDerivation(['P']);
      expect(derivation.isGoalSatisfied(Formula('P')), true);
      expect(derivation.isGoalSatisfied(Formula('Q')), false);
      expect(derivation.isGoalSatisfied(Formula('<Q->Q>')), false);
    });

    test('Inside fantasy, no premise yet', () {
      var derivation = _makeDerivation(['P', '[']);
      expect(derivation.isGoalSatisfied(Formula('P')), false);
      expect(derivation.isGoalSatisfied(Formula('Q')), false);
      expect(derivation.isGoalSatisfied(Formula('<Q->Q>')), false);
    });

    test('Inside fantasy, after premise', () {
      var derivation = _makeDerivation(['P', '[', 'Q']);
      expect(derivation.isGoalSatisfied(Formula('P')), false);
      expect(derivation.isGoalSatisfied(Formula('Q')), false);
      expect(derivation.isGoalSatisfied(Formula('<Q->Q>')), false);
    });

    test('Inside fantasy, after nested fantasy', () {
      var derivation = _makeDerivation(['P', '[', 'Q', '[']);
      expect(derivation.isGoalSatisfied(Formula('P')), false);
      expect(derivation.isGoalSatisfied(Formula('Q')), false);
      expect(derivation.isGoalSatisfied(Formula('<Q->Q>')), false);
    });

    test('Inside fantasy, after nested fantasy and premise', () {
      var derivation = _makeDerivation(['P', '[', 'Q', '[']);
      expect(derivation.isGoalSatisfied(Formula('P')), false);
      expect(derivation.isGoalSatisfied(Formula('Q')), false);
      expect(derivation.isGoalSatisfied(Formula('<Q->Q>')), false);
    });

    test('After pop but no conclusion', () {
      var derivation = _makeDerivation(['P', '[', 'Q', ']']);
      expect(derivation.isGoalSatisfied(Formula('P')), false);
      expect(derivation.isGoalSatisfied(Formula('Q')), false);
      expect(derivation.isGoalSatisfied(Formula('<Q->Q>')), false);
    });

    test('After pop and conclusion', () {
      var derivation = _makeDerivation(['P', '[', 'Q', ']', '<Q->Q>']);
      expect(derivation.isGoalSatisfied(Formula('P')), false);
      expect(derivation.isGoalSatisfied(Formula('Q')), false);
      expect(derivation.isGoalSatisfied(Formula('<Q->Q>')), true);
    });
  });
}

final a = Variable('a');

final P = PropositionalAtom('P');

final Q = PropositionalAtom('Q');

final R = PropositionalAtom('R');

void checkInvalidStep(
    List<Formula> premises, Formula Function(DerivationState) action) {
  var proof = DerivationState();
  _prepareStep(proof, premises);
  expect(() => action(proof), throwsA(TypeMatcher<MathError>()));
}

void checkValidStep(List<Formula> premises,
    Formula Function(DerivationState) action, Formula expectedResult) {
  var proof = DerivationState();
  _prepareStep(proof, premises);
  var result = action(proof);
  expect(result, expectedResult);
  expect(proof.isTheorem(result), true);
}

DerivationState _makeDerivation(List<String> lines) {
  var derivation = DerivationState();
  for (var line in lines) {
    derivation.addLine(DerivationLine(line));
  }
  return derivation;
}

void _prepareStep(DerivationState proof, List<Formula> premises) {
  for (int i = 0; i < premises.length; i++) {
    proof.pushFantasy(premises[i]);
    for (int j = 0; j < i; j++) {
      proof.carryOver(premises[j]);
    }
  }
}
