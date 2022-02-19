import 'package:geb/math/ast.dart';
import 'package:geb/math/parse.dart';
import 'package:test/test.dart';

main() {
  test('propositional atom', () {
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
    expect(Formula('<<P∨<Q⊃R>>∧<~P∨~R′>>').toString(), '<<P∨<Q⊃R>>∧<~P∨~R′>>');
  });

  test('parse errors', () {
    expect(() => Formula('<P>'), throwsA(TypeMatcher<ParseError>()));
    expect(() => Formula('<~P>'), throwsA(TypeMatcher<ParseError>()));
    expect(() => Formula('<P∧Q∧R>'), throwsA(TypeMatcher<ParseError>()));
    expect(() => Formula('<<P∧Q>∧<Q~∧P>>'), throwsA(TypeMatcher<ParseError>()));
    expect(() => Formula('<P∧Q>∧<Q∧P>'), throwsA(TypeMatcher<ParseError>()));
  });
}

final P = PropositionalAtom('P');

final Q = PropositionalAtom('Q');
