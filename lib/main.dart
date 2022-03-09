import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:geb/widgets/base_button.dart';
import 'package:geb/widgets/custom_text_span.dart';
import 'package:geb/widgets/challenge_set_detail_menu.dart';
import 'package:geb/widgets/game_menu.dart';
import 'package:confetti/confetti.dart';


import 'math/ast.dart';
import 'math/rule_definitions.dart';
import 'math/rules.dart';
import 'math/state.dart';
import 'math/symbols.dart';

void main() => runApp(const GEBParser());

class GEBParser extends StatelessWidget {
  const GEBParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'NotoSansMath'),
      routes: {
        '/': (context) => const GEB(),
      },
    );
  }
}

class GEB extends StatefulWidget {
  const GEB();

  @override
  _GEBState createState() => _GEBState();
}

class _GEBState extends State<GEB> {
  late ConfettiController _confettiController;
  bool showGameDetail = false;
  FullState state = FullState();
  final _textController = TextEditingController();
  String messageToUser = "";
  Color validationColor = Colors.cyan;
  List<String> specialCharacters = [
    "<",
    ">",
    "P",
    "Q",
    "R",
    and,
    implies,
    or,
    prime,
    "[",
    "]",
    "~",
    forall,
    exists
  ];
  ScrollController _scrollController = ScrollController();
  bool _needsScroll = false;

