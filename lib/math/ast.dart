import 'package:geb/math/free_variables.dart';
import 'package:geb/math/parse.dart';
import 'package:geb/math/pretty_print.dart';

import 'hash.dart';
import 'symbols.dart';
import 'visitor.dart';

class And extends Formula {
  final Formula leftOperand;
  final Formula rightOperand;

  And(this.leftOperand, this.rightOperand) : super._();

  @override
  int get hashCode =>
      Hash.hash3((And).hashCode, leftOperand.hashCode, rightOperand.hashCode);

  @override
  bool operator ==(Object other) =>
      other is And &&
      leftOperand == other.leftOperand &&
      rightOperand == other.rightOperand;

  @override
  T accept<T>(FormulaVisitor<T> visitor) => visitor.visitAnd(this);
}

abstract class Atom extends Formula {
  Atom() : super._();
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
  T accept<T>(FormulaVisitor<T> visitor) => visitor.visitEquation(this);
}

class Exists extends Formula {
  final Variable variable;

  final Formula operand;

  Exists(this.variable, this.operand) : super._() {
    if (!operand.containsFreeVariable(variable)) throw MathError();
  }

  @override
  int get hashCode =>
      Hash.hash3((Exists).hashCode, variable.hashCode, operand.hashCode);

  @override
  bool operator ==(Object other) =>
      other is Exists && variable == other.variable && operand == other.operand;

  @override
  T accept<T>(FormulaVisitor<T> visitor) => visitor.visitExists(this);
}

class Forall extends Formula {
  final Variable variable;

  final Formula operand;

  Forall(this.variable, this.operand) : super._() {
    if (!operand.containsFreeVariable(variable)) throw MathError();
  }

  @override
  int get hashCode =>
      Hash.hash3((Forall).hashCode, variable.hashCode, operand.hashCode);

  @override
  bool operator ==(Object other) =>
      other is Forall && variable == other.variable && operand == other.operand;

  @override
  T accept<T>(FormulaVisitor<T> visitor) => visitor.visitForall(this);
}

abstract class Formula extends Node {
  factory Formula(String input) => Parser.run(input, (p) => p.parseFormula());

  Formula._();

  bool get isOpen => accept(IsOpen());

  T accept<T>(FormulaVisitor<T> visitor);

  bool containsFreeVariable(Variable v) => accept(ContainsFreeVariable(v));
}

class Implies extends Formula {
  final Formula leftOperand;
  final Formula rightOperand;

  Implies(this.leftOperand, this.rightOperand) : super._();

  @override
  int get hashCode => Hash.hash3(
      (Implies).hashCode, leftOperand.hashCode, rightOperand.hashCode);

  @override
  bool operator ==(Object other) =>
      other is Implies &&
      leftOperand == other.leftOperand &&
      rightOperand == other.rightOperand;

  @override
  T accept<T>(FormulaVisitor<T> visitor) => visitor.visitImplies(this);
}

class MathError {}

abstract class Node {
  const Node();

  T accept<T>(Visitor<T> visitor);

  String toString() {
    var visitor = PrettyPrinter();
    accept(visitor);
    return visitor.buffer.toString();
  }
}

class NonzeroNumeral extends Numeral implements Successor {
  final int value;

  NonzeroNumeral(this.value) : super._() {
    if (value <= 0) throw MathError();
  }

  @override
  int get hashCode => Hash.hash2((NonzeroNumeral).hashCode, value.hashCode);

  @override
  Term get operand => Numeral(0);

  @override
  int get successorCount => value;

  @override
  bool operator ==(Object other) =>
      other is NonzeroNumeral && value == other.value;

  @override
  T accept<T>(TermVisitor<T> visitor) => visitor.visitNonzeroNumeral(this);
}

class Not extends Formula {
  final Formula operand;

  Not(this.operand) : super._();

  @override
  int get hashCode => Hash.hash2((Not).hashCode, operand.hashCode);

  @override
  bool operator ==(Object other) => other is Not && operand == other.operand;

  @override
  T accept<T>(FormulaVisitor<T> visitor) => visitor.visitNot(this);
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
}

class Or extends Formula {
  final Formula leftOperand;
  final Formula rightOperand;

  Or(this.leftOperand, this.rightOperand) : super._();

  @override
  int get hashCode =>
      Hash.hash3((Or).hashCode, leftOperand.hashCode, rightOperand.hashCode);

  @override
  bool operator ==(Object other) =>
      other is Or &&
      leftOperand == other.leftOperand &&
      rightOperand == other.rightOperand;

  @override
  T accept<T>(FormulaVisitor<T> visitor) => visitor.visitOr(this);
}

class Plus extends Term {
  final Term leftOperand;
  final Term rightOperand;

  Plus(this.leftOperand, this.rightOperand) : super._();

  @override
  int get hashCode =>
      Hash.hash3((Plus).hashCode, leftOperand.hashCode, rightOperand.hashCode);

  @override
  bool get isDefinite => leftOperand.isDefinite && rightOperand.isDefinite;

  @override
  bool operator ==(Object other) =>
      other is Plus &&
      leftOperand == other.leftOperand &&
      rightOperand == other.rightOperand;

  @override
  T accept<T>(TermVisitor<T> visitor) => visitor.visitPlus(this);
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
  T accept<T>(FormulaVisitor<T> visitor) =>
      visitor.visitPropositionalAtom(this);

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
  int get hashCode => Hash.hash3(
      (Successor).hashCode, successorCount.hashCode, operand.hashCode);

  @override
  bool get isDefinite => operand.isDefinite;

  @override
  bool operator ==(Object other) =>
      other is Successor &&
      successorCount == other.successorCount &&
      operand == other.operand;

  @override
  T accept<T>(TermVisitor<T> visitor) => visitor.visitSuccessor(this);

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
  int get hashCode =>
      Hash.hash3((Times).hashCode, leftOperand.hashCode, rightOperand.hashCode);

  @override
  bool get isDefinite => leftOperand.isDefinite && rightOperand.isDefinite;

  @override
  bool operator ==(Object other) =>
      other is Times &&
      leftOperand == other.leftOperand &&
      rightOperand == other.rightOperand;

  @override
  T accept<T>(TermVisitor<T> visitor) => visitor.visitTimes(this);
}

abstract class TNTAtom extends Atom {}

class Variable extends Term {
  static const _allowedFirstCharacters = ['a', 'b', 'c', 'd', 'e'];

  final String name;

  Variable(this.name) : super._() {
    if (!_isValidName(name)) throw MathError();
  }

  @override
  int get hashCode => Hash.hash2((Variable).hashCode, name.hashCode);

  @override
  bool get isDefinite => false;

  @override
  bool operator ==(Object other) => other is Variable && name == other.name;

  @override
  T accept<T>(TermVisitor<T> visitor) => visitor.visitVariable(this);

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
  int get hashCode => (Zero).hashCode;

  @override
  int get value => 0;

  @override
  bool operator ==(Object other) => other is Zero;

  @override
  T accept<T>(TermVisitor<T> visitor) => visitor.visitZero(this);
}
