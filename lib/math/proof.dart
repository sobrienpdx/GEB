import 'ast.dart';

class Proof {
  _Context _context = _TopLevelContext();

  bool isTheorem(Formula x) => _context.isTheorem(x);

  Formula join(Formula x, Formula y) => _rule([x, y], () => And(x, y));

  void pushFantasy(Formula premise) {
    _context = _FantasyContext(_context, premise);
  }

  Formula separate(Formula x, Side side) =>
      _rule([x], () => x is And ? x.getOperand(side) : throw MathError());

  Formula _rule(List<Formula> premises, Formula createNewTheorem()) {
    for (var premise in premises) {
      if (!isTheorem(premise)) throw MathError();
    }
    var result = createNewTheorem();
    _context.addTheorem(result);
    return result;
  }
}

abstract class _Context {
  void addTheorem(Formula x);

  bool isTheorem(Formula x);
}

class _FantasyContext extends _Context {
  final _Context parent;

  final Set<Formula> localTheorems;

  _FantasyContext(this.parent, Formula premise) : localTheorems = {premise};

  @override
  void addTheorem(Formula x) {
    localTheorems.add(x);
  }

  @override
  bool isTheorem(Formula x) => localTheorems.contains(x) || parent.isTheorem(x);
}

class _TopLevelContext extends _Context {
  final Set<Formula> theorems = {};

  @override
  void addTheorem(Formula x) {
    theorems.add(x);
  }

  @override
  bool isTheorem(Formula x) => theorems.contains(x);
}
