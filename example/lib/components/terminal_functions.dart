import 'dart:io';

import 'package:example/components/colors.dart';
import 'package:example/components/text_component_style.dart';
import 'package:example/components/text_field_component.dart';

import 'input_handler.dart';
import 'input_manager.dart';

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

  static void write(String data) {
    stdout.write(data);
  }

  static void writeLn(String data) {
    stdout.write('$data\n');
  }

  static void displayCentered(String data) {
    final width = Terminal.getWidth();
    final height = Terminal.getHeight();
    write('\x1B[${height ~/ 2};${width ~/ 2}H');
    write(data);
  }

  static Future<void> clearAfterDelay(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
    stdout.write('\x1B[2J');
    stdout.write('\x1B[H');
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

    if (input == '\r' || input == '\n') {
      _executeCommand();
      _commandBuffer.clear();
    } else if (input == '\b' || input == '\x7F') {
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

// testing
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
