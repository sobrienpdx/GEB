import 'dart:convert';

import 'package:geb/math/ast.dart';
import 'package:geb/math/parse.dart';
import 'package:geb/math/rule_definitions.dart';
import 'package:geb/math/rules.dart';
import 'package:geb/math/state.dart';
import 'package:geb/math/symbols.dart';
import 'package:test/test.dart';

main() {
  late FullState state;

  setUp(() {
    state = FullState();
  });

  void check(TestStep action) {
    action.check(state);
  }

  group('addDerivationLine:', () {
    test('basic', () {
      check(addLine('P').addsExplanations(['User supplied premise']));
    });

    test("don't crash on empty fantasy", () {
      check(addLines(['[', ']']));
    });
  });

  group('joining:', () {
    test('basic', () {
      check(addLines(['[', 'P', 'Q']));
      check(rule(joiningRule)
          .showsMessage('Select 2 lines for joining')
          .hasSelectionState(
              selectable: {1: 'P', 2: 'Q'}).showsPreview('<x${and}y>'));
      check(select(1, 'P')
          .showsMessage('Select 2 lines for joining')
          .hasSelectionState(
              selectable: {1: 'P', 2: 'Q'},
              selected: {1: 'P'}).showsPreview('<P${and}y>'));
      check(select(2, 'Q')
          .addsLines(['<P&Q>'])
          .addsExplanations(['Applied rule "joining"'])
          .isQuiescent()
          .showsMessage('Applied rule "joining".'));
    });

    test('same line twice', () {
      check(addLine('P'));
      check(rule(joiningRule));
      check(select(0, 'P')
          .hasSelectionState(selectable: {0: 'P'}, selected: {0: 'P'}));
      check(select(0, 'P').addsLines(['<P&P>']).isQuiescent());
    });

    test('available theorems', () {
      check(addLines(['P', '[', 'Q', '[', 'R', ']', 'P']));
      check(rule(joiningRule).hasSelectionState(selectable: {2: 'Q', 6: 'P'}));
    });
  });

  group('double tilde: ', () {
    test('introduce at top', () {
      check(addLine('P'));
      check(rule(doubleTildeRule).hasSelectionState(selectable: {
        0: star
      }).showsMessage('Select a region for double tilde'));
      check(select(0, star)
          .addsLines(['~~P'])
          .addsExplanations(['Applied rule "double tilde"'])
          .isQuiescent()
          .showsMessage('Applied rule "double tilde".'));
    });

    test('introduce inner', () {
      check(addLine('!a:a=a'));
      check(rule(doubleTildeRule).hasSelectionState(selectable: {
        0: [star, star]
      }));
      check(select(0, star, index: 1).addsLines(['!a:~~a=a']).isQuiescent());
    });

    test('remove', () {
      check(addLine('~~P'));
      check(rule(doubleTildeRule).hasSelectionState(selectable: {
        0: [star, '~~', star]
      }));
      check(select(0, '~~').addsLines(['P']).isQuiescent());
    });

    test('available theorems', () {
      check(addLines(['P', '[', 'Q', '[', 'R', ']', 'P']));
      check(rule(doubleTildeRule)
          .hasSelectionState(selectable: {2: star, 6: star}));
    });
  });

  group('separation:', () {
    test('LHS', () {
      check(addLine('<P&Q>'));
      check(rule(separationRule).hasSelectionState(selectable: {
        0: ['P', 'Q']
      }).showsMessage('Select a region for separation'));
      check(select(0, 'P')
          .addsLines(['P'])
          .addsExplanations(['Applied rule "separation"'])
          .isQuiescent()
          .showsMessage('Applied rule "separation".'));
    });

    test('RHS', () {
      check(addLine('<P&Q>'));
      check(rule(separationRule));
      check(select(0, 'Q').addsLines(['Q']).isQuiescent());
    });

    test('no match', () {
      check(addLine('<P|Q>'));
      check(rule(separationRule).hasSelectionState(selectable: isEmpty));
    });

    test('available theorems', () {
      check(addLines(["<P&P'>", '[', "<Q&Q'>", '[', "<R&R'>", ']', "<P&P'>"]));
      check(rule(separationRule).hasSelectionState(selectable: {
        2: ['Q', "Q'"],
        6: ['P', "P'"]
      }));
    });
  });

  group('fantasy:', () {
    test('basic', () {
      check(rule(pushFantasyRule)
          .addsLines(['['])
          .addsExplanations(['Applied rule "push fantasy"'])
          .isQuiescent()
          .showsMessage('Starting a fantasy,  Please enter the premise.'));
      check(addLine('P')
          .addsExplanations(['User supplied premise']).showsMessage(''));
      check(addLine('Q'));
      check(rule(popFantasyRule)
          .addsLines([']', '<P->Q>'])
          .addsExplanations(
              ['Applied rule "pop fantasy"', 'Resulting new theorem'])
          .isQuiescent()
          .showsMessage('Applied rule "pop fantasy".'));
    });

    group('illegal pop:', () {
      test('no fantasy in progress', () {
        check(rule(popFantasyRule)
            .isQuiescent()
            .showsMessage('Cannot pop a fantasy right now.'));
      });

      test('last line is not a formula', () {
        check(addLines(['[', 'P', '[']));
        check(rule(popFantasyRule)
            .isQuiescent()
            .showsMessage('Cannot pop a fantasy right now.'));
      });
    });
  });

  group('carry-over:', () {
    test('basic', () {
      check(addLines(['[', 'P', '[', 'Q']));
      check(rule(carryOverRule)
          .showsMessage('Select a region for carry-over')
          .hasSelectionState(selectable: {1: 'P'}));
      check(select(1, 'P')
          .addsLines(['P'])
          .addsExplanations(['Applied rule "carry-over"'])
          .isQuiescent()
          .showsMessage('Applied rule "carry-over".'));
    });

    test('available theorems', () {
      check(addLines(['P', '[', 'Q', '[', 'R', ']', 'P', '[', 'Q']));
      check(
          rule(carryOverRule).hasSelectionState(selectable: {2: 'Q', 6: 'P'}));
    });
  });

  group('detachment:', () {
    test('basic', () {
      check(addLines(['[', 'P', '<P->Q>']));
      check(rule(detachmentRule)
          .showsMessage('Select 2 lines for detachment')
          .hasSelectionState(
              selectable: {1: 'P', 2: '<P->Q>'}).showsPreview(''));
      check(select(1, 'P')
          .showsMessage('Select 2 lines for detachment')
          .hasSelectionState(
              selectable: {2: '<P->Q>'}, selected: {1: 'P'}).showsPreview(''));
      check(select(2, '<P->Q>')
          .addsLines(['Q'])
          .addsExplanations(['Applied rule "detachment"'])
          .isQuiescent()
          .showsMessage('Applied rule "detachment".'));
    });

    test('reversed selection order', () {
      check(addLines(['[', 'P', '<P->Q>']));
      check(rule(detachmentRule)
          .showsMessage('Select 2 lines for detachment')
          .hasSelectionState(
              selectable: {1: 'P', 2: '<P->Q>'}).showsPreview(''));
      check(select(2, '<P->Q>')
          .showsMessage('Select 2 lines for detachment')
          .hasSelectionState(
              selectable: {1: 'P'}, selected: {2: '<P->Q>'}).showsPreview('Q'));
      check(select(1, 'P')
          .addsLines(['Q'])
          .addsExplanations(['Applied rule "detachment"'])
          .isQuiescent()
          .showsMessage('Applied rule "detachment".'));
    });

    group('ambiguous first selection:', () {
      void firstPart() {
        check(addLines(['[', 'P', '<P->Q>', '<<P->Q>->R>']));
        check(rule(detachmentRule).hasSelectionState(
            selectable: {1: 'P', 2: '<P->Q>', 3: '<<P->Q>->R>'}));
        check(select(2, '<P->Q>').hasSelectionState(
            selectable: {1: 'P', 3: '<<P->Q>->R>'},
            selected: {2: '<P->Q>'}).showsPreview('Q'));
      }

      test('implication', () {
        firstPart();
        check(select(1, 'P').addsLines(['Q']).isQuiescent());
      });

      test('premise', () {
        firstPart();
        check(select(3, '<<P->Q>->R>').addsLines(['R']).isQuiescent());
      });
    });

    test('available theorems', () {
      check(addLines(['P', '[', 'Q', '[', 'R', ']', 'P']));
      check(rule(joiningRule).hasSelectionState(selectable: {2: 'Q', 6: 'P'}));
    });
  });

  group('contrapositive: ', () {
    group('forward', () {
      test('basic', () {
        check(addLine('<P->Q>'));
        check(rule(contrapositiveRule)
            .hasSelectionState(selectable: {0: '<P->Q>'})
            .showsPreview('<~y⊃~x>')
            .showsMessage('Select 1 line for contrapositive'));
        check(select(0, '<P->Q>')
            .addsLines(['<~Q->~P>'])
            .addsExplanations(['Applied rule "contrapositive"'])
            .isQuiescent()
            .showsMessage('Applied rule "contrapositive".'));
      });

      test('premise inverted', () {
        check(addLine('<~P->Q>'));
        check(rule(contrapositiveRule)
            .hasSelectionState(selectable: {0: '<~P->Q>'}));
        check(select(0, '<~P->Q>').addsLines(['<~Q->~~P>']).isQuiescent());
      });

      test('conclusion inverted', () {
        check(addLine('<P->~Q>'));
        check(rule(contrapositiveRule)
            .hasSelectionState(selectable: {0: '<P->~Q>'}));
        check(select(0, '<P->~Q>').addsLines(['<~~Q->~P>']).isQuiescent());
      });
    });

    test('reversed', () {
      check(addLine('<~P->~Q>'));
      check(rule(contrapositiveRule)
          .hasSelectionState(selectable: {0: '<~P->~Q>'}));
      check(select(0, '<~P->~Q>').addsLines(['<Q->P>']).isQuiescent());
    });

    test('mismatch', () {
      check(addLine('<P&Q>'));
      check(rule(contrapositiveRule).hasSelectionState(selectable: isEmpty));
    });

    test('available theorems', () {
      check(addLines(
          ["<P->P'>", '[', "<Q->Q'>", '[', "<R->R'>", ']', "<P->P'>"]));
      check(rule(contrapositiveRule)
          .hasSelectionState(selectable: {2: "<Q->Q'>", 6: "<P->P'>"}));
    });
  });

  group('de morgan: ', () {
    test('forward', () {
      check(addLine('<~P&~Q>'));
      check(rule(deMorgansRule)
          .hasSelectionState(selectable: {0: '<~P&~Q>'})
          .showsPreview('')
          .showsMessage('Select 1 line for de morgan'));
      check(select(0, '<~P&~Q>')
          .addsLines(['~<P|Q>'])
          .addsExplanations(['Applied rule "de morgan"'])
          .isQuiescent()
          .showsMessage('Applied rule "de morgan".'));
    });

    test('reversed', () {
      check(addLine('~<P|Q>'));
      check(rule(deMorgansRule).hasSelectionState(selectable: {0: '~<P|Q>'}));
      check(select(0, '~<P|Q>').addsLines(['<~P&~Q>']).isQuiescent());
    });

    test('mismatch', () {
      check(addLines(['<~P&Q>', '<P&~Q>', '~<P&Q>', '<~P|~Q>']));
      check(rule(deMorgansRule).hasSelectionState(selectable: isEmpty));
    });

    test('available theorems', () {
      check(addLines(
          ["~<P|P'>", '[', "~<Q|Q'>", '[', "~<R|R'>", ']', "~<P|P'>"]));
      check(rule(deMorgansRule)
          .hasSelectionState(selectable: {2: "~<Q|Q'>", 6: "~<P|P'>"}));
    });
  });

  group('switcheroo: ', () {
    test('forward', () {
      check(addLine('<P|Q>'));
      check(rule(switcherooRule)
          .hasSelectionState(selectable: {0: '<P|Q>'})
          .showsPreview('')
          .showsMessage('Select 1 line for switcheroo'));
      check(select(0, '<P|Q>')
          .addsLines(['<~P->Q>'])
          .addsExplanations(['Applied rule "switcheroo"'])
          .isQuiescent()
          .showsMessage('Applied rule "switcheroo".'));
    });

    test('reversed', () {
      check(addLine('<~P->Q>'));
      check(rule(switcherooRule).hasSelectionState(selectable: {0: '<~P->Q>'}));
      check(select(0, '<~P->Q>').addsLines(['<P|Q>']).isQuiescent());
    });

    test('mismatch', () {
      check(addLines(['<P&Q>', '<P->Q>']));
      check(rule(switcherooRule).hasSelectionState(selectable: isEmpty));
    });

    test('available theorems', () {
      check(addLines(["<P|P'>", '[', "<Q|Q'>", '[', "<R|R'>", ']', "<P|P'>"]));
      check(rule(switcherooRule)
          .hasSelectionState(selectable: {2: "<Q|Q'>", 6: "<P|P'>"}));
    });
  });

  test("Ganto's Ax", () {
    check(rule(pushFantasyRule).addsLines(['['])); // 0: [
    check(addLine('<<P->Q>&<~P->Q>>')); // 1: <<P->Q>&<~P->Q>>
    check(rule(separationRule));
    check(select(1, '<P->Q>').addsLines(['<P->Q>'])); // 2: <P->Q>
    check(rule(contrapositiveRule));
    check(select(2, '<P->Q>').addsLines(['<~Q->~P>'])); // 3: <~Q->~P>
    check(rule(separationRule));
    check(select(1, '<~P->Q>').addsLines(['<~P->Q>'])); // 4: <~P->Q>
    check(rule(contrapositiveRule));
    check(select(4, '<~P->Q>').addsLines(['<~Q->~~P>'])); // 5: <~Q->~~P>
    check(rule(pushFantasyRule).addsLines(['['])); // 6: [
    check(addLine('~Q')); // 7: ~Q
    check(rule(carryOverRule));
    check(select(3, '<~Q->~P>').addsLines(['<~Q->~P>'])); // 8: <~Q->~P>
    check(rule(detachmentRule));
    check(select(7, '~Q'));
    check(select(8, '<~Q->~P>').addsLines(['~P'])); // 9: ~P
    check(rule(carryOverRule));
    check(select(5, '<~Q->~~P>').addsLines(['<~Q->~~P>'])); // 10: <~Q->~~P>
    check(rule(detachmentRule));
    check(select(7, '~Q'));
    check(select(10, '<~Q->~~P>').addsLines(['~~P'])); // 11: ~~P
    check(rule(joiningRule));
    check(select(9, '~P'));
    check(select(11, '~~P').addsLines(['<~P&~~P>'])); // 12: <~P&~~P>
    check(rule(deMorgansRule));
    check(select(12, '<~P&~~P>').addsLines(['~<P|~P>'])); // 13: ~<P|~P>
    check(rule(popFantasyRule).addsLines([
      ']', // 14: ]
      '<~Q->~<P|~P>>' // 15: <~Q->~<P|~P>>
    ]));
    check(rule(contrapositiveRule));
    check(select(15, '<~Q->~<P|~P>>')
        .addsLines(['<<P|~P>->Q>'])); // 16: <<P|~P>->Q>
    check(rule(pushFantasyRule).addsLines(['['])); // 17: [
    check(addLine('~P')); // 18: ~P
    check(rule(popFantasyRule).addsLines([
      ']', // 19: ]
      '<~P->~P>', // 20: <~P->~P>
    ]));
    check(rule(switcherooRule));
    check(select(20, '<~P->~P>').addsLines(['<P|~P>'])); // 21: <P|~P>
    check(rule(detachmentRule));
    check(select(21, '<P|~P>'));
    check(select(16, '<<P|~P>->Q>').addsLines(['Q'])); // 22: Q
    check(rule(popFantasyRule).addsLines([
      ']', // 23: ]
      '<<<P->Q>&<~P->Q>>->Q>' // 24: <<<P->Q>&<~P->Q>>->Q>
    ]));
  });
}

