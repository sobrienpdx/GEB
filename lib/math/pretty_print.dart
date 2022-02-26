import 'package:geb/math/ast.dart';

import 'symbols.dart';
import 'visitor.dart';

class PrettyPrinter implements Visitor<void> {
  final buffer = StringBuffer();

  @override
  void visitAnd(And node) {
    buffer.write('<');
    node.leftOperand.accept(this);
    buffer.write(and);
    node.rightOperand.accept(this);
    buffer.write('>');
  }

  @override
  void visitEquation(Equation node) {
    node.leftSide.accept(this);
    buffer.write('=');
    node.rightSide.accept(this);
  }

  @override
  void visitExists(Exists node) {
    buffer.write(exists);
    node.variable.accept(this);
    buffer.write(':');
    node.operand.accept(this);
  }

  @override
  void visitForall(Forall node) {
    buffer.write(forall);
    node.variable.accept(this);
    buffer.write(':');
    node.operand.accept(this);
  }

  @override
  void visitImplies(Implies node) {
    buffer.write('<');
    node.leftOperand.accept(this);
    buffer.write(implies);
    node.rightOperand.accept(this);
    buffer.write('>');
  }

  @override
  void visitNot(Not node) {
    buffer.write('~');
    node.operand.accept(this);
  }

  @override
  void visitOr(Or node) {
    buffer.write('<');
    node.leftOperand.accept(this);
    buffer.write(or);
    node.rightOperand.accept(this);
    buffer.write('>');
  }

  @override
  void visitPlus(Plus node) {
    buffer.write('(');
    node.leftOperand.accept(this);
    buffer.write('+');
    node.rightOperand.accept(this);
    buffer.write(')');
  }

  @override
  void visitPropositionalAtom(PropositionalAtom node) {
    buffer.write(node.name);
  }

  @override
  void visitSuccessor(Successor node) {
    buffer.write('S');
    node.operand.accept(this);
  }

  @override
  void visitTimes(Times node) {
    buffer.write('(');
    node.leftOperand.accept(this);
    buffer.write(times);
    node.rightOperand.accept(this);
    buffer.write(')');
  }

  @override
  void visitVariable(Variable node) {
    buffer.write(node.name);
  }

  @override
  void visitZero(Zero node) {
    buffer.write('0');
  }
}
