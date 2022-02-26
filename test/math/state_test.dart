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
    state.addDerivationLine(PushFantasy());
    state.addDerivationLine(Formula('P'));
    state.addDerivationLine(Formula('Q'));
    state.activateRule(joiningRule);
    expect(state.message, 'Select 2 lines for joining');
    expect(state.proofLines[0].isSelectable, false);
    expect(state.proofLines[1].isSelectable, true);
    expect(state.proofLines[2].isSelectable, true);
    state.proofLines[1].toggleSelection();
    expect(state.proofLines, hasLength(3));
    state.proofLines[2].toggleSelection();
    expect(state.proofLines, hasLength(4));
    expect(state.proofLines[3].line, Formula('<P&Q>'));
  });
}