TestStep addLine(String line) {
  var parsedLine = DerivationLine(line);
  return TestStep((state) => state.addDerivationLine(parsedLine))
      .addsLines([parsedLine]).isQuiescent();
}

TestStep addLines(List<String> lines) => TestStep((state) {
      for (var line in lines) {
        addLine(line).check(state);
      }
    }).addsLines(anything);

TestStep<void> rule(Rule rule) => TestStep((state) => state.activateRule(rule));

TestStep<void> select(int lineIndex, String target, {int? index}) =>
    TestStep((state) {
      target = TestStep._translateChunkExpectation(target) as String;
      var line = state.derivationLines[lineIndex];
      var candidateChunks = [
        for (var chunk in line.decorated)
          if (chunk.isSelectable && chunk.text == target) chunk
      ];
      if (candidateChunks.isEmpty) {
        fail('Line ${json.encode(line.line.toString())} contains no selectable '
            'chunk matching ${json.encode(target)}');
      } else if (index == null && candidateChunks.length > 1) {
        fail('Line ${json.encode(line.line.toString())} contains '
            '${candidateChunks.length} selectable chunks matching '
            '${json.encode(target)}.  Disambiguate using "index" parameter.');
      }
      candidateChunks[index ?? 0].select();
    });

class TestStep<R> {
  final R Function(FullState) _action;

