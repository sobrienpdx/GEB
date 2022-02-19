import 'package:geb/math/ast.dart';

import 'visitor.dart';

class ContainsFreeVariable implements FormulaVisitor<bool>, TermVisitor<bool> {
  final Variable variable;

  ContainsFreeVariable(this.variable);

  @override
  bool visitAnd(And node) =>
      node.leftOperand.accept(this) || node.rightOperand.accept(this);

  @override
  bool visitEquation(Equation node) =>
      node.leftSide.accept(this) || node.rightSide.accept(this);

  @override
  bool visitExists(Exists node) =>
      node.variable.name == variable.name ? false : node.operand.accept(this);

  @override
  bool visitForall(Forall node) =>
      node.variable.name == variable.name ? false : node.operand.accept(this);

  @override
  bool visitImplies(Implies node) =>
      node.leftOperand.accept(this) || node.rightOperand.accept(this);

  @override
  bool visitNonzeroNumeral(NonzeroNumeral node) => false;

  @override
  bool visitNot(Not node) => node.operand.accept(this);

  @override
  bool visitOr(Or node) =>
      node.leftOperand.accept(this) || node.rightOperand.accept(this);

  @override
  bool visitPlus(Plus node) =>
      node.leftOperand.accept(this) || node.rightOperand.accept(this);

  @override
  bool visitPropositionalAtom(PropositionalAtom node) => false;

  @override
  bool visitSuccessor(Successor node) => node.operand.accept(this);

  @override
  bool visitTimes(Times node) =>
      node.leftOperand.accept(this) || node.rightOperand.accept(this);

  @override
  bool visitVariable(Variable node) => node.name == variable.name;

  @override
  bool visitZero(Zero node) => false;
}
