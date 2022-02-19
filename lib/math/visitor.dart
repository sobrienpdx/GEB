import 'ast.dart';

abstract class FormulaVisitor<T> {
  T visitAnd(And node);
  T visitEquation(Equation node);
  T visitExists(Exists node);
  T visitForall(Forall node);
  T visitImplies(Implies node);
  T visitNot(Not node);
  T visitOr(Or node);
  T visitPropositionalAtom(PropositionalAtom node);
}

abstract class TermVisitor<T> {
  T visitNonzeroNumeral(NonzeroNumeral node);
  T visitPlus(Plus node);
  T visitSuccessor(Successor node);
  T visitTimes(Times node);
  T visitVariable(Variable node);
  T visitZero(Zero node);
}

abstract class Visitor<T> implements FormulaVisitor<T>, TermVisitor<T> {}