  final List<void Function(FullState)> _preChecks = [];

  final List<void Function(FullState, R)> _tests = [];

  bool _mayAddLines = false;

  TestStep(this._action);

  TestStep<R> addsExplanations(Object expectation) {
    late List<String> before;
    _preChecks.add((state) => before = state.explanations.toList());
    _tests.add((state, returnValue) {
      var after = state.explanations.toList();
      expect(after, hasLength(greaterThanOrEqualTo(before.length)));
      var added = after.sublist(before.length);
      expect(added, expectation);
    });
    return this;
  }

  TestStep<R> addsLines(Object expectation) {
    _mayAddLines = true;
    if (expectation is List<String>) {
      expectation = <DerivationLine>[
        for (var line in expectation) DerivationLine(line)
      ];
    }
    late List<DerivationLine> before;
    _preChecks.add((state) =>
        before = [for (var line in state.derivationLines) line.line]);
    _tests.add((state, returnValue) {
      var after = [for (var line in state.derivationLines) line.line];
      expect(after, hasLength(greaterThanOrEqualTo(before.length)));
      var added = after.sublist(before.length);
      expect(added, expectation);
    });
    return this;
  }

  void check(FullState state) {
    if (!_mayAddLines) {
      addsLines(isEmpty); // ignore: unused_result
    }
    for (var preCheck in _preChecks) {
      preCheck(state);
    }
    var returnValue = _action(state);
    for (var test in _tests) {
      test(state, returnValue);
    }
  }

