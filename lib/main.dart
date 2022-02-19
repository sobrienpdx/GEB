import 'package:flutter/material.dart';
import 'package:geb/widgets/drop_down_menu.dart';
import 'package:geb/widgets/special_character_button.dart';

void main() => runApp(const GEBParser());

class GEBParser extends StatelessWidget {
  const GEBParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SpecialCharacterButton(
                  onPressed: () {
                    setState(() {
                      _textController.text = text + "p";
                      text = text + "p";
                    });
                  },
                  text: "p",
                ),
              ],
            ),
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
