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
            }, solo: challenge.solo); // ignore: deprecated_member_use
          } else {
            test('$challenge (expected to fail)', () {
              expect(() => checkProof(challenge), throwsA(anything));
            }, solo: challenge.solo); // ignore: deprecated_member_use
          }
        }
      });
    }
  });
}

void checkProof(Challenge challenge) {
  var proverState = ProverState();
  List<Theorem> givens = [for (var line in challenge.initialLines) given(line)];
  for (var theorem in givens) {
    proverState.addTheorem(theorem);
  }
  challenge.strategy.to(challenge.goal).run(proverState);
  var result = proverState.getTheorem(challenge.goal);
  if (result == null) throw 'TODO(paul)';
  var lines = <String>[for (var theorem in givens) theorem.toProofLine()];
  var seenTheorems = {...givens};
  _toProofLines(result, lines, seenTheorems);
  print(lines.join('\n'));
  expect(lines, hasLength(challenge.goalStepCount));
}

void _toProofLines(
    Theorem theorem, List<String> lines, Set<Theorem> seenTheorems) {
  if (!seenTheorems.add(theorem)) return;
  for (var prerequisite in theorem.prerequisites) {
    _toProofLines(prerequisite, lines, seenTheorems);
  }
  if (theorem is PopFantasyTheorem) {
    lines.add('[\tpush fantasy');
    var premise = theorem.premise.asTheorem;
    lines.add(premise.toProofLine());
    _toProofLines(theorem.conclusion, lines, {premise});
    lines.add(']\tpop fantasy');
  }
  lines.add(theorem.toProofLine());
}

extension _ on Theorem {
  String toProofLine() => '$formula\t$explanation';
}
