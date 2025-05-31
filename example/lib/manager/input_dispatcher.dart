import 'package:example/components/input_handler.dart';
import 'package:example/events/input_event.dart';
import 'package:example/manager/response_input.dart';
import 'package:example/renderer/renderer.dart';

class InputDispatcher {
  final Renderer _renderer;
  final List<InputHandler> _handlers = [];

  InputDispatcher({required Renderer renderer}) : _renderer = renderer;

  void registerHandler(InputHandler handler) {
    if (!_handlers.contains(handler)) {
      _handlers.add(handler);
    }
  }

  void unregisterHandler(InputHandler handler) {
    _handlers.remove(handler);
  }

  bool dispatchEvent(InputEvent event) {
    for (var handler in _handlers) {
      final response = handler.handleInput(event);
      if (response.handled) {
        for (final component in response.dirty ?? []) {
          _renderer.markDirty(component);
        }

        if ((response.dirty ?? []).isNotEmpty) _renderer.requestRedraw();
        if (response.commands == ResponseCommands.exit) return true;
      }
    }

    return false;
  }
}
