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

class IsOpen extends AnyVisitor {
  final Set<String> quantifiedVariables = {};

  @override
  bool visitExists(Exists node) {
    var variableName = node.variable.name;
    var newlyAdded = quantifiedVariables.add(variableName);
    assert(newlyAdded);
    var result = node.operand.accept(this);
    if (newlyAdded) {
      quantifiedVariables.remove(variableName);
    }
    return result;
  }

  @override
  bool visitForall(Forall node) {
    var variableName = node.variable.name;
    var newlyAdded = quantifiedVariables.add(variableName);
    assert(newlyAdded);
    var result = node.operand.accept(this);
    if (newlyAdded) {
      quantifiedVariables.remove(variableName);
    }
    return result;
  }

  @override
  bool visitVariable(Variable node) => !quantifiedVariables.contains(node.name);
}
