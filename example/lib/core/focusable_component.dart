import 'package:example/core/canvas_buffer.dart';
import 'package:example/core/component.dart';
import 'package:example/core/rect.dart';

abstract class InteractableComponent extends Component {
  bool isFocused = false;
  bool isHovered = true;

  void blur() {
    isFocused = false;
    onBlur();

    return;
  }

  void focus() {
    isFocused = true;
    onFocus();

    return;
  }

  void hover() {
    isHovered = true;
    onHover();

    return;
  }

  void unhover() {
    isHovered = false;
    return;
  }

  void onFocus();
  void onBlur();
  void onHover();

  void handleInput(String input);
}
