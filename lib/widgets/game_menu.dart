import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geb/math/challenges.dart';

class GameMenuDialog extends StatefulWidget {
  final void Function(ChallengeSet set) onSetSelection;

  GameMenuDialog(this.onSetSelection);

  @override
  _GameMenuDialog createState() => _GameMenuDialog();
}

class _GameMenuDialog extends State<GameMenuDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 500,
        width: 400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                "Pick a challenge",
                style: TextStyle(
                    color: Color(0xFF76310D),
                    fontWeight: FontWeight.bold,
                    fontSize: 40),
              ),
            ),
            Expanded(
                child: Scrollbar(
                  isAlwaysShown: true,
                  child: ListView(children: [
              for (var set in challengeSets)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: OutlinedButton(
                        onPressed: () {
                          widget.onSetSelection(set);
                        },
                        child: Text(
                          set.name,
                          style: TextStyle(color: Color(0xFF3B1807)),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Color(0x82CE6E3A)),
                        ),
                      ),
                    ),
                  )
            ]),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Close")),
      ],
    );
  }
}
