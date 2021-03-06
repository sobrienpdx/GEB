import 'package:geb/math/free_variables.dart';
import 'package:geb/math/parse.dart';
import 'package:geb/math/pretty_print.dart';

import 'context.dart';
import 'hash.dart';
import 'symbols.dart';
import 'visitor.dart';

class And extends BinaryFormula {
  And(Formula leftOperand, Formula rightOperand)
      : super(leftOperand, rightOperand);

  @override
  int get hashCode =>
      Hash.hash3((And).hashCode, leftOperand.hashCode, rightOperand.hashCode);

  @override
  bool operator ==(Object other) =>
      other is And &&
      leftOperand == other.leftOperand &&
      rightOperand == other.rightOperand;

  @override
  R accept<R, P>(FormulaVisitor<R, P> visitor, P param) =>
      visitor.visitAnd(this, param);

  @override
  Formula _rebuild(Formula leftOperand, Formula rightOperand) =>
      And(leftOperand, rightOperand);
}

abstract class Atom extends Formula {
  Atom() : super._();
}

abstract class BinaryFormula extends Formula {
  final Formula leftOperand;
  final Formula rightOperand;

  BinaryFormula(this.leftOperand, this.rightOperand) : super._();

  Formula getOperand(Side side) {
    switch (side) {
      case Side.left:
        return leftOperand;
      case Side.right:
        return rightOperand;
    }
  }

  Formula substitute(Side side, Formula replacement) {
    switch (side) {
      case Side.left:
        return _rebuild(replacement, rightOperand);
      case Side.right:
        return _rebuild(leftOperand, replacement);
    }
  }

  Formula _rebuild(Formula leftOperand, Formula rightOperand);
}

abstract class DerivationLine extends Node {
  factory DerivationLine(String input) =>
      Parser.run(input, (p) => p.parseProofLine());

  DerivationLine._();

  R accept<R, P>(ProofLineVisitor<R, P> visitor, P param);

  String toString() {
    var visitor = PrettyPrinter();
    accept(visitor, DerivationLineContext(this));
    return visitor.buffer.toString();
  }
}

class Equation extends TNTAtom {
  final Term leftSide;
  final Term rightSide;

  Equation(this.leftSide, this.rightSide);

  @override
  int get hashCode =>
      Hash.hash3((Equation).hashCode, leftSide.hashCode, rightSide.hashCode);

  @override
  bool operator ==(Object other) =>
      other is Equation &&
      leftSide == other.leftSide &&
      rightSide == other.rightSide;

  @override
  R accept<R, P>(FormulaVisitor<R, P> visitor, P param) =>
      visitor.visitEquation(this, param);
}

class Exists extends Quantification {
  Exists(Variable variable, Formula operand) : super(variable, operand);

  @override
  int get hashCode =>
      Hash.hash3((Exists).hashCode, variable.hashCode, operand.hashCode);

  @override
  bool operator ==(Object other) =>
      other is Exists && variable == other.variable && operand == other.operand;

  @override
  R accept<R, P>(FormulaVisitor<R, P> visitor, P param) =>
      visitor.visitExists(this, param);

  @override
  Quantification _rebuild(Variable variable, Formula operand) =>
      Exists(variable, operand);
}

class Forall extends Quantification {
  Forall(Variable variable, Formula operand) : super(variable, operand);

  @override
  int get hashCode =>
      Hash.hash3((Forall).hashCode, variable.hashCode, operand.hashCode);

  @override
  bool operator ==(Object other) =>
      other is Forall && variable == other.variable && operand == other.operand;

  @override
  R accept<R, P>(FormulaVisitor<R, P> visitor, P param) =>
      visitor.visitForall(this, param);

  @override
  Quantification _rebuild(Variable variable, Formula operand) =>
      Forall(variable, operand);
}

abstract class Formula extends DerivationLine {
  factory Formula(String input) => Parser.run(input, (p) => p.parseFormula());

  Formula._() : super._();

  bool get isOpen => accept(IsOpen(), null);

  @override
  R accept<R, P>(FormulaVisitor<R, P> visitor, P param);

  bool containsFreeVariable(Variable v) =>
      accept(ContainsFreeVariable(v), null);
}

class Implies extends BinaryFormula {
  Implies(Formula leftOperand, Formula rightOperand)
      : super(leftOperand, rightOperand);

  @override
  int get hashCode => Hash.hash3(
      (Implies).hashCode, leftOperand.hashCode, rightOperand.hashCode);

  @override
  bool operator ==(Object other) =>
      other is Implies &&
      leftOperand == other.leftOperand &&
      rightOperand == other.rightOperand;

  @override
  R accept<R, P>(FormulaVisitor<R, P> visitor, P param) =>
      visitor.visitImplies(this, param);

  @override
  BinaryFormula _rebuild(Formula leftOperand, Formula rightOperand) =>
      Implies(leftOperand, rightOperand);
}

class MathError {}

abstract class Node {
  const Node();

  R accept<R, P>(Visitor<R, P> visitor, P param);
}

class Not extends UnaryFormula {
  Not(Formula operand) : super(operand);

  @override
  int get hashCode => Hash.hash2((Not).hashCode, operand.hashCode);

  @override
  bool operator ==(Object other) => other is Not && operand == other.operand;

  @override
  R accept<R, P>(FormulaVisitor<R, P> visitor, P param) =>
      visitor.visitNot(this, param);

  @override
  Formula substituteOperand(Formula replacement) => Not(replacement);
}

class Or extends BinaryFormula {
  Or(Formula leftOperand, Formula rightOperand)
      : super(leftOperand, rightOperand);

  @override
  int get hashCode =>
      Hash.hash3((Or).hashCode, leftOperand.hashCode, rightOperand.hashCode);

