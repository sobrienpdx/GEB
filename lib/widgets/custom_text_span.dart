import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// TextSpan class that works around a flutter bug
class CustomTextSpan extends TextSpan {
  CustomTextSpan(
      {String? text,
      List<InlineSpan>? children,
      TextStyle? style,
      GestureRecognizer? recognizer,
      MouseCursor? mouseCursor,
      PointerEnterEventListener? onEnter,
      PointerExitEventListener? onExit,
      String? semanticsLabel})
      : super(
            text: text,
            children: children,
            style: style,
            recognizer: recognizer,
            mouseCursor: mouseCursor,
            onEnter: onEnter,
            onExit: onExit,
            semanticsLabel: semanticsLabel);

  @override
  RenderComparison compareTo(InlineSpan other) {
    if (other is CustomTextSpan && recognizer != other.recognizer) {
      // Theoretically, if `this` and `other` differ only in their `recognizer`,
      // that should be a metadata change (which is how it's treated by the base
      // class).  But for some reason this doesn't work (the old recognizer
      // sticks around).  So we have to pretend it's a layout change to trigger
      // Flutter to notice the difference.
      // TODO(paul): file a flutter bug for this
      return RenderComparison.layout;
    } else {
      return super.compareTo(other);
    }
  }
}
