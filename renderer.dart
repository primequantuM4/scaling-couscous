import 'dart:io';
import 'dart:convert';

abstract class InteractableComponent {
  void clear();
  void draw();
  String render();
}

class TextfieldComponent implements InteractableComponent {
  String value = "";
  bool focused = false;

  @override
  void clear() {
    stdout.write("\x1B[2K");
    stdout.write("\r");
  }

  @override
  void draw() {
    stdout.write("\r");
    stdout.write(render());
  }

  @override
  String render() {
    return focused ? "> $value " : "  $value  ";
  }

  void handleInput(String input) {
    if (input == '\n') {
      focused = false;
    } else if (input == '\b' && value.isNotEmpty) {
      value = value.substring(0, value.length - 1);
    } else {
      value += input;
    }
    clear();
    draw();
  }
}

void main() {
  var textField = TextfieldComponent();
  textField.focused = true;

  stdin.echoMode = false;
  stdin.lineMode = false;
  stdin.listen((List<int> event) {
    String key = utf8.decode(event);

    if (key == '\x1B') {
      stdin.echoMode = true;
      stdin.lineMode = true;
      exit(0);
    } else {
      textField.handleInput(key);
    }
  });

  textField.draw();
}

