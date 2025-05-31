import 'package:example/components/input_handler.dart';
import 'package:example/core/focusable_component.dart';
import 'package:example/events/input_event.dart';
import 'package:example/manager/response_input.dart';

class FocusManager implements InputHandler {
  final List<InteractableComponent> components = [];
  InteractableComponent? _currentComponent;
  int currentIndex = -1;

  FocusManager();

  void register(InteractableComponent c) {
    components.add(c);
  }

  ResponseInput handleTab(bool shiftPressed) {
    if (components.isEmpty) {
      return ResponseInput(commands: ResponseCommands.none, handled: false);
    }

    if (currentIndex == -1) {
      currentIndex = shiftPressed ? components.length - 1 : 0;
      components[currentIndex].focus();
      _currentComponent = components[currentIndex];

      return ResponseInput(
          commands: ResponseCommands.none,
          handled: true,
          dirty: [_currentComponent!]);
    }

    final List<InteractableComponent> dirtyComponents = [];

    _currentComponent!.blur();
    dirtyComponents.add(components[currentIndex]);

    if (shiftPressed) {
      currentIndex = (currentIndex - 1 + components.length) % components.length;
    } else {
      currentIndex = (currentIndex + 1) % components.length;
    }
    _currentComponent = components[currentIndex];
    _currentComponent!.focus();
    dirtyComponents.add(_currentComponent!);

    return ResponseInput(
      commands: ResponseCommands.none,
      handled: true,
      dirty: dirtyComponents,
    );
  }

  @override
  ResponseInput handleInput(InputEvent event) {
    if (event is ShiftTabEvent) {
      return handleTab(true);
    } else if (event is TabEvent) {
      return handleTab(false);
    } else if (event is MouseEvent) {
      final List<InteractableComponent> dirtyComponents = [];
      for (int i = 0; i < components.length; i++) {
        final component = components[i];
        if (_isWithinBounds(event.x, event.y, component)) {
          if (event.type == MouseEventType.release) {
            component.hover();
          } else if (event.type == MouseEventType.click) {
            _currentComponent?.blur();
            component.focus();
          }
          if (_currentComponent != null) {
            dirtyComponents.add(_currentComponent!);
          }

          dirtyComponents.add(component);

          _currentComponent = component;
        }
      }

      return ResponseInput(
        commands: ResponseCommands.none,
        handled: true,
        dirty: dirtyComponents,
      );
    }
    return ResponseInput(commands: ResponseCommands.none, handled: false);
  }

  bool _isWithinBounds(int x, int y, InteractableComponent component) {
    final bounds = component.getBounds();
    return (x >= bounds.x && x <= bounds.x + bounds.width) ||
        (y >= bounds.y && y <= bounds.y + bounds.height);
  }
}
