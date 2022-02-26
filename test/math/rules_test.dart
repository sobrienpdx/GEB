import 'package:geb/math/ast.dart';
import 'package:geb/math/rules.dart';
import 'package:test/test.dart';

main() {
  test('joining', () {
    var derivation = makeDerivation(['P', 'Q']);
    var rule = JoiningRule();
    var regions = rule.getRegions(derivation);
    expect(regions, hasLength(2));
    expect(regions[0], TypeMatcher<FullLineStepRegionInfo>());
    expect(regions[1], TypeMatcher<FullLineStepRegionInfo>());
    checkResult(rule.apply(regions[0]!, regions[1]!), ['<P&Q>']);
  });

  test('separation', () {
    var derivation = makeDerivation(['P', 'Q', '<P&Q>']);
    var rule = SeparationRule();
    var regions = rule.getRegions(derivation);
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

void checkResult(List<DerivationStep> result, List<String> newLines) {
  expect([for (var line in result) (line as FormulaStep).formula],
      [for (var line in newLines) Formula(line)]);
}

Derivation makeDerivation(Iterable<String> lines) =>
    Derivation([for (var line in lines) FormulaStep(Formula(line))]);