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
    stdout.write("\x1B[2K"); // Clear the entire line
    stdout.write("\r"); // Move cursor to the beginning of the line
  }

  @override
  void draw() {
    stdout.write("\r"); // Move cursor to the start of the line
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

  stdin.echoMode = false; // Disable automatic input display
  stdin.lineMode = false; // Capture single keypresses
  stdin.listen((List<int> event) {
    String key = utf8.decode(event);

    if (key == '\x1B') {
      // Escape key to exit
      stdin.echoMode = true;
      stdin.lineMode = true;
      exit(0);
    } else {
      textField.handleInput(key);
    }
  });

  textField.draw();
}

