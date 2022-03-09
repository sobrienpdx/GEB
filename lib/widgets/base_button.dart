import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaseButton extends StatelessWidget {
  final void Function()? onPressed;
  final String? text;
  final IconData? icon;
  final double width;
  final double height;
  final double textSize;

  const BaseButton(
      {Key? key,
      this.onPressed,
      this.text,
      this.icon,
      this.height = 50,
      this.width = 50,
      this.textSize = 30})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var gradientStart = Color(0xff4583bb);
    var gradientEnd = Color(0xff64B6FF);
    var buttonColor = Colors.white;

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.all(0)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)))),
        child: Container(
          width: width,
          height: height,
          child: Ink(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[gradientStart, gradientEnd],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(15.0)),
            child: Container(
              constraints: BoxConstraints(maxWidth: width, minHeight: height),
              alignment: Alignment.center,
              child: text != null
                  ? Text(text!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: buttonColor, fontSize: textSize))
                  : Icon(icon),
            ),
          ),
        ),
      ),
    );
  }
}
