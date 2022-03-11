import 'ast.dart';
import 'prover.dart';

final List<ChallengeSet> challengeSets = [
  ChallengeSet('Switcheroo', [
    Challenge(Formula('<~P->Q>'), 2, initialLines: [Formula('<P|Q>')]),
    Challenge(Formula('<~a=b->a=c>'), 2, initialLines: [Formula('<a=b|a=c>')]),
    Challenge(Formula('<~P->~P>'), 2, initialLines: [Formula('<P|~P>')]),
    Challenge(Formula('<P|Q>'), 2, initialLines: [Formula('<~P->Q>')]),
    Challenge(Formula('<a=b|a=c>'), 2, initialLines: [Formula('<~a=b->a=c>')]),
    Challenge(Formula('<P|~P>'), 2, initialLines: [Formula('<~P->~P>')]),
  ]),
  ChallengeSet('Fantasy, carry over', [
    Challenge(Formula('<P->P>'), 4, strategy: Fantasy()),
    Challenge(Formula('<a=0->a=0>'), 4, strategy: Fantasy()),
    Challenge(Formula('<P->Q>'), 6,
        initialLines: [Formula('Q')], strategy: Fantasy()),
    Challenge(Formula('<(a+b)=0->a=0>'), 6,
        initialLines: [Formula('a=0')], strategy: Fantasy()),
    Challenge(Formula('<P-><Q->Q>>'), 8,
        strategy: Fantasy(strategy: Fantasy())),
    Challenge(Formula('<P-><Q->P>>'), 9,
        strategy: Fantasy(strategy: Fantasy())),
    Challenge(Formula('<P-><Q-><R->P>>>'), 14,
        strategy: Fantasy(strategy: Fantasy(strategy: Fantasy()))),
    Challenge(Formula('<~Q->~Q>'), 4, strategy: Fantasy()),
    Challenge(Formula('<P|~P>'), 5,
        strategy: SubGoal(Formula('<~P->~P>'), strategy: Fantasy())),
  ]),
  ChallengeSet('Contrapositive, De Morgan', [
    Challenge(Formula('<<P|Q>->~<~P&~Q>>'), 6, verified: false),
    Challenge(Formula('<~<~P&~Q>-><P|Q>>'), 6, verified: false),
  ]),
  ChallengeSet('Detachment, separation', [
    Challenge(Formula('<<P-><Q&R>>-><P->Q>>'), 11, verified: false),
    Challenge(Formula('<<P-><Q&R>>-><P->R>>'), 11, verified: false),
  ]),
  ChallengeSet('Joining', [
    Challenge(Formula('<<<P->Q>&<P->R>>-><P-><Q&R>>>'), 14, verified: false),
    Challenge(Formula('<<P-><Q&R>>-><<P->Q>&<P->R>>>'), 19, verified: false),
  ]),
  ChallengeSet('Double Tilde', [
    Challenge(Formula('~<P&~P>'), 15, verified: false),
    Challenge(Formula('<<<P->Q>|<P->R>>-><P-><Q|R>>>'), 30, verified: false),
  ]),
  ChallengeSet('Intermediate propositional calculus', [
    // 6 rules
    Challenge(Formula('<<<P|Q>->R>-><P->R>>'), 14, verified: false),
    Challenge(Formula('<<<P|Q>->R>-><Q->R>>'), 14, verified: false),
  ]),
  ChallengeSet('Advanced propositional calculus', [
    // 7 rules
    Challenge(Formula('<<<P->R>&<Q->R>>-><<P|Q>->R>>'), 18, verified: false),
    Challenge(Formula('<<<P|Q>->R>-><<P->R>&<Q->R>>>'), 24, verified: false),
    Challenge(Formula('<<<P->R>|<Q->R>>-><<P&Q>->R>>'), 41, verified: false),
  ]),
];

class Challenge {
  final List<Formula> initialLines;

  final Formula goal;

  final int goalStepCount;

  final bool verified;

  final Strategy strategy;

  Challenge(this.goal, this.goalStepCount,
      {this.initialLines = const [],
      this.verified = true,
      this.strategy = const NullStrategy()});

  String toString() {
    var s = goalStepCount == 1 ? '' : 's';
    var result = StringBuffer('Prove $goal in $goalStepCount step$s');
    if (initialLines.isNotEmpty) {
      result.write(' given ');
      for (int i = 0; i < initialLines.length; i++) {
        result.write(initialLines[i]);
        if (initialLines.length > 2) {
          result.write(',');
        }
        if (i + 2 == initialLines.length) {
          result.write(' and ');
        } else {
          result.write(' ');
        }
      }
    }
    return result.toString();
  }
}

class ChallengeSet {
  final String name;

  final List<Challenge> challenges;

  ChallengeSet(this.name, this.challenges);
}
