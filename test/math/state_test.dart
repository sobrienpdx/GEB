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

  group('addDerivationLine:', () {
    test("don't crash on empty fantasy", () {
      state.addDerivationLine(PushFantasy());
      state.addDerivationLine(PopFantasy());
    });
  });

  group('joining:', () {
    test('basic', () {
      state.addDerivationLine(PushFantasy());
      state.addDerivationLine(Formula('P'));
      state.addDerivationLine(Formula('Q'));
      expect(state.isSelectionNeeded, false);
      state.activateRule(joiningRule);
      expect(state.isSelectionNeeded, true);
      expect(state.message, 'Select 2 lines for joining');
      expect(state.derivationLines[0].decorated.single.isSelectable, false);
      expect(state.derivationLines[1].decorated.single.isSelectable, true);
      expect(state.derivationLines[2].decorated.single.isSelectable, true);
      expect(state.previewLine, '<x${and}y>');
      state.derivationLines[1].decorated.single.select();
      expect(state.isSelectionNeeded, true);
      expect(state.previewLine, '<P${and}y>');
      expect(state.derivationLines, hasLength(3));
      state.derivationLines[2].decorated.single.select();
      expect(state.isSelectionNeeded, false);
      expect(state.derivationLines, hasLength(4));
      expect(state.derivationLines[3].line, Formula('<P&Q>'));
      expect(state.message, 'Applied rule "joining"');
    });

    test('same line twice', () {
      state.addDerivationLine(Formula('P'));
      expect(state.isSelectionNeeded, false);
      state.activateRule(joiningRule);
      expect(state.isSelectionNeeded, true);
      state.derivationLines[0].decorated.single.select();
      expect(state.isSelectionNeeded, true);
      expect(state.derivationLines, hasLength(1));
      state.derivationLines[0].decorated.single.select();
      expect(state.isSelectionNeeded, false);
      expect(state.derivationLines, hasLength(2));
      expect(state.derivationLines[1].line, Formula('<P&P>'));
    });

    group('double tilde: ', () {
      test('introduce at top', () {
        state.addDerivationLine(Formula('P'));
        expect(state.isSelectionNeeded, false);
        state.activateRule(doubleTildeRule);
        expect(state.isSelectionNeeded, true);
        expect(state.message, 'Select a region for double tilde');
        var decoratedLine = state.derivationLines[0].decorated;
        expect(decoratedLine, hasLength(2));
        expect(decoratedLine[0].text, middleDot);
        expect(decoratedLine[0].isSelectable, true);
        expect(decoratedLine[0].isSelected, false);
        expect(decoratedLine[1].text, 'P');
        expect(decoratedLine[1].isSelectable, false);
        expect(decoratedLine[1].isSelected, false);
        expect(state.derivationLines, hasLength(1));
        decoratedLine[0].select();
        expect(state.isSelectionNeeded, false);
        expect(state.derivationLines, hasLength(2));
        expect(state.derivationLines[1].line, Formula('~~P'));
      });

      test('introduce inner', () {
        state.addDerivationLine(Formula('!a:a=a'));
        expect(state.isSelectionNeeded, false);
        state.activateRule(doubleTildeRule);
        expect(state.isSelectionNeeded, true);
        expect(state.message, 'Select a region for double tilde');
        var decoratedLine = state.derivationLines[0].decorated;
        expect(decoratedLine, hasLength(4));
        expect(decoratedLine[0].text, middleDot);
        expect(decoratedLine[0].isSelectable, true);
        expect(decoratedLine[0].isSelected, false);
        expect(decoratedLine[1].text, '${forall}a:');
        expect(decoratedLine[1].isSelectable, false);
        expect(decoratedLine[1].isSelected, false);
        expect(decoratedLine[2].text, middleDot);
        expect(decoratedLine[2].isSelectable, true);
        expect(decoratedLine[2].isSelected, false);
        expect(decoratedLine[3].text, 'a=a');
        expect(decoratedLine[3].isSelectable, false);
        expect(decoratedLine[3].isSelected, false);
        expect(state.derivationLines, hasLength(1));
        decoratedLine[2].select();
        expect(state.isSelectionNeeded, false);
        expect(state.derivationLines, hasLength(2));
        expect(state.derivationLines[1].line, Formula('!a:~~a=a'));
      });

      test('remove', () {
        state.addDerivationLine(Formula('~~P'));
        expect(state.isSelectionNeeded, false);
        state.activateRule(doubleTildeRule);
        expect(state.isSelectionNeeded, true);
        expect(state.message, 'Select a region for double tilde');
        var decoratedLine = state.derivationLines[0].decorated;
        expect(decoratedLine, hasLength(4));
        expect(decoratedLine[0].text, middleDot);
        expect(decoratedLine[0].isSelectable, true);
        expect(decoratedLine[0].isSelected, false);
        expect(decoratedLine[1].text, '~~');
        expect(decoratedLine[1].isSelectable, true);
        expect(decoratedLine[1].isSelected, false);
        expect(decoratedLine[2].text, middleDot);
        expect(decoratedLine[2].isSelectable, true);
        expect(decoratedLine[2].isSelected, false);
        expect(decoratedLine[3].text, 'P');
        expect(decoratedLine[3].isSelectable, false);
        expect(decoratedLine[3].isSelected, false);
        expect(state.derivationLines, hasLength(1));
        decoratedLine[1].select();
        expect(state.isSelectionNeeded, false);
        expect(state.derivationLines, hasLength(2));
        expect(state.derivationLines[1].line, Formula('P'));
      });
    });
  });
}
