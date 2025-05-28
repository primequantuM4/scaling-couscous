import 'package:example/core/focusable_component.dart';

class FocusManager {
  final List<FocusableComponent> components = [];
  int currentIndex = 0;

  void register(FocusableComponent c) {
    components.add(c);

    if (components.length == 1) {
      components[0].isFocused = true;
    }
  }

  void handleTab(bool shiftPressed) {
    components[currentIndex].blur();

    if (shiftPressed) {
      currentIndex = (currentIndex - 1 + components.length) % components.length;
    } else {
      currentIndex = (currentIndex + 1) % components.length;
    }
    components[currentIndex].focus();

    for (var component in components) {
      print(component.isFocused);
    }
  }

  void focusFirst() {
    if (components.isNotEmpty) {
      components.first.focus();
    }
  }
}
