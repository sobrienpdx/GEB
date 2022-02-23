import 'package:geb/math/ast.dart';
import 'package:geb/math/parse.dart';
import 'package:test/test.dart';

main() {
  group('propositional calculus', () {
    test('atom', () {
      expect(() => PropositionalAtom('O'), throwsA(TypeMatcher<MathError>()));
      expect(() => PropositionalAtom('S'), throwsA(TypeMatcher<MathError>()));
      expect(P.toString(), 'P');
      expect(Formula('P').toString(), 'P');
      expect(PropositionalAtom('P′').toString(), 'P′');
      expect(Formula('P′').toString(), 'P′');
      expect(Formula("P'").toString(), 'P′');
      expect(Formula('P′′').toString(), 'P′′');
      expect(Formula("P''").toString(), 'P′′');
      expect(Formula('P').containsFreeVariable(a), false);
      expectEqual(Formula('P'), Formula('P'), true);
      expectEqual(Formula('P'), Formula('Q'), false);
      expectEqual(Formula('P'), Formula("P'"), false);
      expectEqual(Formula('P'), Formula('0=0'), false);
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
      expectEqual(Formula('<P&Q>'), Formula('<P&Q>'), true);
      expectEqual(Formula('<P&Q>'), Formula('<P|Q>'), false);
      expectEqual(Formula('<P&Q>'), Formula('<R&Q>'), false);
      expectEqual(Formula('<P&Q>'), Formula('<P&R>'), false);
    });

    test('or', () {
      expect(Or(P, Q).toString(), '<P∨Q>');
      expect(Formula('<P∨Q>').toString(), '<P∨Q>');
      expect(Formula('<P|Q>').toString(), '<P∨Q>');
      expectEqual(Formula('<P|Q>'), Formula('<P|Q>'), true);
      expectEqual(Formula('<P|Q>'), Formula('<P->Q>'), false);
      expectEqual(Formula('<P|Q>'), Formula('<R|Q>'), false);
      expectEqual(Formula('<P|Q>'), Formula('<P|R>'), false);
    });

    test('implies', () {
      expect(Implies(P, Q).toString(), '<P⊃Q>');
      expect(Formula('<P⊃Q>').toString(), '<P⊃Q>');
      expect(Formula('<P->Q>').toString(), '<P⊃Q>');
      expectEqual(Formula('<P->Q>'), Formula('<P->Q>'), true);
      expectEqual(Formula('<P->Q>'), Formula('<P|Q>'), false);
      expectEqual(Formula('<P->Q>'), Formula('<R->Q>'), false);
      expectEqual(Formula('<P->Q>'), Formula('<P->R>'), false);
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
      expect(Zero().isDefinite, true);
      expect(Zero().containsVariable(a), false);
      expect(Zero().toString(), '0');
      expect(Term('0').toString(), '0');
      expect(Successor(Zero()).operand, TypeMatcher<Zero>());
      expect(Successor(Zero()).isDefinite, true);
      expect(Successor(Zero()).containsVariable(a), false);
      expect(Successor(Zero()).toString(), 'S0');
      expect(Term('S0').toString(), 'S0');
      expect(Term('SS0').toString(), 'SS0');
      expect(Term('SSS0').toString(), 'SSS0');
      expect(Term('SSSS0').toString(), 'SSSS0');
      expect(Term('SSSSS0').toString(), 'SSSSS0');
      expectEqual(Zero(), Zero(), true);
      expectEqual(Zero(), Successor(Zero()), false);
      expectEqual(Successor(Zero()), Zero(), false);
      expectEqual(Successor(Zero()), Successor(Zero()), true);
      expectEqual(Zero(), Term('a'), false);
      expectEqual(Successor(Zero()), Term('a'), false);
    });

    test('variable', () {
      expect(() => Variable('f'), throwsA(TypeMatcher<MathError>()));
      expect(a.toString(), 'a');
      expect(a.isDefinite, false);
      expect(Term('a').toString(), 'a');
      expect(Variable('a′').toString(), 'a′');
      expect(Term('a′').toString(), 'a′');
      expect(Term("a'").toString(), 'a′');
      expect(Term('a′′').toString(), 'a′′');
      expect(Term("a''").toString(), 'a′′');
      expect(Term('b′').toString(), 'b′');
      expect(Term('c′′').toString(), 'c′′');
      expect(Term('d′′′').toString(), 'd′′′');
      expect(Term('e′′′′').toString(), 'e′′′′');
      expect(Term('b').toString(), 'b');
      expectEqual(Term('a'), Term('a'), true);
      expectEqual(Term('a'), Term('b'), false);
      expectEqual(Term('a'), Term("a'"), false);
      expectEqual(Term('a'), Term('0'), false);
    });

    test('successor', () {
      expect(Successor(Zero()).isDefinite, true);
      expect(Successor(Successor(a)).operand, Successor(a));
      expect(Successor(a).operand, TypeMatcher<Variable>());
      expect(Successor(a).isDefinite, false);
      expect(Successor(a).containsVariable(a), true);
      expect(Successor(a).containsVariable(b), false);
      expect(Successor(a).toString(), 'Sa');
      expect(Successor(Successor(a)).toString(), 'SSa');
      expect(Term('Sa').toString(), 'Sa');
      expect(Term('SSa').toString(), 'SSa');
      expect(Term('SSa′').toString(), 'SSa′');
      expect(Term('S(Sa⋅(Sb⋅Sc))').toString(), 'S(Sa⋅(Sb⋅Sc))');
      expectEqual(Term('Sa'), Term('Sa'), true);
      expectEqual(Term('Sa'), Term('SSa'), false);
      expectEqual(Term('Sa'), Term('Sb'), false);
      expectEqual(Term('Sa'), Term('a'), false);
    });

    test('plus', () {
      expect(Plus(a, b).toString(), '(a+b)');
      expect(Plus(a, b).isDefinite, false);
      expect(Plus(zero, b).isDefinite, false);
      expect(Plus(a, one).isDefinite, false);
      expect(Plus(zero, one).isDefinite, true);
      expect(Plus(a, a).containsVariable(a), true);
      expect(Plus(a, b).containsVariable(a), true);
      expect(Plus(b, a).containsVariable(a), true);
      expect(Plus(b, b).containsVariable(a), false);
      expect(Term('(a+b)').toString(), '(a+b)');
      expectEqual(Term('(a+b)'), Term('(a+b)'), true);
      expectEqual(Term('(a+b)'), Term('(a*b)'), false);
      expectEqual(Term('(a+b)'), Term('(c+b)'), false);
      expectEqual(Term('(a+b)'), Term('(a+c)'), false);
    });

    test('times', () {
      expect(Times(a, b).toString(), '(a⋅b)');
      expect(Times(a, b).isDefinite, false);
      expect(Times(zero, b).isDefinite, false);
      expect(Times(a, one).isDefinite, false);
      expect(Times(zero, one).isDefinite, true);
      expect(Times(a, a).containsVariable(a), true);
      expect(Times(a, b).containsVariable(a), true);
      expect(Times(b, a).containsVariable(a), true);
      expect(Times(b, b).containsVariable(a), false);
      expect(Term('(a⋅b)').toString(), '(a⋅b)');
      expect(Term('(a*b)').toString(), '(a⋅b)');
      expect(Term('(S0⋅(SS0+c))').toString(), '(S0⋅(SS0+c))');
      expectEqual(Term('(a*b)'), Term('(a*b)'), true);
      expectEqual(Term('(a*b)'), Term('(a+b)'), false);
      expectEqual(Term('(a*b)'), Term('(c*b)'), false);
      expectEqual(Term('(a*b)'), Term('(a*c)'), false);
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
      expect(Equation(a, a).containsFreeVariable(a), true);
      expect(Equation(a, b).containsFreeVariable(a), true);
      expect(Equation(b, a).containsFreeVariable(a), true);
      expect(Equation(b, b).containsFreeVariable(a), false);
      expect(Formula('a=b').toString(), 'a=b');
      expect(Formula('S0=0').toString(), 'S0=0');
      expect(Formula('(SS0+SS0)=SSSS0').toString(), '(SS0+SS0)=SSSS0');
      expect(Formula('S(b+c)=((c⋅d)⋅e)').toString(), 'S(b+c)=((c⋅d)⋅e)');
      expectEqual(Formula('a=b'), Formula('a=b'), true);
      expectEqual(Formula('a=b'), Formula('c=b'), false);
      expectEqual(Formula('a=b'), Formula('a=c'), false);
      expectEqual(Formula('a=b'), Formula('P'), false);
    });

    test('free variables', () {
      var equation = Formula('S(b+c)=((c*d)*e)') as Equation;
      expect(equation.containsFreeVariable(a), false);
      expect(equation.containsFreeVariable(b), true);
      expect(equation.containsFreeVariable(c), true);
      expect(equation.containsFreeVariable(d), true);
      expect(equation.containsFreeVariable(e), true);
    });

    test('not', () {
      expect(Formula('~S0=0').toString(), '~S0=0');
      expect(Formula('~∃b:(b+b)=S0').toString(), '~∃b:(b+b)=S0');
      expect(Formula('~<0=0⊃S0=0>').toString(), '~<0=0⊃S0=0>');
      expect(Formula('~b=S0').toString(), '~b=S0');
      expect(Formula('~a=b').containsFreeVariable(a), true);
      expect(Formula('~a=b').containsFreeVariable(b), true);
      expect(Formula('~a=b').containsFreeVariable(c), false);
      expectEqual(Formula('~P'), Formula('~P'), true);
      expectEqual(Formula('~P'), Formula('~Q'), false);
      expectEqual(Formula('~P'), Formula('P'), false);
    });

    test('compounds', () {
      expect(Formula('<a=b&a=c>').containsFreeVariable(a), true);
      expect(Formula('<a=b&a=c>').containsFreeVariable(b), true);
      expect(Formula('<a=b&a=c>').containsFreeVariable(c), true);
      expect(Formula('<a=b&a=c>').containsFreeVariable(d), false);
      expect(Formula('<a=b|a=c>').containsFreeVariable(a), true);
      expect(Formula('<a=b|a=c>').containsFreeVariable(b), true);
      expect(Formula('<a=b|a=c>').containsFreeVariable(c), true);
      expect(Formula('<a=b|a=c>').containsFreeVariable(d), false);
      expect(Formula('<a=b->a=c>').containsFreeVariable(a), true);
      expect(Formula('<a=b->a=c>').containsFreeVariable(b), true);
      expect(Formula('<a=b->a=c>').containsFreeVariable(c), true);
      expect(Formula('<a=b->a=c>').containsFreeVariable(d), false);
      expect(Formula('<0=0∧~0=0>').toString(), '<0=0∧~0=0>');
      expect(Formula('<b=b∨~∃c:c=b>').toString(), '<b=b∨~∃c:c=b>');
      expect(
          Formula('<S0=0⊃∀c:~∃b:(b+b)=c>').toString(), '<S0=0⊃∀c:~∃b:(b+b)=c>');
    });

    test('forall', () {
      expect(() => Forall(a, Equation(zero, zero)),
          throwsA(TypeMatcher<MathError>()));
      var formulaQuantifyingA = Forall(a, Equation(a, b));
      expect(() => Forall(a, formulaQuantifyingA),
          throwsA(TypeMatcher<MathError>()));
      expect(Forall(a, Equation(a, b)).toString(), '∀a:a=b');
      expect(Formula('∀a:a=b').toString(), '∀a:a=b');
      expect(Formula('!a:a=b').toString(), '∀a:a=b');
      expect(Formula('∀a:a=b').containsFreeVariable(a), false);
      expect(Formula('∀a:a=b').containsFreeVariable(b), true);
      expect(Formula('∀a:a=b').containsFreeVariable(c), false);
      expectEqual(Formula('!a:a=b'), Formula('!a:a=b'), true);
      expectEqual(Formula('!a:a=b'), Formula('?a:a=b'), false);
      expectEqual(Formula('!a:a=b'), Formula('!b:a=b'), false);
      expectEqual(Formula('!a:a=b'), Formula('!a:b=a'), false);
    });

    test('exists', () {
      expect(() => Exists(a, Equation(zero, zero)),
          throwsA(TypeMatcher<MathError>()));
      var formulaQuantifyingA = Forall(a, Equation(a, b));
      expect(() => Exists(a, formulaQuantifyingA),
          throwsA(TypeMatcher<MathError>()));
      expect(Exists(a, Equation(a, b)).toString(), '∃a:a=b');
      expect(Formula('∃a:a=b').toString(), '∃a:a=b');
      expect(Formula('?a:a=b').toString(), '∃a:a=b');
      expect(Formula('∃a:a=b').containsFreeVariable(a), false);
      expect(Formula('∃a:a=b').containsFreeVariable(b), true);
      expect(Formula('∃a:a=b').containsFreeVariable(c), false);
      expectEqual(Formula('?a:a=b'), Formula('?a:a=b'), true);
      expectEqual(Formula('?a:a=b'), Formula('!a:a=b'), false);
      expectEqual(Formula('?a:a=b'), Formula('?b:a=b'), false);
      expectEqual(Formula('?a:a=b'), Formula('?a:b=a'), false);
    });

    test('quantifications', () {
      expect(Formula('∀b:<b=b∨~∃c:c=b>').toString(), '∀b:<b=b∨~∃c:c=b>');
      expect(Formula('∀c:~∃b:(b+b)=c').toString(), '∀c:~∃b:(b+b)=c');
      expect(Formula('∃c:Sc=d').toString(), '∃c:Sc=d');
    });

    test('isOpen', () {
      expect(Formula('~c=c').isOpen, true);
      expect(Formula('b=b').isOpen, true);
      expect(Formula('<!b:b=b&~c=c>').isOpen, true);
      expect(Formula('S0=0').isOpen, false);
      expect(Formula('~!d:d=0').isOpen, false);
      expect(Formula('?c:<!b:b=b&~c=c>').isOpen, false);
    });
  });
}

final a = Variable('a');

final b = Variable('b');

final c = Variable('c');

final d = Variable('d');

final e = Variable('e');

final one = Successor(Zero());

final P = PropositionalAtom('P');

final Q = PropositionalAtom('Q');

final zero = Zero();

void expectEqual(Object o1, Object o2, bool expectedResult) {
  expect(o1 == o2, expectedResult);
  if (expectedResult) {
    expect(o1.hashCode, o2.hashCode);
  }
}
