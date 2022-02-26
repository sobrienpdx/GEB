import 'package:geb/math/ast.dart';
import 'package:geb/math/rule_definitions.dart';
import 'package:geb/math/state.dart';
import 'package:geb/math/symbols.dart';
import 'package:test/test.dart';

main() {
  late FullState state;

  setUp(() {
    state = FullState();
  });

  group('joining:', () {
    test('basic', () {
      state.addDerivationLine(PushFantasy());
      state.addDerivationLine(Formula('P'));
      state.addDerivationLine(Formula('Q'));
      state.activateRule(joiningRule);
      expect(state.message, 'Select 2 lines for joining');
      expect(state.derivationLines[0].decorated.single.isSelectable, false);
      expect(state.derivationLines[1].decorated.single.isSelectable, true);
      expect(state.derivationLines[2].decorated.single.isSelectable, true);
      expect(state.previewLine, '<x${and}y>');
      state.derivationLines[1].decorated.single.select();
      expect(state.previewLine, '<P${and}y>');
      expect(state.derivationLines, hasLength(3));
      state.derivationLines[2].decorated.single.select();
      expect(state.derivationLines, hasLength(4));
      expect(state.derivationLines[3].line, Formula('<P&Q>'));
      expect(state.message, 'Applied rule "joining"');
    });

    test('same line twice', () {
      state.addDerivationLine(Formula('P'));
      state.activateRule(joiningRule);
      state.derivationLines[0].decorated.single.select();
      expect(state.derivationLines, hasLength(1));
      state.derivationLines[0].decorated.single.select();
      expect(state.derivationLines, hasLength(2));
      expect(state.derivationLines[1].line, Formula('<P&P>'));
    });
  });
}
