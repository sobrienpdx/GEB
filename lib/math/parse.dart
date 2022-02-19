import 'package:geb/math/symbols.dart';

import 'ast.dart';

class ParseError {}

abstract class Parser {
  factory Parser(String input) = _Parser;

  bool get isAtEnd;

  Formula parseFormula();

  static T run<T>(String input, T Function(Parser) parseFunction) {
    var parser = Parser(input);
    var result = parseFunction(parser);
    if (!parser.isAtEnd) {
      throw ParseError();
    }
    return result;
  }
}

class _Parser implements Parser {
  final String input;

  int pos = 0;

  _Parser(this.input);

  @override
  bool get isAtEnd => pos >= input.length;

  String next() {
    if (isAtEnd) throw ParseError();
    return input[pos++];
  }

  @override
  Formula parseFormula() {
    switch (peek()) {
      case 'P':
      case 'Q':
      case 'R':
        return parsePropositionalAtom();
      case '~':
        next();
        return Not(parseFormula());
      default:
        throw ParseError();
    }
  }

  PropositionalAtom parsePropositionalAtom() {
    var name = StringBuffer(next());
    while (true) {
      var char = peek();
      if (char == prime || char == "'") {
        name.write(prime);
        next();
      } else {
        break;
      }
    }
    return PropositionalAtom(name.toString());
  }

  String? peek() => isAtEnd ? null : input[pos];
}
