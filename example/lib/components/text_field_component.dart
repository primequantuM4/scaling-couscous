import 'dart:io';
import 'package:example/components/input_manager.dart';
import 'package:example/components/mouse_event.dart';
import 'package:example/core/canvas_buffer.dart';
import 'package:example/core/focusable_component.dart';
import 'package:example/core/rect.dart';
import 'package:example/core/size.dart';

import 'colors.dart';
import 'text_component_style.dart';

class TextfieldComponent extends FocusableComponent {
  String value = "";
  TextComponentStyle textStyle;
  final Function(String)? onSubmitted;
  final String? placeHolder;

  TextfieldComponent({
    TextComponentStyle? textStyle,
    this.onSubmitted,
    this.placeHolder,
  }) : textStyle = textStyle ?? TextComponentStyle();

  @override
  void clear() {
    stdout.write("\x1B[2K");
    stdout.write("\r");
  }

  @override
  void draw() {}

  @override
  void render(CanvasBuffer buffer, Rect bounds) async {
    int x = bounds.x;
    int y = bounds.y;

    final TextComponentStyle colorStyle =
        TextComponentStyle().foreground(ColorRGB(23, 233, 210));

    final String text = isFocused ? "|> " : "   ";
    final String display = (value.isEmpty && placeHolder != null)
        ? "$text$placeHolder"
        : "$text$value";

    buffer.drawAt(x, y, display, colorStyle);
  }

  @override
  void handleInput(String input) {
    if (!isFocused) return;

    Set<String> arrowKeys = {'\x1B[A', '\x1B[B', '\x1B[C', '\x1B[D'};

    if (arrowKeys.contains(input)) return;

    if (input == '\r' || input == '\n') {
      final submittedValue = value;
      isFocused = false;
      value = "";
      blur();
      return;
    } else if (input == '\b' || input == '\x7F') {
      if (value.isNotEmpty) {
        value = value.substring(0, value.length - 1);
      }
    } else {
      value += input;
      print('value $value');
    }
  }

  @override
  void getCursorPosition(void Function(int x, int y) callback) {
    // TODO: implement getCursorPosition
  }

  @override
  Size measure(Size maxSize) {
    final text = value.isEmpty && isFocused && placeHolder != null
        ? placeHolder!
        : value;
    final width = text.length + 3;
    return Size(width: width, height: 1);
  }

  @override
  void onBlur() {
    // TODO: implement onBlur
  }

  @override
  void onFocus() {
    // TODO: implement onFocus
  }

  @override
  set onMouseEvent(Function(MouseEvent p1) callback) {
    // TODO: implement onMouseEvent
  }

  @override
  void startListening() {
    InputManager().registerHandler(this);
  }

  @override
  void stopListening() {
    InputManager().unregisterHandler(this);
  }

  @override
  int fitHeight() => 1;

  @override
  int fitWidth() {
    final text = value.isEmpty && isFocused && placeHolder != null
        ? placeHolder!
        : value;
    final width = isFocused ? text.length + 3 : text.length;
    return width;
  }

  @override
  Rect getArea() {
    throw UnimplementedError();
  }
}
