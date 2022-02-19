import 'package:geb/math/ast.dart';
import 'package:geb/math/parse.dart';
import 'package:test/test.dart';

main() {
  group('propositional calculus', () {
    test('atom', () {
      expect(P.toString(), 'P');
      expect(Formula('P').toString(), 'P');
      expect(PropositionalAtom('P′').toString(), 'P′');
      expect(Formula('P′').toString(), 'P′');
      expect(Formula("P'").toString(), 'P′');
      expect(Formula('P′′').toString(), 'P′′');
      expect(Formula("P''").toString(), 'P′′');
    });

    test('not', () {
      expect(Not(P).toString(), '~P');
      expect(Formula('~P').toString(), '~P');
      expect(Formula('~~P').toString(), '~~P');
    });

    test('and', () {
      expect(And(P, Q).toString(), '<P∧Q>');
      expect(Formula('<P∧Q>').toString(), '<P∧Q>');
      expect(Formula('<P&Q>').toString(), '<P∧Q>');
    });

    test('or', () {
      expect(Or(P, Q).toString(), '<P∨Q>');
      expect(Formula('<P∨Q>').toString(), '<P∨Q>');
      expect(Formula('<P|Q>').toString(), '<P∨Q>');
    });

    test('implies', () {
      expect(Implies(P, Q).toString(), '<P⊃Q>');
      expect(Formula('<P⊃Q>').toString(), '<P⊃Q>');
      expect(Formula('<P->Q>').toString(), '<P⊃Q>');
    });

    test('complex parsing', () {
      expect(Formula('<P∧Q>').toString(), '<P∧Q>');
      expect(Formula('<P∧~P>').toString(), '<P∧~P>');
      expect(
          Formula('<<P∨<Q⊃R>>∧<~P∨~R′>>').toString(), '<<P∨<Q⊃R>>∧<~P∨~R′>>');
    });

    test('parse errors', () {
      expect(() => Formula('<P>'), throwsA(TypeMatcher<ParseError>()));
      expect(() => Formula('<~P>'), throwsA(TypeMatcher<ParseError>()));
      expect(() => Formula('<P∧Q∧R>'), throwsA(TypeMatcher<ParseError>()));
      expect(
          () => Formula('<<P∧Q>∧<Q~∧P>>'), throwsA(TypeMatcher<ParseError>()));
      expect(() => Formula('<P∧Q>∧<Q∧P>'), throwsA(TypeMatcher<ParseError>()));
    });
  });

  group('TNT', () {
    test('numeral', () {
      expect(Numeral(0), TypeMatcher<Zero>());
      expect(Numeral(0).value, 0);
      expect(Numeral(0).isDefinite, true);
      expect(Numeral(0).toString(), '0');
      expect(Term('0').toString(), '0');
      expect(Numeral(1), TypeMatcher<NonzeroNumeral>());
      expect(Numeral(1).value, 1);
      expect((Numeral(1) as Successor).operand, TypeMatcher<Zero>());
      expect((Numeral(1) as Successor).successorCount, 1);
      expect(Numeral(1).isDefinite, true);
      expect(Numeral(1).toString(), 'S0');
      expect(Term('S0').toString(), 'S0');
      expect(Numeral(2), TypeMatcher<NonzeroNumeral>());
      expect(Numeral(2).value, 2);
      expect((Numeral(2) as Successor).operand, TypeMatcher<Zero>());
      expect((Numeral(2) as Successor).successorCount, 2);
      expect(Numeral(2).isDefinite, true);
      expect(Numeral(2).toString(), 'SS0');
      expect(Term('SS0').toString(), 'SS0');
    });

    test('variable', () {
      expect(a.toString(), 'a');
      expect(a.isDefinite, false);
      expect(Term('a').toString(), 'a');
      expect(Variable('a′').toString(), 'a′');
      expect(Term('a′').toString(), 'a′');
      expect(Term("a'").toString(), 'a′');
      expect(Term('a′′').toString(), 'a′′');
      expect(Term("a''").toString(), 'a′′');
    });

    test('successor', () {
      expect(Successor.apply(0, Zero()), TypeMatcher<Zero>());
      expect(Successor.apply(1, Zero()), TypeMatcher<Numeral>());
      expect((Successor.apply(1, Zero()) as Numeral).value, 1);
      expect(Successor.apply(1, Zero()).isDefinite, true);
      expect(Successor.apply(1, Numeral(1)), TypeMatcher<Numeral>());
      expect((Successor.apply(1, Numeral(1)) as Numeral).value, 2);
      expect((Successor.apply(1, Successor.apply(1, a))),
          TypeMatcher<Successor>());
      expect(
          (Successor.apply(1, Successor.apply(1, a)) as Successor)
              .successorCount,
          2);
      expect((Successor.apply(1, Successor.apply(1, a)) as Successor).operand,
          TypeMatcher<Variable>());
      expect((Successor.apply(1, a) as Successor).operand,
          TypeMatcher<Variable>());
      expect((Successor.apply(1, a) as Successor).successorCount, 1);
      expect(Successor.apply(1, a).isDefinite, false);
      expect(Successor.apply(1, a).toString(), 'Sa');
      expect(Successor.apply(2, a).toString(), 'SSa');
      expect(Term('Sa').toString(), 'Sa');
      expect(Term('SSa').toString(), 'SSa');
    });

    test('plus', () {
      expect(Plus(a, b).toString(), '(a+b)');
      expect(Plus(a, b).isDefinite, false);
      expect(Plus(zero, b).isDefinite, false);
      expect(Plus(a, one).isDefinite, false);
      expect(Plus(zero, one).isDefinite, true);
      expect(Term('(a+b)').toString(), '(a+b)');
    });

    test('times', () {
      expect(Times(a, b).toString(), '(a⋅b)');
      expect(Times(a, b).isDefinite, false);
      expect(Times(zero, b).isDefinite, false);
      expect(Times(a, one).isDefinite, false);
      expect(Times(zero, one).isDefinite, true);
      expect(Term('(a⋅b)').toString(), '(a⋅b)');
      expect(Term('(a*b)').toString(), '(a⋅b)');
    });

    test('definiteness', () {
      expect(Term('0').isDefinite, true);
      expect(Term('(S0+S0)').isDefinite, true);
      expect(Term('SS((SS0*SS0)+(S0*S0))').isDefinite, true);
      expect(Term('b').isDefinite, false);
      expect(Term('Sa').isDefinite, false);
      expect(Term('(b+S0)').isDefinite, false);
      expect(Term('(((S0+S0)+S0)+e)').isDefinite, false);
    });

    test('equation', () {
      expect(Equation(a, b).toString(), 'a=b');
      expect(Formula('a=b').toString(), 'a=b');
    });
  });
}

final a = Variable('a');

final b = Variable('b');

final one = Numeral(1);

final P = PropositionalAtom('P');

final Q = PropositionalAtom('Q');

final zero = Zero();
