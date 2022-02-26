import 'ast.dart';

abstract class DerivationLineContext {
  factory DerivationLineContext(DerivationLine derivationLine) =>
      _DerivationLineContext(
          derivationLine, derivationLine, (replacement) => replacement);

  DerivationLineContext._();

  DerivationLine get derivationLine;

  DerivationLineContext get leftOperand => getOperand(Side.left);

  DerivationLineContext get operand;

  DerivationLineContext get rightOperand => getOperand(Side.right);

  DerivationLine get top;

  DerivationLineContext getOperand(Side side);

  Formula substitute(Formula replacement);
}

class _DerivationLineContext extends DerivationLineContext {
  @override
  final DerivationLine top;

  @override
  final DerivationLine derivationLine;

  final Formula Function(Formula) _substitute;

  _DerivationLineContext(this.top, this.derivationLine, this._substitute)
      : super._();

  DerivationLineContext get operand {
    var formula = this.derivationLine;
    if (formula is! UnaryFormula) throw MathError();
    return _DerivationLineContext(top, formula.operand,
        (replacement) => _substitute(formula.substituteOperand(replacement)));
  }

  @override
  DerivationLineContext getOperand(Side side) {
    var formula = this.derivationLine;
    if (formula is! BinaryFormula) throw MathError();
    return _DerivationLineContext(top, formula.getOperand(side),
        (replacement) => _substitute(formula.substitute(side, replacement)));
  }

  @override
  Formula substitute(Formula replacement) => _substitute(replacement);
}
