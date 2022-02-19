import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SpecialCharacterButton extends StatelessWidget {
  final void Function()? onPressed;
  final String? text;

  const SpecialCharacterButton({
    Key? key,
    this.onPressed,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var gradientStart = Color(0xff4583bb);
    var gradientEnd = Color(0xff64B6FF);
    var buttonColor = Colors.white;

    return SizedBox(
      width: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.all(0)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)))),
        child: Container(
          width: 50,
          height: 50,
          child: Ink(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[gradientStart, gradientEnd],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(15.0)),
            child: Container(
              constraints: BoxConstraints(maxWidth: 55.0, minHeight: 55.0),
              alignment: Alignment.center,
              child: Text(
                text!,
                textAlign: TextAlign.center,
                style: TextStyle(color: buttonColor, fontSize: 30, fontFamily: "Chalkboard"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
