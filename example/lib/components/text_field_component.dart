import 'package:example/core/canvas_buffer.dart';
import 'package:example/core/focusable_component.dart';
import 'package:example/core/rect.dart';
import 'package:example/core/size.dart';

import 'colors.dart';
import 'text_component_style.dart';

class TextfieldComponent extends InteractableComponent {
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
  void render(CanvasBuffer buffer, Rect bounds) async {
    int x = bounds.x;
    int y = bounds.y;

    final String text = (isFocused) ? "|> " : "   ";
    final String display = (value.isEmpty && placeHolder != null)
        ? "$text$placeHolder"
        : "$text$value";

    buffer.drawAt(x, y, display, textStyle);
  }

  @override
  void handleInput(String input) {
    if (!isFocused) return;

    Set<String> arrowKeys = {'\x1B[A', '\x1B[B', '\x1B[C', '\x1B[D'};

    if (arrowKeys.contains(input)) return;

    if (input == '\r' || input == '\n') {
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
    }

    return;
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
  void onHover() {
    textStyle = TextComponentStyle()
        .foreground(Colors.white)
        .background(ColorRGB(40, 40, 40));
  }
}
