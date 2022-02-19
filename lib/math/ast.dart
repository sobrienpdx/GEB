import 'package:geb/math/parse.dart';

import 'symbols.dart';

class And extends Formula {
  final Formula leftOperand;
  final Formula rightOperand;

  And(this.leftOperand, this.rightOperand) : super._();

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

abstract class Formula extends Node {
  factory Formula(String input) => Parser.run(input, (p) => p.parseFormula());

  Formula._();
}

class Implies extends Formula {
  final Formula leftOperand;
  final Formula rightOperand;

  Implies(this.leftOperand, this.rightOperand) : super._();

  @override
  void _writeTo(StringBuffer buffer) {
    buffer.write('<');
    leftOperand._writeTo(buffer);
    buffer.write(implies);
    rightOperand._writeTo(buffer);
    buffer.write('>');
  }
}

abstract class Node {
  String toString() {
    var buffer = StringBuffer();
    _writeTo(buffer);
    return buffer.toString();
  }

  void _writeTo(StringBuffer buffer);
}

class Not extends Formula {
  final Formula operand;

  Not(this.operand) : super._();

  @override
  void _writeTo(StringBuffer buffer) {
    buffer.write('~');
    operand._writeTo(buffer);
  }
}

class Numeral extends Term {
  final int value;

  Numeral(this.value)
      : assert(value >= 0),
        super._();

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
  void _writeTo(StringBuffer buffer) {
    buffer.write('<');
    leftOperand._writeTo(buffer);
    buffer.write(or);
    rightOperand._writeTo(buffer);
    buffer.write('>');
  }
}

class PropositionalAtom extends Atom {
  static const _allowedFirstCharacters = ['P', 'Q', 'R'];

  final String name;

  PropositionalAtom(this.name) : assert(_isValidName(name));

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

abstract class Term extends Node {
  factory Term(String input) => Parser.run(input, (p) => p.parseTerm());

  Term._();
}

class Variable extends Term {
  static const _allowedFirstCharacters = ['a', 'b', 'c', 'd', 'e'];

  final String name;

  Variable(this.name)
      : assert(_isValidName(name)),
        super._();

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
