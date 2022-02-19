import 'ast.dart';

class Proof {
  _Context _context = _TopLevelContext();

  bool isTheorem(Formula x) => _context.isTheorem(x);

  Formula join(Formula x, Formula y) {
    if (!isTheorem(x)) throw MathError();
    if (!isTheorem(y)) throw MathError();
    var result = And(x, y);
    _context.addTheorem(result);
    return result;
  }

  void pushFantasy(Formula premise) {
    _context = _FantasyContext(_context, premise);
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
