import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'input_handler.dart';

class InputManager {
  static final InputManager _instance = InputManager._internal();
  final List<InputHandler> _activeHandlers = [];
  InputHandler? _currentHandler;
  bool _inCommandMode = false;
  bool _isInputPaused = false;
  final StringBuffer _commandBuffer = StringBuffer();
  StreamSubscription<List<int>>? _stdinSubscription;

  InputManager._internal() {
    stdin.echoMode = false;
    stdin.lineMode = false;
    _stdinSubscription = stdin.listen(_handleInput);
  }

  factory InputManager() => _instance;

  void registerHandler(InputHandler handler) {
    if (!_activeHandlers.contains(handler)) {
      _activeHandlers.add(handler);
      _updateCurrentHandler();
    }
  }

  void unregisterHandler(InputHandler handler) {
    _activeHandlers.remove(handler);
    _updateCurrentHandler();
  }

  void stop() {
    final handlersCopy = List.of(_activeHandlers);
    for (var handler in handlersCopy) {
      unregisterHandler(handler);
    }
    _stdinSubscription?.cancel();
  }

  void pauseInput() {
    _isInputPaused = true;
  }

  void resumeInput() {
    _isInputPaused = false;
  }

  void _updateCurrentHandler() {
    _currentHandler = _activeHandlers.isNotEmpty ? _activeHandlers.last : null;
  }

  void _handleInput(List<int> data) {
    if (_isInputPaused) return;

    final input = utf8.decode(data);

    if (_inCommandMode) {
      _handleCommandMode(input);
    } else if (input == ':') {
      _enterCommandMode();
    } else {
      _currentHandler?.handleInput(input);
    }
  }

  void _handleCommandMode(String input) {
    if (_commandBuffer.isEmpty) {
      _inCommandMode = false;
      return;
    }

    if (input == '\r') {
      _inCommandMode = false;
      _executeCommand();
    } else if (input == '\b') {
      String currentVal = _commandBuffer.toString();
      currentVal = currentVal.substring(0, currentVal.length - 1);

      _commandBuffer.clear();
      _commandBuffer.write(currentVal);
    } else {
      _commandBuffer.write(input);
    }
  }

  void _enterCommandMode() {
    _inCommandMode = true;
    _commandBuffer.clear();
    _commandBuffer.write(':');
  }

  void _executeCommand() {
    if (_commandBuffer.toString().trim() == ':q') {
      stdout.write('\x1B[?1049l');
      stop();
    }
    _commandBuffer.clear();
  }
}
