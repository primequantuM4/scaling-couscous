import 'dart:io';

import 'colors.dart';
import 'interactable_component.dart';
import 'input_handler.dart';
import 'text_component_style.dart';

class Checkbox extends InputHandler implements InteractableComponent {
  final List<String> items;
  final Set<int> _selected = {};
  final TextComponentStyle onSelect;
  final TextComponentStyle textStyle;
  final Function(List<String>)? onSubmitted;
  int _index = 0;
  bool _listening = false;

  Checkbox(
      {required this.items,
      TextComponentStyle? onSelect,
      TextComponentStyle? textStyle,
      this.onSubmitted})
      : onSelect = onSelect ?? TextComponentStyle(),
        textStyle = textStyle ?? TextComponentStyle();

  set listening(bool value) {
    if (_listening == value) return;
    _listening = value;
    if (_listening) {
      startListening();
      draw();
    } else {
      stopListening();
    }
  }

  bool get listening => _listening;

  @override
  void clear() {
    stdout.write("\x1B[${items.length}A");
    for (var i = 0; i < items.length; i++) {
      stdout.write("\x1B[1B\x1B[2K");
    }
    if (items.length > 1) stdout.write("\x1B[${items.length - 1}A");
    stdout.write("\r");
  }

  @override
  void draw() {
    stdout.write(render());
  }

  @override
  void handleInput(String input) {
    if (!_listening) return;

    if (input == '\r') {
      listening = false;
      clear();
      draw();
      stdout.write('\n');
      final List<String> selectedList = [];
      for (int i = 0; i < items.length; i++) {
        if (_selected.contains(i)) {
          selectedList.add(items[i]);
        }
      }
      onSubmitted?.call(selectedList);
      return;
    }

    if (input == ' ') {
      if (_selected.contains(_index)) {
        _selected.remove(_index);
      } else {
        _selected.add(_index);
      }
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
        final styledItem = onSelect.render(items[i]);
        modifiedItems.add(
            _index == i && _listening ? '[.X.]$styledItem' : '[X]$styledItem');
      } else {
        final styledItem = textStyle.render(items[i]);
        modifiedItems.add(
            _index == i && _listening ? '[.]$styledItem' : '[]$styledItem');
      }
    }

    return modifiedItems.join('\n');
  }
}

void main() {
  Checkbox checkbox = Checkbox(
      items: ['Option 1', 'Option 2', 'Option 3'],
      textStyle: TextComponentStyle().bold().italic().foreground(Colors.yellow),
      onSelect: TextComponentStyle()
          .italic()
          .bold()
          .foreground(Colors.yellow)
          .background(ColorRGB(255, 140, 0)));
  checkbox.listening = true;
}
