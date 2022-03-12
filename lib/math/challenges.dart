import 'ast.dart';
import 'prover.dart';

final List<ChallengeSet> challengeSets = [
  ChallengeSet('Switcheroo', [
    Challenge(Formula('<~P->Q>'), 4,
        initialLines: [Formula('<P&Q>'), Formula('<P|Q>'), Formula('<P->Q>')],
        requiredRules: {'switcheroo'}),
    Challenge(Formula('<~a=b->a=c>'), 3,
        initialLines: [Formula('<a=b|a=c>'), Formula('~<a=b|a=c>')],
        requiredRules: {'switcheroo'}),
    Challenge(Formula('<~P->~P>'), 4,
        initialLines: [Formula('<~P|P>'), Formula('<P|P>'), Formula('<P|~P>')],
        requiredRules: {'switcheroo'}),
    Challenge(Formula('<P|Q>'), 4, initialLines: [
      Formula('<~P->Q>'),
      Formula('<P->Q>'),
      Formula('<P->~Q>')
    ], requiredRules: {
      'switcheroo'
    }),
    Challenge(Formula('<P|~P>'), 5, initialLines: [
      Formula('<P->P>'),
      Formula('<P->~P>'),
      Formula('<~P->P>'),
      Formula('<~P->~P>')
    ], requiredRules: {
      'switcheroo'
    }),
  ]),
  ChallengeSet('Fantasy, carry over', [
    Challenge(Formula('<P->P>'), 4,
        strategy: Fantasy(), requiredRules: {'fantasy'}),
    Challenge(Formula('<a=0->a=0>'), 4,
        strategy: Fantasy(), requiredRules: {'fantasy'}),
    Challenge(Formula('<P->Q>'), 6,
        initialLines: [Formula('Q')],
        strategy: Fantasy(),
        requiredRules: {'fantasy', 'carry over'}),
    Challenge(Formula('<(a+b)=0->a=0>'), 6,
        initialLines: [Formula('a=0')],
        strategy: Fantasy(),
        requiredRules: {'fantasy', 'carry over'}),
    Challenge(Formula('<P-><Q->Q>>'), 8,
        strategy: Fantasy(strategy: Fantasy()), requiredRules: {'fantasy'}),
    Challenge(Formula('<P-><Q->P>>'), 9,
        strategy: Fantasy(strategy: Fantasy()),
        requiredRules: {'fantasy', 'carry over'}),
    Challenge(Formula('<P-><Q-><R->P>>>'), 14,
        strategy: Fantasy(strategy: Fantasy(strategy: Fantasy())),
        requiredRules: {'fantasy', 'carry over'}),
    Challenge(Formula('<~Q->~Q>'), 4,
        strategy: Fantasy(), requiredRules: {'fantasy'}),
    Challenge(Formula('<P|~P>'), 5,
        strategy: Fantasy().to(Formula('<~P->~P>')).then(rewrite),
        requiredRules: {'fantasy', 'switcheroo'}),
  ]),
  ChallengeSet('Detachment', [
    Challenge(Formula('Q'), 3,
        initialLines: [Formula('P'), Formula('<P->Q>')],
        strategy: detach,
        requiredRules: {'detachment'}),
    Challenge(Formula('<R->Q>'), 10,
        initialLines: [Formula('<P->Q>'), Formula('<R->P>')],
        strategy: ApplyEverywhere(detach),
        requiredRules: {'detachment', 'fantasy', 'carry over'}),
    Challenge(Formula('<P->R>'), 10,
        initialLines: [Formula('<P->Q>'), Formula('<Q->R>')],
        strategy: ApplyEverywhere(detach),
        requiredRules: {'detachment', 'fantasy', 'carry over'}),
    Challenge(Formula('<P|R>'), 12,
        initialLines: [Formula('<P|Q>'), Formula('<Q->R>')],
        strategy: ApplyEverywhere(detach),
        requiredRules: {'detachment', 'fantasy', 'carry over', 'switcheroo'}),
    Challenge(Formula("<<P'->Q>->R>"), 17,
        initialLines: [Formula('<<P->Q>->R>'), Formula("<P->P'>")],
        strategy: ApplyEverywhere(detach),
        requiredRules: {'detachment', 'fantasy', 'carry over'}),
    Challenge(Formula("<P-><Q->R'>>"), 17,
        initialLines: [Formula('<P-><Q->R>>'), Formula("<R->R'>")],
        strategy: ApplyEverywhere(detach),
        requiredRules: {'detachment', 'fantasy', 'carry over'}),
  ]),
  ChallengeSet('Contrapositive, De Morgan', [
    Challenge(Formula('<<P|Q>->~<~P&~Q>>'), 6,
        verified: false, requiredRules: {}),
    Challenge(Formula('<~<~P&~Q>-><P|Q>>'), 6,
        verified: false, requiredRules: {}),
  ]),
  ChallengeSet('Detachment, separation', [
    Challenge(Formula('<<P-><Q&R>>-><P->Q>>'), 11,
        verified: false, requiredRules: {}),
    Challenge(Formula('<<P-><Q&R>>-><P->R>>'), 11,
        verified: false, requiredRules: {}),
  ]),
  ChallengeSet('Joining', [
    Challenge(Formula('<<<P->Q>&<P->R>>-><P-><Q&R>>>'), 14,
        verified: false, requiredRules: {}),
    Challenge(Formula('<<P-><Q&R>>-><<P->Q>&<P->R>>>'), 19,
        verified: false, requiredRules: {}),
  ]),
  ChallengeSet('Double Tilde', [
    Challenge(Formula('~<P&~P>'), 15, verified: false, requiredRules: {}),
    Challenge(Formula('<<<P->Q>|<P->R>>-><P-><Q|R>>>'), 30,
        verified: false, requiredRules: {}),
  ]),
  ChallengeSet('Intermediate propositional calculus', [
    // 6 rules
    Challenge(Formula('<<<P|Q>->R>-><P->R>>'), 14,
        verified: false, requiredRules: {}),
    Challenge(Formula('<<<P|Q>->R>-><Q->R>>'), 14,
        verified: false, requiredRules: {}),
  ]),
  ChallengeSet('Advanced propositional calculus', [
    // 7 rules
    Challenge(Formula('<<<P->R>&<Q->R>>-><<P|Q>->R>>'), 18,
        verified: false, requiredRules: {}),
    Challenge(Formula('<<<P|Q>->R>-><<P->R>&<Q->R>>>'), 24,
        verified: false, requiredRules: {}),
    Challenge(Formula('<<<P->R>|<Q->R>>-><<P&Q>->R>>'), 41,
        verified: false, requiredRules: {}),
  ]),
];

class Challenge {
  final List<Formula> initialLines;

  final Formula goal;

  final int goalStepCount;

  final bool verified;

  final Strategy strategy;

  final bool solo;

  final Set<String> requiredRules;

  Challenge(this.goal, this.goalStepCount,
      {this.initialLines = const [],
      this.verified = true,
      this.strategy = rewrite,
      required this.requiredRules,
      @deprecated this.solo = false});

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
