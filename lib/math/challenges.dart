import 'ast.dart';

final List<ChallengeSet> challengeSets = [
  ChallengeSet('Fantasy, carry over', [
    Challenge(Formula('<P->P>'), 4),
    Challenge(Formula('<P-><Q->Q>>'), 8),
    Challenge(Formula('<P-><Q->P>>'), 9),
  ]),
  ChallengeSet('Switcheroo', [
    Challenge(Formula('<P|~P>'), 5),
  ]),
  ChallengeSet('Contrapositive, De Morgan', [
    Challenge(Formula('<<P|Q>->~<~P&~Q>>'), 6),
    Challenge(Formula('<~<~P&~Q>-><P|Q>>'), 6),
  ]),
  ChallengeSet('Detachment, separation', [
    Challenge(Formula('<<P-><Q&R>>-><P->Q>>'), 11),
    Challenge(Formula('<<P-><Q&R>>-><P->R>>'), 11),
  ]),
  ChallengeSet('Joining', [
    Challenge(Formula('<<<P->Q>&<P->R>>-><P-><Q&R>>>'), 14),
    Challenge(Formula('<<P-><Q&R>>-><<P->Q>&<P->R>>>'), 19),
  ]),
  ChallengeSet('Double Tilde', [
    Challenge(Formula('~<P&~P>'), 15),
    Challenge(Formula('<<<P->Q>|<P->R>>-><P-><Q|R>>>'), 30),
  ]),
  ChallengeSet('Intermediate propositional calculus', [
    // 6 rules
    Challenge(Formula('<<<P|Q>->R>-><P->R>>'), 14),
    Challenge(Formula('<<<P|Q>->R>-><Q->R>>'), 14),
  ]),
  ChallengeSet('Advanced propositional calculus', [
    // 7 rules
    Challenge(Formula('<<<P->R>&<Q->R>>-><<P|Q>->R>>'), 18),
    Challenge(Formula('<<<P|Q>->R>-><<P->R>&<Q->R>>>'), 24),
    Challenge(Formula('<<<P->R>|<Q->R>>-><<P&Q>->R>>'), 41),
  ]),
];

class Challenge {
  final List<DerivationLine> initialLines;

  final Formula goal;

  final int goalStepCount;

  Challenge(this.goal, this.goalStepCount, {this.initialLines = const []});
}

class ChallengeSet {
  final String name;

  final List<Challenge> challenges;

  ChallengeSet(this.name, this.challenges);
}
