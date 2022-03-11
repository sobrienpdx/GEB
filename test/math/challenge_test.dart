import 'package:geb/math/challenges.dart';
import 'package:geb/math/kernel.dart';
import 'package:geb/math/prover.dart';
import 'package:test/test.dart';

main() {
  group('proofs:', () {
    for (var challengeSet in challengeSets) {
      group('${challengeSet.name}:', () {
        for (var challenge in challengeSet.challenges) {
          if (challenge.verified) {
            test('$challenge', () {
              checkProof(challenge);
            });
          } else {
            test('$challenge (expected to fail)', () {
              expect(() => checkProof(challenge), throwsA(anything));
            });
          }
        }
      });
    }
  });
}

void checkProof(Challenge challenge) {
  var theorems = <Theorem>[];
  Assumption? assumptions;
  for (var line in challenge.initialLines) {
    var newTheorem = assume(assumptions, line);
    assumptions = newTheorem.assumptions!;
    for (int i = 0; i < theorems.length; i++) {
      theorems[i] = carryOver(assumptions, theorems[i])!;
    }
    theorems.add(newTheorem);
  }
  var goal = challenge.goal;
  Theorem? result;
  for (var theorem in theorems) {
    result = rewrite(theorem, goal);
    if (result != null) break;
  }
  if (result == null) throw 'TODO(paul)';
  var lines = <String>[
    for (var theorem in theorems) '${theorem.formula}\tgiven'
  ];
  var seenTheorems = {...theorems};
  _toProofLines(result, lines, seenTheorems);
  print(lines.join('\n'));
}

void _toProofLines(
    Theorem theorem, List<String> lines, Set<Theorem> seenTheorems) {
  if (!seenTheorems.add(theorem)) return;
  if (theorem.explanation == 'pop fantasy') throw 'TODO(paul)';
  for (var prerequisite in theorem.prerequisites) {
    _toProofLines(prerequisite, lines, seenTheorems);
  }
  lines.add('${theorem.formula}\t${theorem.explanation}');
}
