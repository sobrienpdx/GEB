import 'package:flutter/material.dart';
import 'package:geb/widgets/drop_down_menu.dart';
import 'package:geb/widgets/base_button.dart';

import 'math/ast.dart';
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
  String validationDeclaration ="";
  Color validationColor = Colors.indigo;
  List<String> specialCharacters = ["<", ">", "P", "Q", "R", and, implies, or, prime, "[", "]", "~"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            validationDeclaration != "" ?
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  validationDeclaration,
                style: TextStyle(fontSize: 50, color: validationColor, fontWeight: FontWeight.w800),
              ),
            ) : Container(),
            SizedBox(
              width: 800,
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
                          validationDeclaration = "Good work! Your feelings and formula are valid!";
                        } catch (e) {
                          validationColor = Colors.pink;
                          validationDeclaration = "☹️ ☹️ ☹️ Your formula is bad. You should feel bad. ☹️ ☹️ ☹️ ️";
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
              child: Text("You have typed ${_textController.text}"),
            ),
            Text("Please select the correct answer. What is this?"),
            DropDownMenu(),
          ],
        ),
      ),
    );
  }
}
