import 'package:flutter/material.dart';
import 'package:geb/widgets/base_button.dart';

import 'math/ast.dart';
import 'math/rule_definitions.dart';
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
  final _textController = TextEditingController();
  String messageToUser ="";
  Color validationColor = Colors.indigo;
  List<String> specialCharacters = ["<", ">", "P", "Q", "R", and, implies, or, prime, "[", "]", "~", forall, exists];
  List<String> ruleDefinitions = [joiningRule, separationRule, doubleTildeRule, fantasyRule, carryOverRule, detachmentRule, contrapositiveRule, deMorgansRule, switcherooRule];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            messageToUser != "" ?
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  messageToUser,
                style: TextStyle(fontSize: 25, color: validationColor, fontWeight: FontWeight.w800),
              ),
            ) : Container(),
            SizedBox(
              width: 850,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (String sc in specialCharacters)
                  BaseButton(
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
                  BaseButton(
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
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 500,
                            child: TextFormField(
                              controller: _textController,
                              decoration: const InputDecoration(hintText: 'Type stuff'),
                            ),
                          ),
                          BaseButton(
                            height: 50,
                            width: 100,
                            textSize: 20,
                            onPressed: () {
                              setState(() {
                                try {
                                  Formula(_textController.text);
                                  messageToUser = "Good work! Your feelings and formula are valid!";
                                } catch (e) {
                                  validationColor = Colors.pink;
                                  messageToUser = "☹️ ☹️ ☹️ Your formula is bad. You should feel bad. ☹️ ☹️ ☹️ ️";
                                }
                              });
                            },
                            text: "Validate",
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (String rule in ruleDefinitions)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BaseButton(
                        text: "I'm a rule",
                        width: 120,
                        height: 35,
                        textSize: 20,
                        onPressed: () {
                          setState(() {
                            if (messageToUser != rule) {
                              messageToUser = rule;
                            } else {
                              messageToUser = "";
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),



          ],
        ),
      ),
    );
  }
}
