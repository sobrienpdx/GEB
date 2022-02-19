import 'ast.dart';

abstract class FormulaContext {
  factory FormulaContext(Formula formula) =>
      _FormulaContext(formula, formula, (replacement) => replacement);

  FormulaContext._();

  Formula get formula;

  FormulaContext get leftOperand => getOperand(Side.left);

  FormulaContext get operand;

  FormulaContext get rightOperand => getOperand(Side.right);

  Formula get top;

  FormulaContext getOperand(Side side);

  Formula substitute(Formula replacement);
}

class _FormulaContext extends FormulaContext {
  @override
  final Formula top;

  @override
  final Formula formula;

  final Formula Function(Formula) _substitute;

  _FormulaContext(this.top, this.formula, this._substitute) : super._();

  FormulaContext get operand {
    var formula = this.formula;
    if (formula is! UnaryFormula) throw MathError();
    return _FormulaContext(top, formula.operand,
        (replacement) => _substitute(formula.substituteOperand(replacement)));
  }

  @override
  FormulaContext getOperand(Side side) {
    var formula = this.formula;
    if (formula is! BinaryFormula) throw MathError();
    return _FormulaContext(top, formula.getOperand(side),
        (replacement) => _substitute(formula.substitute(side, replacement)));
  }

  @override
  Formula substitute(Formula replacement) => _substitute(replacement);
}
