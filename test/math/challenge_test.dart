import 'package:geb/math/challenges.dart';
import 'package:geb/math/proof.dart';
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
              expect(() => checkProof(challenge),
                  throwsA(TypeMatcher<ProverFailed>()));
            });
          }
        }
      });
    }
  });
}

void checkProof(Challenge challenge) {
  var derivationState = DerivationState();
  derivationState.setupChallenge(challenge);
  Prover(derivationState).prove(challenge.goal);
  expect(derivationState.isGoalSatisfied(challenge.goal), true);
  expect(derivationState.lines.length, challenge.goalStepCount);
}
