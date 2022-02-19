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
  String text = "";
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
            FractionallySizedBox(
              widthFactor: .5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (String sc in specialCharacters)
                  BaseButton(
                    onPressed: () {
                      setState(() {
                        _textController.text = text + sc;
                        text = text + sc;
                      });
                    },
                    text: sc,
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
                      onChanged: (value) {
                        setState(() {
                          text = _textController.text;
                        });
                      },
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
                          Formula(text);
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
              child: Text("You have typed $text"),
            ),
            Text("Please select the correct answer. What is this?"),
            DropDownMenu(),
          ],
        ),
      ),
    );
  }
}
