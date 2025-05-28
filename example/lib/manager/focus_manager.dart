import 'package:example/core/focusable_component.dart';

class FocusManager {
  final List<FocusableComponent> components = [];
  int currentIndex = -1;

  void register(FocusableComponent c) {
    components.add(c);
  }

  void handleTab(bool shiftPressed) {
    if (currentIndex == -1) {
      currentIndex = shiftPressed ? components.length - 1 : 0;
      components[currentIndex].focus();

      return;
    }
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
