import 'package:geb/math/ast.dart';

import 'visitor.dart';

class ContainsFreeVariable extends AnyVisitor {
  final Variable variable;

  ContainsFreeVariable(this.variable);

  @override
  bool visitExists(Exists node) =>
      node.variable.name == variable.name ? false : node.operand.accept(this);

  @override
  bool visitForall(Forall node) =>
      node.variable.name == variable.name ? false : node.operand.accept(this);

  @override
  bool visitVariable(Variable node) => node.name == variable.name;
}
