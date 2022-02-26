import 'package:geb/math/ast.dart';
import 'package:geb/math/rule_definitions.dart';
import 'package:geb/math/state.dart';
import 'package:test/test.dart';

main() {
  late FullState state;

  setUp(() {
    state = FullState();
  });

  test('joining', () {
    state.addFormula(Formula('P'));
    state.addFormula(Formula('Q'));
    state.activateRule(joiningRule);
    expect(state.message, 'Select 2 lines for joining');
    state.proofLines[0].toggleSelection();
    expect(state.proofLines, hasLength(2));
    state.proofLines[1].toggleSelection();
    expect(state.proofLines, hasLength(3));
    expect(state.proofLines[2].formula, Formula('<P&Q>'));
  });
}
