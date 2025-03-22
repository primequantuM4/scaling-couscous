import 'dart:io';
import 'interactable_component.dart';
import 'input_handler.dart';
import 'main.dart';

class TextfieldComponent extends InputHandler implements InteractableComponent {
  String value = "";
  bool _focused = false;
  TextComponentStyle textStyle;
  final Function(String)? onSubmitted;
  final String? placeHolder;

  TextfieldComponent({
    TextComponentStyle? textStyle,
    this.onSubmitted,
    this.placeHolder,
  }) : textStyle = textStyle ?? TextComponentStyle();

  set focused(bool value) {
    if (_focused == value) return;
    _focused = value;
    if (_focused) {
      startListening();
      draw();
    } else {
      stopListening();
    }
  }

  bool get focused => _focused;

  @override
  void clear() {
    stdout.write("\x1B[2K");
    stdout.write("\r");
  }

  @override
  void draw() {
    stdout.write(render());
  }

  @override
  String render() {
    final styledValue;

    if (value.isEmpty && placeHolder != null && focused) {
      final TextComponentStyle colorStyle =
          TextComponentStyle().foreground(ColorRGB(128, 128, 128));
      styledValue = colorStyle.render(placeHolder!);
    } else {
      styledValue = textStyle.render(value);
    }

    return focused ? "> $styledValue" : "  $styledValue";
  }

  @override
  void handleInput(String input) {
    if (!focused) return;

    if (input == '\r') {
      final submittedValue = value;
      focused = false;
      clear();
      draw();
      value = "";
      stdout.write('\n');
      onSubmitted?.call(submittedValue);
    } else if (input == '\b') {
      if (value.isNotEmpty) {
        value = value.substring(0, value.length - 1);
      }
    } else {
      value += input;
    }

    clear();
    draw();
  }
}

void main() {
  final textField = TextfieldComponent(
    placeHolder: 'Charizard',
    textStyle: TextComponentStyle().foreground(Colors.green),
    onSubmitted: (submittedValue) {
      print("You have selected the pokemon [$submittedValue]:");
      print("choose your favorite attack");
      print("[]Thunderstrike []Thunderbolt [X]Tackle");
    },
  );

  print("What's your favorite pokemon?");
  textField.focused = true;
}
