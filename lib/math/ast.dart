import 'package:geb/math/free_variables.dart';
import 'package:geb/math/parse.dart';

import 'symbols.dart';
import 'visitor.dart';

class And extends Formula {
  final Formula leftOperand;
  final Formula rightOperand;

  And(this.leftOperand, this.rightOperand) : super._();

  @override
  T accept<T>(FormulaVisitor<T> visitor) => visitor.visitAnd(this);

  @override
  void _writeTo(StringBuffer buffer) {
    buffer.write('<');
    leftOperand._writeTo(buffer);
    buffer.write(and);
    rightOperand._writeTo(buffer);
    buffer.write('>');
  }
}

abstract class Atom extends Formula {
  Atom() : super._();
}

class Equation extends TNTAtom {
  final Term leftSide;
  final Term rightSide;

  Equation(this.leftSide, this.rightSide);

  @override
  T accept<T>(FormulaVisitor<T> visitor) => visitor.visitEquation(this);

  @override
  void _writeTo(StringBuffer buffer) {
    leftSide._writeTo(buffer);
    buffer.write('=');
    rightSide._writeTo(buffer);
  }
}

class Forall extends Formula {
  final Variable variable;

  final Formula operand;

  Forall(this.variable, this.operand) : super._() {
    if (!operand.containsFreeVariable(variable)) throw MathError();
  }

  @override
  T accept<T>(FormulaVisitor<T> visitor) => visitor.visitForall(this);

  @override
  void _writeTo(StringBuffer buffer) {
    buffer.write(forall);
    buffer.write(variable);
    buffer.write(':');
    buffer.write(operand);
  }
}

abstract class Formula extends Node {
  factory Formula(String input) => Parser.run(input, (p) => p.parseFormula());

  Formula._();

  T accept<T>(FormulaVisitor<T> visitor);

  bool containsFreeVariable(Variable v) => accept(ContainsFreeVariable(v));
}

class Implies extends Formula {
  final Formula leftOperand;
  final Formula rightOperand;

  Implies(this.leftOperand, this.rightOperand) : super._();

  @override
  T accept<T>(FormulaVisitor<T> visitor) => visitor.visitImplies(this);

  @override
  void _writeTo(StringBuffer buffer) {
    buffer.write('<');
    leftOperand._writeTo(buffer);
    buffer.write(implies);
    rightOperand._writeTo(buffer);
    buffer.write('>');
  }
}

class MathError {}

abstract class Node {
  const Node();

  String toString() {
    var buffer = StringBuffer();
    _writeTo(buffer);
    return buffer.toString();
  }

  void _writeTo(StringBuffer buffer);
}

class NonzeroNumeral extends Numeral implements Successor {
  final int value;

  NonzeroNumeral(this.value) : super._() {
    if (value <= 0) throw MathError();
  }

  @override
  Term get operand => Numeral(0);

  @override
  int get successorCount => value;

  @override
  T accept<T>(TermVisitor<T> visitor) => visitor.visitNonzeroNumeral(this);
}

class Not extends Formula {
  final Formula operand;

  Not(this.operand) : super._();

  @override
  T accept<T>(FormulaVisitor<T> visitor) => visitor.visitNot(this);

  @override
  void _writeTo(StringBuffer buffer) {
    buffer.write('~');
    operand._writeTo(buffer);
  }
}

abstract class Numeral extends Term {
  factory Numeral(int value) {
    if (value < 0) throw MathError();
    if (value == 0) return Zero();
    return NonzeroNumeral(value);
  }

  const Numeral._() : super._();

  @override
  bool get isDefinite => true;

  int get value;

  @override
  void _writeTo(StringBuffer buffer) {
    for (int i = 0; i < value; i++) {
      buffer.write('S');
    }
    buffer.write('0');
  }
}

class Or extends Formula {
  final Formula leftOperand;
  final Formula rightOperand;

  Or(this.leftOperand, this.rightOperand) : super._();

  @override
  T accept<T>(FormulaVisitor<T> visitor) => visitor.visitOr(this);

