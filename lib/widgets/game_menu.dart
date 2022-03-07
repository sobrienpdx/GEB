import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geb/math/challenges.dart';

class GameMenuDialog extends StatefulWidget {
  @override
  _GameMenuDialog createState() => _GameMenuDialog();
}

class _GameMenuDialog extends State<GameMenuDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        children: [
          Text(
            "Pick a challenge",
            style: TextStyle(
                color: Colors.green, fontWeight: FontWeight.bold, fontSize: 30),
          ),
          for (var challenge in challengeSets)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                onPressed: () {},
                child: Text(challenge.name),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0x82D9BEF6)),
                ),
              ),
            )
        ],
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
