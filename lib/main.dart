
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geb/widgets/base_button.dart';
import 'package:geb/widgets/custom_text_span.dart';

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
  FullState state = FullState();
  final _textController = TextEditingController();
  String messageToUser ="";
  Color validationColor = Colors.indigo;
  List<String> specialCharacters = ["<", ">", "P", "Q", "R", and, implies, or, prime, "[", "]", "~", forall, exists];

  int colorDecider(int i) {
    List<int> acceptableColors = [0,1,2,3,4,5,6,7,8,9,10,13,14,15];
    return acceptableColors[i%acceptableColors.length];
  }


  @override
  Widget build(BuildContext context) {
    _disposeGestureRecognizers();
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  flex: 3,
                  child: Column(
                    children: [
                      messageToUser != "" ?
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 8, 8, 8),
                        child: Text(
                          messageToUser,
                          style: TextStyle(fontSize: 25, color: validationColor, fontWeight: FontWeight.w800),
                        ),
                      ) : Container(),
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
                                    _textController.text = _textController.text.substring(0, start) + sc +_textController.text.substring(end);
                                    _textController.selection= TextSelection.fromPosition(TextPosition(offset: start +1));
                                  });
                                },
                                text: sc,
                              ),
                            ),
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
                                  _textController.text = _textController.text.substring(0, start -1) +_textController.text.substring(end);
                                  _textController.selection= TextSelection.fromPosition(TextPosition(offset: start -1));
                                });
                              },
                              icon: Icons.backspace,
                            ),
                          ),
                        ],
                      ),
                      for (int i= 0; i< state.derivationLines.length; i++ )
                      RichText(
                        text: TextSpan(children: [
                          for (var chunk in state.derivationLines[i].decorated)
                            convertInteractiveTextToTextSpan(chunk, i),
                        ],
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
                                controller: _textController,
                                decoration: const InputDecoration(hintText: 'Type stuff'),
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
                                  onPressed: () {
                                    setState(() {
                                      try {
                                        DerivationLine line = DerivationLine(_textController.text);
                                        messageToUser = "Good work! Your feelings and formula are valid!";
                                        state.addDerivationLine(line);
                                        validationColor = Colors.indigo;
                                      } catch (e) {
                                        validationColor = Colors.pink;
                                        messageToUser = "☹️ ☹️ ☹️ Your formula is bad. You should feel bad. ☹️ ☹️ ☹️ ️";
                                      }
                                    });
                                  },
                                  text: "Validate",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text("You have typed: ${_textController.text}"),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (Rule rule in ruleDefinitions)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: BaseButton(
                          text: rule.name,
                          width: 130,
                          height: 35,
                          textSize: 17,
                          onPressed: () {
                            setState(() {
                              state.activateRule(rule);
                              messageToUser = state.message;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
    super.dispose();
  }

  TextSpan convertInteractiveTextToTextSpan(InteractiveText chunk, int i) {
    var recognizer = TapGestureRecognizer()..onTap = () {
        setState(() {
          chunk.select();
        });
      };
    _gestureRecognizers.add(recognizer);
    return CustomTextSpan(text: "${i+1}: ${chunk.text}",
      recognizer: recognizer,
      style: TextStyle(
          backgroundColor: chunk.isSelected ? Colors.black.withOpacity(.9) : Colors.black.withOpacity(0),
          color: chunk.isSelectable || !state.isSelectionNeeded ? Colors.primaries[colorDecider(i)] : Colors.primaries[colorDecider(i)].withOpacity(.3),
          fontWeight: chunk.isSelectable || !state.isSelectionNeeded  ? FontWeight.bold: FontWeight.w100,
          fontFamily: "NotoSansMath"));
  }
}
