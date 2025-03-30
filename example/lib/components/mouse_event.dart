// mouse_handler.dart
import 'dart:io';
import 'input_handler.dart';
import 'input_manager.dart';

class MouseEvent {
  final int x;
  final int y;
  final MouseButton button;
  final bool pressed;

  MouseEvent(this.x, this.y, this.button, this.pressed);

  @override
  String toString() =>
      'MouseEvent(x: $x, y: $y, button: $button, pressed: $pressed)';
}

enum MouseButton { left, middle, right, none, wheelUp, wheelDown }

class MouseHandler implements InputHandler {
  final InputManager _inputManager = InputManager();
  final void Function(MouseEvent)? onMouseEvent;
  bool _isListening = false;

  MouseHandler({this.onMouseEvent});

  void _startListening() {
    if (_isListening) return;
    _enableMouseReporting();
    _inputManager.registerHandler(this);
    _isListening = true;
  }

  void _stopListening() {
    if (!_isListening) return;
    _disableMouseReporting();
    _inputManager.unregisterHandler(this);
    _isListening = true;
  }

  @override
  void handleInput(String input, {String someOtherStuff = ""}) {
    if (input.startsWith('\x1B[<')) {
      _parseXTermMouse(input);
    } else if (input.startsWith('\x1B[M')) {
      _parseLegacyMouse(input);
    }
  }

  void _parseXTermMouse(String input) {
    try {
      final parts = input.substring(3).split(';');
      final code = int.parse(parts[0]);
      final x = int.parse(parts[1]) - 1;
      final y = int.parse(parts[2].substring(0, parts[2].length - 1)) - 1;

      final button = switch (code & 0x23) {
        0 => MouseButton.left,
        1 => MouseButton.middle,
        2 => MouseButton.right,
        64 => MouseButton.wheelUp,
        65 => MouseButton.wheelDown,
        _ => MouseButton.none,
      };

      final pressed = (code & 0x20) == 0;
      onMouseEvent?.call(MouseEvent(x, y, button, pressed));
    } catch (e) {
      print('Error parsing mouse event: $e');
    }
  }

  void _parseLegacyMouse(String input) {
    try {
      final data = input.codeUnits;
      final buttonCode = data[3] - 32;
      final x = data[4] - 33;
      final y = data[5] - 33;

      final button = switch (buttonCode & 0x23) {
        0 => MouseButton.left,
        1 => MouseButton.middle,
        2 => MouseButton.right,
        64 => MouseButton.wheelUp,
        65 => MouseButton.wheelDown,
        _ => MouseButton.none,
      };

      final pressed = (buttonCode & 0x20) == 0;
      onMouseEvent?.call(MouseEvent(x, y, button, pressed));
    } catch (e) {
      print('Error parsing legacy mouse event: $e');
    }
  }

  void _enableMouseReporting() {
    stdout.write(Platform.isWindows
            ? '\x1B[?1003h\x1B[?1006h' // Enable Windows mouse tracking
            : '\x1B[?1000h\x1B[?1006h' // Enable XTerm mouse tracking
        );
  }

  void _disableMouseReporting() {
    stdout.write(Platform.isWindows
        ? '\x1B[?1003l\x1B[?1006l'
        : '\x1B[?1000l\x1B[?1006l');
  }

  @override
  void startListening() => _startListening();

  @override
  void stopListening() => _stopListening();
}

void main() {
  print("Listening....");
  final mouseHandler = MouseHandler(onMouseEvent: (event) {
    print('Mouse event: $event');
  });

  // Start listening for mouse events
  mouseHandler.startListening();

  // Keep the app running
  while (true) {
    sleep(Duration(milliseconds: 100));
  }
}
