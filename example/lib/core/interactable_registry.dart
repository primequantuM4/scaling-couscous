import 'package:example/core/component.dart';
import 'package:example/core/focusable_component.dart';
import 'package:example/manager/focus_manager.dart';

class InteractableRegistry {
  void registerInteractables(Component component, FocusManager focusManager) {
    if (component is InteractableComponent) {
      focusManager.register(component);
    }

    if (component is ParentComponent) {
      for (var child in component.children) {
        registerInteractables(child, focusManager);
      }
    }
  }
}
