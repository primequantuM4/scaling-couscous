import 'dart:io';

import 'package:example/components/mouse_event.dart';

import 'interactable_component.dart';
import 'input_handler.dart';
import 'text_component_style.dart';

class Checkbox extends InputHandler implements InteractableComponent {
  final List<String> items;
  final Set<int> _selected = {};
  final TextComponentStyle onSelect;
  final TextComponentStyle onHover;
  final TextComponentStyle textStyle;
  final Function(List<String>)? onSubmitted;
  int _index = 0;
  int _hovered = -1;
  int _posY = -1;
  bool _listening = false;

  final int _checkBoxLength = 5;

  Checkbox(
      {required this.items,
      TextComponentStyle? onSelect,
      TextComponentStyle? textStyle,
      TextComponentStyle? onHover,
      this.onSubmitted})
      : onSelect = onSelect ?? TextComponentStyle(),
        onHover = onHover ?? TextComponentStyle(),
        textStyle = textStyle ?? TextComponentStyle() {
    if (onHover != null) {
      onMouseEvent = _handleMouseEvent;
    }
  }

  _handleMouseEvent(MouseEvent event) {
    final newHovered = event.y - _posY;
    if (newHovered >= 0 &&
        newHovered < items.length &&
        items[newHovered].length + _checkBoxLength >= event.x) {
      if (_hovered != newHovered) {
        _hovered = newHovered;
        _index = _hovered;
        clear();
        draw();
      }
      if (event.type == MouseEventType.click && event.button == 0) {
        if (_selected.contains(newHovered)) {
          _selected.remove(newHovered);
        } else {
          _selected.add(newHovered);
        }
        clear();
        draw();
      }
    } else {
      if (_hovered != -1) {
        _hovered = -1;
        clear();
        draw();
      }
    }
  }

  set listening(bool value) {
    if (_listening == value) return;
    _listening = value;
    if (_listening) {
      getCursorPosition((x, y) {
        _posY = y;
      });
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

    if (input == '\r' || input == '\n') {
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
    } else if ((input == 'k' || input == '\x1B[A') && _index > 0) {
      _index--;
    } else if ((input == 'j' || input == '\x1B[B') &&
        _index < items.length - 1) {
      _index++;
    }

    clear();
    draw();
  }

  @override
  String render() {
    final List<String> modifiedItems = [];

    for (int i = 0; i < items.length; i++) {
      final hoveredItem = onHover.render(items[i]);
      if (_selected.contains(i)) {
        final styledItem = onSelect.render(items[i]);
        modifiedItems.add(
            _index == i && _listening ? '[.X.]$styledItem' : '[X]$styledItem');
      } else {
        final styledItem = textStyle.render(items[i]);
        modifiedItems.add((_index == i || _hovered == i) && _listening
            ? '[.]$hoveredItem'
            : '[]$styledItem');
      }
    }

    return modifiedItems.join('\n');
  }
}
