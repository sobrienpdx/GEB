import 'package:geb/math/symbols.dart';

import 'ast.dart';

class ParseError {}

abstract class Parser {
  factory Parser(String input) = _Parser;

  bool get isAtEnd;

  Formula parseFormula();

  Term parseTerm();

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

  Formula parseBinaryFormula() {
    assert(peek() == '<');
    next();
    var left = parseFormula();
    Formula Function(Formula, Formula) combiner;
    switch (peek()) {
      case and:
      case '&':
        next();
        combiner = (left, right) => And(left, right);
        break;
      case or:
      case '|':
        next();
        combiner = (left, right) => Or(left, right);
        break;
      case implies:
        next();
        combiner = (left, right) => Implies(left, right);
        break;
      case '-':
        if (peek(skip: 1) == '>') {
          next();
          next();
          combiner = (left, right) => Implies(left, right);
          break;
        } else {
          throw ParseError();
        }
      default:
        throw ParseError();
    }
    var right = parseFormula();
    if (peek() != '>') throw ParseError();
    next();
    return combiner(left, right);
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
      case '<':
        return parseBinaryFormula();
      default:
        throw ParseError();
    }
  }

  PropositionalAtom parsePropositionalAtom() =>
      PropositionalAtom(_gatherName());

  @override
  Term parseTerm() {
    int successorCount = 0;
    while (peek() == 'S') {
      ++successorCount;
      next();
    }
    switch (peek()) {
      case '0':
        next();
        return Numeral(successorCount);
      case 'a':
      case 'b':
      case 'c':
      case 'd':
      case 'e':
        return _applySuccessors(successorCount, parseVariable());
      default:
        throw ParseError();
    }
  }

  Variable parseVariable() => Variable(_gatherName());

  String? peek({int skip = 0}) =>
      pos + skip >= input.length ? null : input[pos + skip];

  Term _applySuccessors(int successorCount, Term term) {
    for (int i = 0; i < successorCount; i++) {
      term = throw UnimplementedError('TODO(paul)');
    }
    return term;
  }

  String _gatherName() {
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
    return name.toString();
  }
}
