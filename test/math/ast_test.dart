import 'package:geb/math/ast.dart';
import 'package:test/test.dart';

main() {
  group('Pretty print', () {
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
    });

    test('implies', () {
      expect(Implies(P, Q).toString(), '<P⊃Q>');
    });
  });
}

final P = PropositionalAtom('P');

final Q = PropositionalAtom('Q');
