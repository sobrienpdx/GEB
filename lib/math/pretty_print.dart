import 'package:geb/math/ast.dart';

import 'context.dart';
import 'symbols.dart';
import 'visitor.dart';

class PrettyPrinter extends PrettyPrinterBase {
  final buffer = StringBuffer();

  @override
  void write(String text) {
    buffer.write(text);
  }
}

abstract class PrettyPrinterBase
    implements ProofLineVisitor<void, DerivationLineContext>, TermVisitor<void, void> {
  void dispatchFormula(Formula node, DerivationLineContext context) {
    node.accept(this, context);
  }

  void dispatchTerm(Term node) {
    node.accept(this, null);
  }

  @override
  void visitAnd(And node, DerivationLineContext context) {
    write('<');
    dispatchFormula(node.leftOperand, context.leftOperand);
    write(and);
    dispatchFormula(node.rightOperand, context.rightOperand);
    write('>');
  }

  @override
  void visitEquation(Equation node, DerivationLineContext context) {
    dispatchTerm(node.leftSide);
    write('=');
    dispatchTerm(node.rightSide);
  }

  @override
  void visitExists(Exists node, DerivationLineContext context) {
    write(exists);
    visitVariable(node.variable, null);
    write(':');
    dispatchFormula(node.operand, context.operand);
  }

  @override
  void visitForall(Forall node, DerivationLineContext context) {
    write(forall);
    visitVariable(node.variable, null);
    write(':');
    dispatchFormula(node.operand, context.operand);
  }

  @override
  void visitImplies(Implies node, DerivationLineContext context) {
    write('<');
    dispatchFormula(node.leftOperand, context.leftOperand);
    write(implies);
    dispatchFormula(node.rightOperand, context.rightOperand);
    write('>');
  }

  @override
  void visitNot(Not node, DerivationLineContext context) {
    write('~');
    dispatchFormula(node.operand, context.operand);
  }

  @override
  void visitOr(Or node, DerivationLineContext context) {
    write('<');
    dispatchFormula(node.leftOperand, context.leftOperand);
    write(or);
    dispatchFormula(node.rightOperand, context.rightOperand);
    write('>');
  }

  @override
  void visitPlus(Plus node, void param) {
    write('(');
    dispatchTerm(node.leftOperand);
    write('+');
    dispatchTerm(node.rightOperand);
    write(')');
  }

  @override
  void visitPopFantasy(PopFantasy node, DerivationLineContext context) {
    write(']');
  }

  @override
  void visitPropositionalAtom(PropositionalAtom node, DerivationLineContext context) {
    write(node.name);
  }

  @override
  void visitPushFantasy(PushFantasy node, DerivationLineContext context) {
    write('[');
  }

  @override
  void visitSuccessor(Successor node, void param) {
    write('S');
    dispatchTerm(node.operand);
  }

  @override
  void visitTimes(Times node, void param) {
    write('(');
    dispatchTerm(node.leftOperand);
    write(times);
    dispatchTerm(node.rightOperand);
    write(')');
  }

  @override
  void visitVariable(Variable node, void param) {
    write(node.name);
  }

  @override
  void visitZero(Zero node, void param) {
    write('0');
  }

  void write(String text);
}
