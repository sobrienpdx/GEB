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

  Term parseBinaryTerm() {
    assert(peek() == '(');
    next();
    var left = parseTerm();
    Term Function(Term, Term) combiner;
    switch (peek()) {
      case '+':
        next();
        combiner = (left, right) => Plus(left, right);
        break;
      case '⋅':
      case '*':
        next();
        combiner = (left, right) => Times(left, right);
        break;
      default:
        throw ParseError();
    }
    var right = parseTerm();
    if (peek() != ')') throw ParseError();
    next();
    return combiner(left, right);
  }

  Equation parseEquation() {
    var leftSide = parseTerm();
    if (peek() != '=') {
      throw ParseError();
    }
    next();
    var rightSide = parseTerm();
    return Equation(leftSide, rightSide);
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
      case forall:
      case '!':
        return parseQuantifier(
            (variable, operand) => Forall(variable, operand));
      default:
        return parseEquation();
    }
  }

  PropositionalAtom parsePropositionalAtom() =>
      PropositionalAtom(_gatherName());

  Formula parseQuantifier(Formula Function(Variable, Formula) combiner) {
    next();
    var variable = parseVariable();
    if (peek() != ':') throw ParseError();
    next();
    var operand = parseFormula();
    return combiner(variable, operand);
  }

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
        return Successor.apply(successorCount, parseVariable());
      case '(':
        return Successor.apply(successorCount, parseBinaryTerm());
      default:
        throw ParseError();
    }
  }

  Variable parseVariable() => Variable(_gatherName());

  String? peek({int skip = 0}) =>
      pos + skip >= input.length ? null : input[pos + skip];

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
