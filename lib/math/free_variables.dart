import 'package:geb/math/ast.dart';

import 'visitor.dart';

class ContainsFreeVariable extends AnyVisitor {
  final Variable variable;

  ContainsFreeVariable(this.variable);

  @override
  bool visitExists(Exists node, void param) =>
      node.variable.name == variable.name
          ? false
          : node.operand.accept(this, param);

  @override
  bool visitForall(Forall node, void param) =>
      node.variable.name == variable.name
          ? false
          : node.operand.accept(this, param);

  @override
  bool visitVariable(Variable node, void param) => node.name == variable.name;
}

class ContainsVariable extends AnyVisitor {
  factory ContainsVariable() => const ContainsVariable._();

  const ContainsVariable._();

  @override
  bool visitVariable(Variable node, void param) => true;
}

class IsOpen extends AnyVisitor {
  final Set<String> quantifiedVariables = {};

  @override
  bool visitExists(Exists node, void param) {
    var variableName = node.variable.name;
    var newlyAdded = quantifiedVariables.add(variableName);
    assert(newlyAdded);
    var result = node.operand.accept(this, param);
    if (newlyAdded) {
      quantifiedVariables.remove(variableName);
    }
    return result;
  }

  @override
  bool visitForall(Forall node, void param) {
    var variableName = node.variable.name;
    var newlyAdded = quantifiedVariables.add(variableName);
    assert(newlyAdded);
    var result = node.operand.accept(this, param);
    if (newlyAdded) {
      quantifiedVariables.remove(variableName);
    }
    return result;
  }

  @override
  bool visitVariable(Variable node, void param) =>
      !quantifiedVariables.contains(node.name);
}
