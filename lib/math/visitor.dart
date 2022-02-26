import 'ast.dart';

class AnyVisitor implements Visitor<bool, void> {
  const AnyVisitor();

  @override
  bool visitAnd(And node, void param) =>
      node.leftOperand.accept(this, param) ||
      node.rightOperand.accept(this, param);

  @override
  bool visitEquation(Equation node, void param) =>
      node.leftSide.accept(this, param) || node.rightSide.accept(this, param);

  @override
  bool visitExists(Exists node, void param) => node.operand.accept(this, param);

  @override
  bool visitForall(Forall node, void param) => node.operand.accept(this, param);

  @override
  bool visitImplies(Implies node, void param) =>
      node.leftOperand.accept(this, param) ||
      node.rightOperand.accept(this, param);

  @override
  bool visitNot(Not node, void param) => node.operand.accept(this, param);

  @override
  bool visitOr(Or node, void param) =>
      node.leftOperand.accept(this, param) ||
      node.rightOperand.accept(this, param);

  @override
  bool visitPlus(Plus node, void param) =>
      node.leftOperand.accept(this, param) ||
      node.rightOperand.accept(this, param);

  @override
  bool visitPopFantasy(PopFantasy node, void param) => false;

  @override
  bool visitPropositionalAtom(PropositionalAtom node, void param) => false;

  @override
  bool visitPushFantasy(PushFantasy node, void param) => false;

  @override
  bool visitSuccessor(Successor node, void param) =>
      node.operand.accept(this, param);

  @override
  bool visitTimes(Times node, void param) =>
      node.leftOperand.accept(this, param) ||
      node.rightOperand.accept(this, param);

  @override
  bool visitVariable(Variable node, void param) => false;

  @override
  bool visitZero(Zero node, void param) => false;
}

abstract class FormulaVisitor<R, P> {
  R visitAnd(And node, P param);
  R visitEquation(Equation node, P param);
  R visitExists(Exists node, P param);
  R visitForall(Forall node, P param);
  R visitImplies(Implies node, P param);
  R visitNot(Not node, P param);
  R visitOr(Or node, P param);
  R visitPropositionalAtom(PropositionalAtom node, P param);
}

abstract class ProofLineVisitor<R, P> implements FormulaVisitor<R, P> {
  R visitPopFantasy(PopFantasy node, P param);
  R visitPushFantasy(PushFantasy node, P param);
}

abstract class TermVisitor<R, P> {
  R visitPlus(Plus node, P param);
  R visitSuccessor(Successor node, P param);
  R visitTimes(Times node, P param);
  R visitVariable(Variable node, P param);
  R visitZero(Zero node, P param);
}

abstract class Visitor<R, P>
    implements ProofLineVisitor<R, P>, TermVisitor<R, P> {}
