import 'dart:io';

import 'interactable_component.dart';
import 'input_handler.dart';

class Checkbox extends InputHandler implements InteractableComponent {
  final List<String> items;
  final Set<int> _selected = {};
  int _index = 0;

  Checkbox({required this.items});
  @override
  void clear() {
    for (var i = 0; i < items.length; i++) {
      stdout.write("\x1B[1B\x1B[2K");
    }
    stdout.write("\x1B[${items.length - 1}A");
  }

  @override
  void draw() {
    stdout.write(render());
  }

  @override
  void handleInput(String input) {
    if (input == ' ') {
      _selected.add(_index);
    } else if (input == 'k' && _index > 0) {
      _index--;
    } else if (input == 'j' && _index < items.length - 1) {
      _index++;
    }

    clear();
    draw();
  }

  @override
  String render() {
    final List<String> modifiedItems = [];

    for (int i = 0; i < items.length; i++) {
      if (_selected.contains(i)) {
        modifiedItems.add('[X]${items[i]}');
      } else {
        if (_index == i)
          modifiedItems.add('[.]${items[i]}');
        else
          modifiedItems.add('[]${items[i]}');
      }
    }

    return modifiedItems.join('\n');
  }
}

void main() {
  Checkbox checkbox = Checkbox(items: ['Option 1', 'Option 2', 'Option 3']);
  checkbox.draw();

  stdin.echoMode = false;
  stdin.lineMode = false;

  stdin.listen((List<int> input) {
    String key = String.fromCharCodes(input);

    if (key == '\x1B') {
      stdin.lineMode = true;
      stdin.echoMode = true;
      exit(0);
    } else {
      checkbox.handleInput(key);
    }
  });
}
