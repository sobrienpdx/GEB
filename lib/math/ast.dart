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

abstract class Formula {
  factory Formula(String input) => Parser.run(input, (p) => p.parseFormula());

  Formula._();

  String toString() {
    var buffer = StringBuffer();
    _writeTo(buffer);
    return buffer.toString();
  }

  void _writeTo(StringBuffer buffer);
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

class Not extends Formula {
  final Formula operand;

  Not(this.operand) : super._();

  @override
  void _writeTo(StringBuffer buffer) {
    buffer.write('~');
    operand._writeTo(buffer);
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
