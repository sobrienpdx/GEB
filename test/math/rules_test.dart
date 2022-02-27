import 'package:geb/math/ast.dart';
import 'package:geb/math/proof.dart';
import 'package:geb/math/rules.dart';
import 'package:test/test.dart';

main() {
  test('joining', () {
    var derivation = makeDerivation(['P', 'Q']);
    var rule = JoiningRule();
    var isSelectable = rule.computeIsSelectable(derivation.lines);
    expect(isSelectable, hasLength(2));
    expect(isSelectable[0], true);
    expect(isSelectable[1], true);
    rule.apply(derivation, derivation.lines[0] as Formula,
        derivation.lines[1] as Formula);
    expect(derivation.lines.last, Formula('<P&Q>'));
  });

  test('separation', () {
    var derivation = makeDerivation(['P', 'Q', '<P&Q>']);
    var rule = SeparationRule();
    var regions = rule.getRegions(derivation.lines);
    expect(regions, hasLength(3));
    expect(regions[0], isNull);
    expect(regions[1], isNull);
    var subexpressions =
        (regions[2] as SubexpressionsStepRegionInfo).subexpressions.toList();
    expect(subexpressions, hasLength(2));
    expect(subexpressions[0].formula, Formula('P'));
    checkResult(rule.apply(subexpressions[0]), ['P']);
    checkResult(rule.apply(subexpressions[1]), ['Q']);
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