  TestStep<R> hasSelectionState(
      {required Object? selectable,
      Object? selected = isEmpty,
      bool isSelectionNeeded = true}) {
    selectable = _translateSelectionExpectation(selectable);
    selected = _translateSelectionExpectation(selected);
    _tests.add((state, returnValue) {
      expect(state.isSelectionNeeded, isSelectionNeeded);
      var lines = state.derivationLines;
      var actualSelectable = <int, List<String>>{};
      var actualSelected = <int, List<String>>{};
      for (int i = 0; i < lines.length; i++) {
        var line = lines[i];
        for (var chunk in line.decorated) {
          if (chunk.isSelectable) {
            (actualSelectable[i] ??= []).add(chunk.text);
          }
          if (chunk.isSelected) {
            (actualSelected[i] ??= []).add(chunk.text);
          }
        }
      }
      expect(actualSelectable, selectable);
      expect(actualSelected, selected);
    });
    return this;
  }

  TestStep<R> isQuiescent() =>
      this.hasSelectionState(selectable: isEmpty, isSelectionNeeded: false);

  TestStep<R> mayAddLines() {
    _mayAddLines = true;
    return this;
  }

  TestStep<R> returns(Object? expectation) {
    _tests.add((state, returnValue) => expect(returnValue, expectation));
    return this;
  }

  TestStep<R> showsMessage(Object? expectation) {
    _tests.add((state, returnValue) => expect(state.message, expectation));
    return this;
  }

  TestStep<R> showsPreview(Object? expectation) {
    _tests.add((state, returnValue) {
      expect(state.previewLine, expectation);
    });
    return this;
  }

  static Object? _translateChunkExpectation(Object? expectation) {
    if (expectation is String) {
      DerivationLine derivationLine;
      try {
        derivationLine = DerivationLine(expectation);
      } on ParseError {
        return expectation;
      }
      return derivationLine.toString();
    } else {
      return expectation;
    }
  }

  static Object? _translateChunkExpectations(Object? expectation) {
    if (expectation is String) {
      return [_translateChunkExpectation(expectation)];
    } else if (expectation is List<String>) {
      return [for (var item in expectation) _translateChunkExpectation(item)];
    } else {
      return expectation;
    }
  }

  static Object? _translateSelectionExpectation(Object? expectation) {
    if (expectation is Map<int, Object?>) {
      return {
        for (var entry in expectation.entries)
          entry.key: _translateChunkExpectations(entry.value)
      };
    } else {
      return expectation;
    }
  }
}
