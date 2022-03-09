import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geb/math/challenges.dart';

class GameDetailDialog extends StatefulWidget {
  final void Function (Challenge challenge) onChallengeSelection;
  final ChallengeSet set;
  GameDetailDialog(this.set, this.onChallengeSelection,);
  @override
  _GameDetailDialog createState() => _GameDetailDialog();
}

class _GameDetailDialog extends State<GameDetailDialog> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 500,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                "${widget.set.name}",
                style: TextStyle(
                    color: Color(0xFF3B7924), fontWeight: FontWeight.bold, fontSize: 40),
              ),
            ),      for (var challenge in widget.set.challenges)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  onPressed: () {
                    widget.onChallengeSelection(challenge);
                   },
                  child: Text(challenge.goal.toString(), style: TextStyle(color: Color(
                      0x820D1D07)),),
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0x8296BA89)),
                  ),
                ),
              )
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Back")),
      ],
    );
  }
}