  @override
  void _writeTo(StringBuffer buffer) {
    buffer.write('<');
    leftOperand._writeTo(buffer);
    buffer.write(or);
    rightOperand._writeTo(buffer);
    buffer.write('>');
  }
}

class Plus extends Term {
  final Term leftOperand;
  final Term rightOperand;

  Plus(this.leftOperand, this.rightOperand) : super._();

  @override
  bool get isDefinite => leftOperand.isDefinite && rightOperand.isDefinite;

  @override
  T accept<T>(TermVisitor<T> visitor) => visitor.visitPlus(this);

  @override
  void _writeTo(StringBuffer buffer) {
    buffer.write('(');
    leftOperand._writeTo(buffer);
    buffer.write('+');
    rightOperand._writeTo(buffer);
    buffer.write(')');
  }
}

class PropositionalAtom extends Atom {
  static const _allowedFirstCharacters = ['P', 'Q', 'R'];

  final String name;

  PropositionalAtom(this.name) {
    if (!_isValidName(name)) throw MathError();
  }

  @override
  T accept<T>(FormulaVisitor<T> visitor) =>
      visitor.visitPropositionalAtom(this);

  @override
  void _writeTo(StringBuffer buffer) {
    buffer.write(name);
  }

  static bool _isValidName(String name) {
    if (name.isEmpty) return false;
    if (!_allowedFirstCharacters.contains(name[0])) return false;
    for (int i = 1; i < name.length; i++) {
      if (name[i] != prime) return false;
    }
    return true;
  }
}

class Successor extends Term {
  final int successorCount;

  final Term operand;

  Successor._(this.successorCount, this.operand) : super._();

  @override
  bool get isDefinite => operand.isDefinite;

  @override
  T accept<T>(TermVisitor<T> visitor) => visitor.visitSuccessor(this);

  @override
  void _writeTo(StringBuffer buffer) {
    for (int i = 0; i < successorCount; i++) {
      buffer.write('S');
    }
    operand._writeTo(buffer);
  }

  static Term apply(int successorCount, Term operand) {
    if (successorCount == 0) {
      return operand;
    } else if (operand is Numeral) {
      return NonzeroNumeral(successorCount + operand.value);
    } else if (operand is Successor) {
      return Successor._(
          successorCount + operand.successorCount, operand.operand);
    } else {
      return Successor._(successorCount, operand);
    }
  }
}

abstract class Term extends Node {
  factory Term(String input) => Parser.run(input, (p) => p.parseTerm());

  const Term._();

  bool get isDefinite;

  T accept<T>(TermVisitor<T> visitor);

  bool containsVariable(Variable v) => accept(ContainsFreeVariable(v));
}

class Times extends Term {
  final Term leftOperand;
  final Term rightOperand;

  Times(this.leftOperand, this.rightOperand) : super._();

  @override
  bool get isDefinite => leftOperand.isDefinite && rightOperand.isDefinite;

  @override
  T accept<T>(TermVisitor<T> visitor) => visitor.visitTimes(this);

  @override
  void _writeTo(StringBuffer buffer) {
    buffer.write('(');
    leftOperand._writeTo(buffer);
    buffer.write(times);
    rightOperand._writeTo(buffer);
    buffer.write(')');
  }
}

abstract class TNTAtom extends Atom {}

class Variable extends Term {
  static const _allowedFirstCharacters = ['a', 'b', 'c', 'd', 'e'];

  final String name;

  Variable(this.name) : super._() {
    if (!_isValidName(name)) throw MathError();
  }

  @override
  bool get isDefinite => false;

  @override
  T accept<T>(TermVisitor<T> visitor) => visitor.visitVariable(this);

  @override
  void _writeTo(StringBuffer buffer) {
    buffer.write(name);
  }

  static bool _isValidName(String name) {
    if (name.isEmpty) return false;
    if (!_allowedFirstCharacters.contains(name[0])) return false;
    for (int i = 1; i < name.length; i++) {
      if (name[i] != prime) return false;
    }
    return true;
  }
}

class Zero extends Numeral {
  factory Zero() => const Zero._();

  const Zero._() : super._();

  @override
  int get value => 0;

  @override
  T accept<T>(TermVisitor<T> visitor) => visitor.visitZero(this);
}
