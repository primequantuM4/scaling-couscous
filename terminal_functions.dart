import 'dart:io';

import 'colors.dart';
import 'input_handler.dart';
import 'input_manager.dart';
import 'text_component_style.dart';
import 'text_field_component.dart';

class Terminal {
  static final _inputHandler = _TerminalInputHandler();
  static final _inputManager = InputManager();

  static int getWidth() {
    if (!stdout.hasTerminal) {
      throw UnsupportedError("Terminal is not available");
    }

    return stdout.terminalColumns;
  }

  static int getHeight() {
    if (!stdout.hasTerminal) {
      throw UnsupportedError("Terminal is not available");
    }

    return stdout.terminalLines;
  }

  static void enterFullscreen() {
    if (!stdout.hasTerminal) {
      throw UnsupportedError("Terminal is not available");
    }

    stdout.write('\x1B[?1049h');
    stdout.write('\x1B[H');
  }

  static void exitFullscreen() {
    if (!stdout.hasTerminal) {
      throw UnsupportedError("Terminal is not available.");
    }
    _inputManager.stop();
    stdout.write('\x1B[?1049l');
  }

  static void startListening() {
    _inputManager.registerHandler(_inputHandler);
  }
}

class _TerminalInputHandler extends InputHandler {
  final StringBuffer _commandBuffer = StringBuffer();

  @override
  void handleInput(String input) {
    if (_commandBuffer.isEmpty) return;

    if (input == '\r') {
      _executeCommand();
      _commandBuffer.clear();
    } else if (input == '\b') {
      String currentVal = _commandBuffer.toString();
      currentVal = currentVal.substring(0, currentVal.length - 1);

      _commandBuffer.clear();
      _commandBuffer.write(currentVal);
    } else {
      _commandBuffer.write(input);
    }
  }

  void _executeCommand() {
    if (_commandBuffer.toString().trim() == ':q') {
      Terminal.exitFullscreen();
    }
    _commandBuffer.clear();
  }
}

void main() {
  try {
    print("Terminal Width: ${Terminal.getWidth()}");
    print("Terminal Height: ${Terminal.getHeight()}");

    print("Entering fullscreen mode...");

    Terminal.enterFullscreen();
    final textField = TextfieldComponent(
        textStyle: TextComponentStyle().foreground(Colors.yellow));
    textField.focused = true;
  } catch (e) {
    print("Error: ${e.toString()}");
  }
}
