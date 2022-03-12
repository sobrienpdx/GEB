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
    Challenge(Formula('P'), 4,
        initialLines: [Formula('R'), Formula('<R->P>'), Formula('<P->R>')],
        strategy: detach,
        requiredRules: {'detachment'}),
    Challenge(Formula('R'), 5,
        initialLines: [Formula('<P->Q>'), Formula('<Q->R>'), Formula('P')],
        strategy: detach.to(Formula('Q')).then(detach),
        requiredRules: {'detachment'}),
    Challenge(Formula('Q'), 6,
        initialLines: [Formula('<<P->P>->Q>')],
        strategy: Fantasy().to(Formula('<P->P>')).then(detach),
        requiredRules: {'fantasy', 'detachment'}),
    Challenge(Formula('Q'), 7,
        strategy: Fantasy()
            .to(Formula('<~P->~P>'))
            .then(rewrite)
            .to(Formula('<P|~P>'))
            .then(detach),
        initialLines: [Formula('<<P|~P>->Q>')],
        requiredRules: {'fantasy', 'switcheroo', 'detachment'}),
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
    Challenge(Formula('<R|Q>'), 12,
        initialLines: [Formula('<P|Q>'), Formula('<~R->~P>')],
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
  ChallengeSet('Contrapositive', [
    Challenge(Formula('<~Q->~P>'), 6,
        initialLines: [
          Formula('<Q->P>'),
          Formula('<P->Q>'),
          Formula('<P->~Q>'),
          Formula('<~P->Q>'),
          Formula('<~P->~Q>')
        ],
        strategy: trivialRewrite,
        requiredRules: {'contrapositive'}),
    Challenge(Formula('<~~Q->~P>'), 5,
        initialLines: [
          Formula('<P->Q>'),
          Formula('<P->~Q>'),
          Formula('<~P->Q>'),
          Formula('<~P->~Q>')
        ],
        strategy: trivialRewrite,
        requiredRules: {'contrapositive'}),
    Challenge(Formula('<Q->P>'), 5,
        initialLines: [
          Formula('<P->Q>'),
          Formula('<P->~Q>'),
          Formula('<~P->Q>'),
          Formula('<~P->~Q>')
        ],
        strategy: trivialRewrite,
        requiredRules: {'contrapositive'}),
    Challenge(Formula('<~Q->~~P>'), 5,
        initialLines: [
          Formula('<P->Q>'),
          Formula('<P->~Q>'),
          Formula('<~P->Q>'),
          Formula('<~P->~Q>')
        ],
        strategy: trivialRewrite,
        requiredRules: {'contrapositive'}),
    Challenge(Formula('~P'), 5,
        initialLines: [Formula('~R'), Formula('<R->P>'), Formula('<P->R>')],
        strategy: trivialRewrite.to(Formula('<~R->~P>')).then(detach),
        requiredRules: {'detachment', 'contrapositive'}),
    Challenge(Formula('~R'), 7,
        initialLines: [Formula('<Q->P>'), Formula('<R->Q>'), Formula('~P')],
        strategy: trivialRewrite
            .to(Formula('<~P->~Q>'))
            .then(trivialRewrite)
            .to(Formula('<~Q->~R>'))
            .then(detach)
            .to(Formula('~Q'))
            .then(detach),
        requiredRules: {'detachment', 'contrapositive'}),
    Challenge(Formula('<P|R>'), 13,
        initialLines: [Formula('<P|Q>'), Formula('<~R->~Q>')],
        strategy:
            trivialRewrite.to(Formula('<Q->R>')).then(ApplyEverywhere(detach)),
        requiredRules: {
          'detachment',
          'fantasy',
          'carry over',
          'switcheroo',
          'contrapositive'
        }),
    Challenge(Formula('<R|Q>'), 13,
        initialLines: [Formula('<P|Q>'), Formula('<P->R>')],
        strategy: trivialRewrite
            .to(Formula('<~R->~P>'))
            .then(ApplyEverywhere(detach)),
        requiredRules: {
          'detachment',
          'fantasy',
          'carry over',
          'switcheroo',
          'contrapositive'
        }),
  ]),
  ChallengeSet('Joining, separation', [
    Challenge(Formula('<P&Q>'), 4,
        initialLines: [Formula('P'), Formula('Q'), Formula('R')],
        strategy: join,
        requiredRules: {'joining'}),
    Challenge(Formula('P'), 3,
        initialLines: [Formula('<P&Q>'), Formula('<Q&R>')],
        strategy: separate,
        requiredRules: {'separation'}),
    Challenge(Formula('<Q&P>'), 4,
        initialLines: [Formula('<P&Q>')],
        strategy: separate
            .to(Formula('Q'))
            .then(separate)
            .to(Formula('P'))
            .then(join),
        requiredRules: {'joining', 'separation'}),
    Challenge(Formula('<<P->Q>&Q>'), 5,
        initialLines: [Formula('<P&<P->Q>>')],
        strategy: separate
            .to(Formula('<P->Q>'))
            .then(separate)
            .to(Formula('P'))
            .then(detach)
            .to(Formula('Q'))
            .then(join),
        requiredRules: {'joining', 'separation', 'detachment'}),
    Challenge(Formula("<<~P->~Q>&<R|R'>>"), 6, initialLines: [
      Formula("<<Q->P>&<~R->R'>>")
    ], requiredRules: {
      'joining',
      'separation',
      'switcheroo',
      'contrapositive'
    }),
    Challenge(Formula('<<P-><Q&R>>-><P->Q>>'), 11,
        strategy: Fantasy(
            strategy:
                Fantasy(strategy: detach.to(Formula('<Q&R>')).then(separate))),
        requiredRules: {'detachment', 'separation', 'fantasy', 'carry over'}),
    Challenge(Formula('<<P-><Q&R>>-><P->R>>'), 11,
        strategy: Fantasy(
            strategy:
                Fantasy(strategy: detach.to(Formula('<Q&R>')).then(separate))),
        requiredRules: {'detachment', 'separation', 'fantasy', 'carry over'}),
    Challenge(Formula('<P->R>'), 13,
        initialLines: [Formula("<P-><Q&Q'>>"), Formula("<<Q'&Q>->R>")],
        strategy: Fantasy(
            strategy: detach
                .to(Formula("<Q&Q'>"))
                .then(separate)
                .to(Formula('Q'))
                .then(separate)
                .to(Formula("Q'"))
                .then(join)
                .to(Formula("<Q'&Q>"))
                .then(detach)),
        requiredRules: {
          'joining',
          'separation',
          'detachment',
          'fantasy',
          'carry over'
        }),
  ]),
  ChallengeSet('De Morgan', [
    Challenge(Formula('~<P|Q>'), 5, initialLines: [
      Formula('<~P|~Q>'),
      Formula('<P&~Q>'),
      Formula('<~P&~Q>'),
      Formula('<P->~Q>')
    ], requiredRules: {
      'De Morgan'
    }),
    Challenge(Formula('<~P&~Q>'), 5, initialLines: [
      Formula('<P|Q>'),
      Formula('~<P&Q>'),
      Formula('<~P->Q>'),
      Formula('~<P|Q>')
    ], requiredRules: {
      'De Morgan'
    }),
    Challenge(Formula('~<P|Q>'), 6,
        initialLines: [
          Formula('P'),
          Formula('~P'),
          Formula('Q'),
          Formula('~Q')
        ],
        strategy: join.to(Formula('<~P&~Q>')).then(trivialRewrite),
        requiredRules: {'De Morgan', 'joining'}),
    Challenge(Formula('R'), 5,
        initialLines: [Formula('P'), Formula('Q'), Formula('<<P&Q>->R>')],
        strategy: join.to(Formula('<P&Q>')).then(detach),
        requiredRules: {'joining', 'detachment'}),
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
