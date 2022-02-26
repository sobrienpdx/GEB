import 'package:geb/math/ast.dart';
import 'package:geb/math/rules.dart';
import 'package:test/test.dart';

main() {
  test('joining', () {
    var derivation = makeDerivation(['P', 'Q']);
    var rule = JoiningRule();
    var regions = rule.getRegions(derivation);
    expect(regions[0], TypeMatcher<FullLineStepRegionInfo>());
    expect(regions[1], TypeMatcher<FullLineStepRegionInfo>());
    var result = rule.apply(regions[0]!, regions[1]!);
    expect(result, hasLength(1));
    expect((result[0] as FormulaStep).formula, Formula('<P&Q>'));
  });

  test('separation', () {
    var derivation = makeDerivation(['P', 'Q', '<P&Q>']);
    var rule = SeparationRule();
    rule.getRegions(derivation);
    // TODO(paul): test this more
  });
}

Derivation makeDerivation(Iterable<String> lines) =>
    Derivation([for (var line in lines) FormulaStep(Formula(line))]);
