import 'package:geb/math/ast.dart';
import 'package:geb/math/proof.dart';
import 'package:geb/math/rules.dart';
import 'package:test/test.dart';

main() {
  test('joining', () {
    var derivation = makeDerivation(['P', 'Q']);
    var rule = JoiningRule();
    var isSelectable = rule.computeIsSelectable(derivation);
    expect(isSelectable, hasLength(2));
    expect(isSelectable[0], true);
    expect(isSelectable[1], true);
    rule.apply(derivation,
        [derivation.lines[0] as Formula, derivation.lines[1] as Formula]);
    expect(derivation.lines.last, Formula('<P&Q>'));
  });
}

void checkResult(List<Formula> result, List<String> newLines) {
  expect(result, [for (var line in newLines) Formula(line)]);
}

DerivationState makeDerivation(Iterable<String> lines) {
  var derivation = DerivationState();
  for (var line in lines) {
    derivation.addLine(DerivationLine(line));
  }
  return derivation;
}