  _scrollToEnd() async {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  int colorDecider(int i) {
    List<int> acceptableColors = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15];
    return acceptableColors[i % acceptableColors.length];
  }
  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    state.onGoalSatisfied = () {
              _confettiController.play();
    };
  }
  @override
  Widget build(BuildContext context) {
    if (_needsScroll) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToEnd());
      _needsScroll = false;
    }
    _disposeGestureRecognizers();
    return ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: pi*.15, // radial value
        particleDrag: 0.01, // apply drag to the confetti
        emissionFrequency: 0.09, // how often it should emit
        numberOfParticles: 30, // number of particles to emit
        gravity: 0.01, // gravity - or fall speed
        shouldLoop: false,
        colors: const [
          Colors.pink,
          Colors.red,
          Colors.deepOrange,
          Colors.orange,
          Colors.amber,
          Colors.yellow,
          Colors.lime,
          Colors.lightGreen,
          Colors.green,
          Colors.teal,
          Colors.cyan,
          Colors.lightBlue,
          Colors.blue,
          Colors.indigo,
          Colors.purple,
          Colors.deepPurple,
        ], // manually specify the colors to be used
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return GameMenuDialog((set) {
                            setState(() {
                              showGameDetail = true;
                              showDialog(
                                  barrierColor: Color(0xFAFAFA),
                                  context: context,
                                  builder: (context) {
                                    return ChallengeSetDetailDialog(set, (challenge) {
                                      setState(() {
                                        state.challenge = challenge;
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        messageToUser = "";
                                      });
                                    });
                                  });
                            });
                          });
                        });
                  });
                },
                icon: Icon(Icons.videogame_asset),
                iconSize: 90,
                color: Colors.cyan,
              ),
            )
          ],
          backgroundColor: Colors.black,
          foregroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          toolbarHeight: 90,
          flexibleSpace: Opacity(
            opacity: .6,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  alignment: Alignment.topCenter,
                  image: AssetImage("assets/images/rainbowEscher.png"),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.grey[200],
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                flex: 25,
                child: Column(
                  children: [
                    state.challenge != null
                        ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Your goal is to validate this formula: ", style: TextStyle(fontSize: 30, color: Colors.green, fontWeight: FontWeight.bold),),
                              Text(state.challenge!.goal.toString(), style: TextStyle(fontSize: 40, color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                        : Container(),
                    messageToUser != ""  ?
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 8, 8, 8),
                      child: Text(
                        messageToUser,
                        style: TextStyle(
                            fontSize: 25,
                            color: validationColor,
                            fontWeight: FontWeight.w800),
                      ),
                    ) : Container(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 8, 8, 8),
                      child: Text(
                        state.message,
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    Wrap(
                      children: [
                        for (String sc in specialCharacters)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: BaseButton(
                              onPressed: () {
                                var start = _textController.selection.start;
                                var end = _textController.selection.end;
                                setState(() {
                                  if (_textController.selection.start == -1) {
                                    start = _textController.text.length;
                                    end = _textController.text.length;
                                  }
                                  _textController.text =
                                      _textController.text.substring(0, start) +
                                          sc +
                                          _textController.text.substring(end);
                                  _textController.selection =
                                      TextSelection.fromPosition(
                                          TextPosition(offset: start + 1));
                                });
                              },
                              text: sc,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: BaseButton(
                            onPressed: () {
                              if (_textController.text.length != 0) {
                                var start = _textController.selection.start;
                                var end = _textController.selection.end;
                                setState(() {
                                  if (_textController.selection.start == -1) {
                                    start = _textController.text.length;
                                    end = _textController.text.length;
                                  }
                                  _textController.text = _textController.text
                                          .substring(0, start - 1) +
                                      _textController.text.substring(end);
                                  _textController.selection =
                                      TextSelection.fromPosition(
                                          TextPosition(offset: start - 1));
                                });
                              } else {
                                setState(() {
                                  state.undo();
                                });
                              }
                            },
                            icon: Icons.backspace,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Flexible(
                              flex: 2,
                              child: Column(
                                children: [
                                  for (int i = 0;
                                      i < state.derivationLines.length;
                                      i++)
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                              text: "${i + 1}: ",
                                              style: TextStyle(
                                                  color: Colors
                                                      .primaries[colorDecider(i)]
                                                      .withOpacity(
                                                          state.isSelectionNeeded
                                                              ? .3
                                                              : 1),
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "NotoSansMath")),
                                          for (var chunk in state
                                              .derivationLines[i].decorated)
                                            convertInteractiveTextToTextSpan(
                                                chunk, i),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Column(
                                children: [
                                  for (int i = 0;
                                      i < state.explanations.length;
                                      i++)
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                              text:
                                                  "${i + 1}: ${state.explanations[i]}",
                                              style: TextStyle(
                                                  color: Colors
                                                      .primaries[colorDecider(i)],
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "NotoSansMath")),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 4,
                            child: TextFormField(
                              onChanged: (_) {
                                setState(() {
                                });
                              },
                              controller: _textController,
                              decoration: state.isPremiseExpected ? const InputDecoration(
                                  hintText: 'Enter your premise'): null,
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: BaseButton(
                                height: 50,
                                width: 100,
                                textSize: 20,
                                onPressed: state.isPremiseExpected ? () {
                                  setState(() {
                                    try {
                                      DerivationLine line =
                                          DerivationLine(_textController.text);
                                      messageToUser =
                                          "Good work! Your feelings and formula are valid!";
                                      state.addDerivationLine(line);
                                      validationColor = Colors.cyan;
                                      _textController.text = "";
                                      _needsScroll = true;
                                    } catch (e) {
                                      validationColor = Colors.pink;
                                      messageToUser =
                                          "Your formula is bad. You have failed.️";
                                    }
                                  });
                                } : null,
                                disabled: state.isPremiseExpected && (_textController.text.length > 0)? false : true,
                                text: "Validate",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (Rule rule in ruleDefinitions)
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: BaseButton(
                          text: rule.name,
                          width: 130,
                          height: 35,
                          textSize: 17,
                          onPressed: () {
                            setState(() {
                              validationColor = Colors.cyan;
                              messageToUser = rule.description;
                              state.activateRule(rule);
                              _needsScroll = true;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
              // Flexible(
              //   flex: 1,
              //   // child: ConfettiWidget(
              //   //   confettiController: _controllerCenterRight,
              //   //   blastDirection: pi*1.1, // radial value - LEFT
              //   //   particleDrag: 0.01, // apply drag to the confetti
              //   //   emissionFrequency: 0.09, // how often it should emit
              //   //   numberOfParticles: 30, // number of particles to emit
              //   //   gravity: 0.02, // gravity - or fall speed
              //   //   shouldLoop: false,
              //   //   colors: const [
              //   //     Colors.pink,
              //   //     Colors.red,
              //   //     Colors.deepOrange,
              //   //     Colors.orange,
              //   //     Colors.amber,
              //   //     Colors.yellow,
              //   //     Colors.lime,
              //   //     Colors.lightGreen,
              //   //     Colors.green,
              //   //     Colors.teal,
              //   //     Colors.cyan,
              //   //     Colors.lightBlue,
              //   //     Colors.blue,
              //   //     Colors.indigo,
              //   //     Colors.purple,
              //   //     Colors.deepPurple,
              //   //   ], // manually specify the colors to be used
              //   // ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  final List<TapGestureRecognizer> _gestureRecognizers = [];

  void _disposeGestureRecognizers() {
    for (var recognizer in _gestureRecognizers) {
      recognizer.dispose();
    }
    _gestureRecognizers.clear();
  }

  @override
  void dispose() {
    _disposeGestureRecognizers();
    _confettiController.dispose();
    super.dispose();
  }

  TextSpan convertInteractiveTextToTextSpan(InteractiveText chunk, int i) {
    var recognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          chunk.select();
        });
      };
    _gestureRecognizers.add(recognizer);
    return CustomTextSpan(
        text: "${chunk.text}",
        recognizer: recognizer,
        style: TextStyle(
            backgroundColor: chunk.isSelected
                ? Colors.amberAccent.withOpacity(.8)
                : Colors.black.withOpacity(0),
            color: chunk.isSelectable || !state.isSelectionNeeded
                ? Colors.primaries[colorDecider(i)]
                : Colors.primaries[colorDecider(i)].withOpacity(.3),
            fontWeight: chunk.isSelectable || !state.isSelectionNeeded
                ? FontWeight.bold
                : FontWeight.w100,
            fontFamily: "NotoSansMath"));
  }
}