  @override
  bool operator ==(Object other) =>
      other is Or &&
      leftOperand == other.leftOperand &&
      rightOperand == other.rightOperand;

  @override
  R accept<R, P>(FormulaVisitor<R, P> visitor, P param) =>
      visitor.visitOr(this, param);

  @override
  Formula _rebuild(Formula leftOperand, Formula rightOperand) =>
      Or(leftOperand, rightOperand);
}

class Plus extends Term {
  final Term leftOperand;
  final Term rightOperand;

  Plus(this.leftOperand, this.rightOperand) : super._();

  @override
  int get hashCode =>
      Hash.hash3((Plus).hashCode, leftOperand.hashCode, rightOperand.hashCode);

  @override
  bool operator ==(Object other) =>
      other is Plus &&
      leftOperand == other.leftOperand &&
      rightOperand == other.rightOperand;

  @override
  R accept<R, P>(TermVisitor<R, P> visitor, P param) =>
      visitor.visitPlus(this, param);
}

class PopFantasy extends DerivationLine {
  PopFantasy() : super._();

  @override
  int get hashCode => (PopFantasy).hashCode;

  @override
  bool operator ==(Object other) => other is PopFantasy;

  @override
  R accept<R, P>(ProofLineVisitor<R, P> visitor, P param) =>
      visitor.visitPopFantasy(this, param);
}

class PropositionalAtom extends Atom {
  static const _allowedFirstCharacters = ['P', 'Q', 'R'];

  final String name;

  PropositionalAtom(this.name) {
    if (!_isValidName(name)) throw MathError();
  }

  @override
  int get hashCode => Hash.hash2((PropositionalAtom).hashCode, name.hashCode);

  @override
  bool operator ==(Object other) =>
      other is PropositionalAtom && name == other.name;

  @override
  R accept<R, P>(FormulaVisitor<R, P> visitor, P param) =>
      visitor.visitPropositionalAtom(this, param);

  static bool _isValidName(String name) {
    if (name.isEmpty) return false;
    if (!_allowedFirstCharacters.contains(name[0])) return false;
    for (int i = 1; i < name.length; i++) {
      if (name[i] != prime) return false;
    }
    return true;
  }
}

class PushFantasy extends DerivationLine {
  PushFantasy() : super._();

  @override
  int get hashCode => (PushFantasy).hashCode;

  @override
  bool operator ==(Object other) => other is PushFantasy;

  @override
  R accept<R, P>(ProofLineVisitor<R, P> visitor, P param) =>
      visitor.visitPushFantasy(this, param);
}

abstract class Quantification extends UnaryFormula {
  final Variable variable;

  Quantification(this.variable, Formula operand) : super(operand) {
    if (!operand.containsFreeVariable(variable)) throw MathError();
  }

  @override
  Formula substituteOperand(Formula replacement) =>
      _rebuild(variable, replacement);

  Quantification _rebuild(Variable variable, Formula operand);
}

enum Side { left, right }

class Successor extends Term {
  final Term operand;

  Successor(this.operand) : super._();

  @override
  int get hashCode => Hash.hash2((Successor).hashCode, operand.hashCode);

  @override
  bool operator ==(Object other) =>
      other is Successor && operand == other.operand;

  @override
  R accept<R, P>(TermVisitor<R, P> visitor, P param) =>
      visitor.visitSuccessor(this, param);
}

abstract class Term extends Node {
  factory Term(String input) => Parser.run(input, (p) => p.parseTerm());

  const Term._();

  bool get isDefinite => !accept(ContainsVariable(), null);

  R accept<R, P>(TermVisitor<R, P> visitor, P param);

  bool containsVariable(Variable v) => accept(ContainsFreeVariable(v), null);

  String toString() {
    var visitor = PrettyPrinter();
    accept(visitor, null);
    return visitor.buffer.toString();
  }
}

class Times extends Term {
  final Term leftOperand;
  final Term rightOperand;

  Times(this.leftOperand, this.rightOperand) : super._();

  @override
  int get hashCode =>
      Hash.hash3((Times).hashCode, leftOperand.hashCode, rightOperand.hashCode);

  @override
  bool operator ==(Object other) =>
      other is Times &&
      leftOperand == other.leftOperand &&
      rightOperand == other.rightOperand;

  @override
  R accept<R, P>(TermVisitor<R, P> visitor, P param) =>
      visitor.visitTimes(this, param);
}

abstract class TNTAtom extends Atom {}

abstract class UnaryFormula extends Formula {
  final Formula operand;

  UnaryFormula(this.operand) : super._();

  Formula substituteOperand(Formula replacement);
}

class Variable extends Term {
  static const _allowedFirstCharacters = ['a', 'b', 'c', 'd', 'e'];

  final String name;

  Variable(this.name) : super._() {
    if (!_isValidName(name)) throw MathError();
  }

  @override
  int get hashCode => Hash.hash2((Variable).hashCode, name.hashCode);

  @override
  bool operator ==(Object other) => other is Variable && name == other.name;

  @override
  R accept<R, P>(TermVisitor<R, P> visitor, P param) =>
      visitor.visitVariable(this, param);

  static bool _isValidName(String name) {
    if (name.isEmpty) return false;
    if (!_allowedFirstCharacters.contains(name[0])) return false;
    for (int i = 1; i < name.length; i++) {
      if (name[i] != prime) return false;
    }
    return true;
  }
}

class Zero extends Term {
  factory Zero() => const Zero._();

  const Zero._() : super._();

  @override
  int get hashCode => (Zero).hashCode;

  @override
  bool operator ==(Object other) => other is Zero;

  @override
  R accept<R, P>(TermVisitor<R, P> visitor, P param) =>
      visitor.visitZero(this, param);
}
