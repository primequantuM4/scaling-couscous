import 'package:example/components/input_handler.dart';
import 'package:example/events/input_event.dart';
import 'package:example/manager/response_input.dart';

class CommandModeHandler implements InputHandler {
  bool _inCommandMode = false;
  final StringBuffer _buffer = StringBuffer();

  @override
  ResponseInput handleInput(InputEvent event) {
    if (!_shouldHandle(event)) {
      return ResponseInput(commands: ResponseCommands.none, handled: true);
    }

    event = event as CharEvent;
    if (event.buffer == '\r' || event.buffer == '\n') {
      return executeCommand();
    } else if (event.buffer == '\b' || event.buffer == '\x7F') {
      String value = _buffer.toString();
      if (value.isNotEmpty) {
        value = value.substring(0, value.length - 1);
        _buffer.clear();
        _buffer.write(value);
      }
    } else {
      _buffer.write(event.buffer);
    }

    return ResponseInput(commands: ResponseCommands.none, handled: true);
  }

  ResponseInput executeCommand() {
    final ResponseCommands responseCommands;
    if (_buffer.toString() == ':q') {
      responseCommands = ResponseCommands.exit;
    } else {
      responseCommands = ResponseCommands.none;
    }

    _exitCommandMode();
    return ResponseInput(commands: responseCommands, handled: true);
  }

  bool _shouldHandle(InputEvent event) {
    if (!_inCommandMode && event is CharEvent && event.buffer == ':') {
      _enterCommandMode();
    }
    return _inCommandMode ||
        (!_inCommandMode && event is CharEvent && event.buffer == ':');
  }

  void _enterCommandMode() {
    _inCommandMode = true;
    _buffer.clear();
    _buffer.write(':');
  }

  void _exitCommandMode() {
    _inCommandMode = false;
    _buffer.clear();
  }
}
