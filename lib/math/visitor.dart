import 'ast.dart';

class AnyVisitor implements Visitor<bool> {
  const AnyVisitor();

  @override
  bool visitAnd(And node) =>
      node.leftOperand.accept(this) || node.rightOperand.accept(this);

  @override
  bool visitEquation(Equation node) =>
      node.leftSide.accept(this) || node.rightSide.accept(this);

  @override
  bool visitExists(Exists node) => node.operand.accept(this);

  @override
  bool visitForall(Forall node) => node.operand.accept(this);

  @override
  bool visitImplies(Implies node) =>
      node.leftOperand.accept(this) || node.rightOperand.accept(this);

  @override
  bool visitNot(Not node) => node.operand.accept(this);

  @override
  bool visitOr(Or node) =>
      node.leftOperand.accept(this) || node.rightOperand.accept(this);

  @override
  bool visitPlus(Plus node) =>
      node.leftOperand.accept(this) || node.rightOperand.accept(this);

  @override
  bool visitPopFantasy(PopFantasy node) => false;

  @override
  bool visitPropositionalAtom(PropositionalAtom node) => false;

  @override
  bool visitPushFantasy(PushFantasy node) => false;

  @override
  bool visitSuccessor(Successor node) => node.operand.accept(this);

  @override
  bool visitTimes(Times node) =>
      node.leftOperand.accept(this) || node.rightOperand.accept(this);

  @override
  bool visitVariable(Variable node) => false;

  @override
  bool visitZero(Zero node) => false;
}

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

abstract class ProofLineVisitor<T> implements FormulaVisitor<T> {
  T visitPopFantasy(PopFantasy node);
  T visitPushFantasy(PushFantasy node);
}

abstract class TermVisitor<T> {
  T visitPlus(Plus node);
  T visitSuccessor(Successor node);
  T visitTimes(Times node);
  T visitVariable(Variable node);
  T visitZero(Zero node);
}

abstract class Visitor<T> implements ProofLineVisitor<T>, TermVisitor<T> {}
