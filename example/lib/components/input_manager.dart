import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'input_handler.dart';

class InputManager {
  static final InputManager _instance = InputManager._internal();
  final List<InputHandler> _activeHandlers = [];
  final List<int> _inputBuffer = [];
  InputHandler? _currentHandler;
  bool _inCommandMode = false;
  bool _isInputPaused = false;
  final StringBuffer _commandBuffer = StringBuffer();
  StreamSubscription<List<int>>? _stdinSubscription;

  InputManager._internal() {
    _configureStdin();
    if (Platform.isWindows) {
      _enableWindowsAnsi();
    }
    _stdinSubscription = stdin.listen(_handleInput);
  }

  factory InputManager() => _instance;

  void _configureStdin() {
    stdin
      ..echoMode = false
      ..lineMode = false;
  }

  void _enableWindowsAnsi() {
    final handle = GetStdHandle(STD_HANDLE.STD_INPUT_HANDLE);
    var mode = calloc<DWORD>();

    GetConsoleMode(handle, mode);
    SetConsoleMode(
        handle,
        mode.value |
            CONSOLE_MODE.ENABLE_VIRTUAL_TERMINAL_INPUT |
            CONSOLE_MODE.ENABLE_WINDOW_INPUT);
    calloc.free(mode);
  }

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

    _inputBuffer.addAll(data);

    while (_inputBuffer.isNotEmpty) {
      if (_inputBuffer[0] == 0x1B && _inputBuffer.length >= 3) {
        _processAnsiSequence();
      } else if (_inputBuffer[0] == 0xE0 && _inputBuffer.length >= 2) {
        _processWindowsSequence();
      } else if (_inputBuffer.length == 1) {
        _processSingleByte();
      } else {
        print("Unhandled input: $_inputBuffer");
        _inputBuffer.clear();
      }
    }
  }

  void _processAnsiSequence() {
    final sequence = _inputBuffer.sublist(0, 3);
    _inputBuffer.removeRange(0, 3);

    switch (sequence[2]) {
      case 0x41:
        _triggerKey('\x1B[A');
        break;
      case 0x42:
        _triggerKey('\x1B[B');
        break;
      case 0x43:
        _triggerKey('\x1B[C');
        break;
      case 0x44:
        _triggerKey('\x1B[D');
        break;
      default:
        print("Unhandled ANSI sequence: $sequence");
    }
  }

  void _processWindowsSequence() {
    final sequence = _inputBuffer.sublist(0, 2);
    _inputBuffer.removeRange(0, 2);

    switch (sequence[1]) {
      case 0x48:
        _triggerKey('\x1B[A');
        break;
      case 0x50:
        _triggerKey('\x1B[B');
        break;
      case 0x4B:
        _triggerKey('\x1B[D');
        break;
      case 0x4D:
        _triggerKey('\x1B[C');
        break;
      default:
        print("Unhandled Windows sequence: $sequence");
    }
  }

  void _processSingleByte() {
    final byte = _inputBuffer.removeAt(0);
    final input = String.fromCharCode(byte);

    if (_inCommandMode) {
      _handleCommandMode(input);
    } else if (input == ':') {
      _enterCommandMode();
    } else {
      _currentHandler?.handleInput(input);
    }
  }

  void _triggerKey(String sequence) {
    _currentHandler?.handleInput(sequence);
  }

  void _handleCommandMode(String input) {
    if (_commandBuffer.isEmpty) {
      _inCommandMode = false;
      return;
    }

    if (input == '\r' || input == '\n') {
      _inCommandMode = false;
      _executeCommand();
    } else if ((input == '\b' || input == '\x7F') &&
        _commandBuffer.isNotEmpty) {
      String value = _commandBuffer.toString();
      value = value.substring(0, value.length - 1);
      _commandBuffer.clear();
      _commandBuffer.write(value);
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
      if (Platform.isWindows) {
        _restoreWindowsConsoleMode();
      } else {
        stdin
          ..echoMode = true
          ..lineMode = true;
      }
      stdout.write('\x1B[?1049l');
      stop();
      exit(0);
    }
    _commandBuffer.clear();
  }

  void _restoreWindowsConsoleMode() {
    final handle = GetStdHandle(STD_HANDLE.STD_INPUT_HANDLE);
    var mode = calloc<DWORD>();

    GetConsoleMode(handle, mode);
    SetConsoleMode(
        handle,
        mode.value &
            ~(CONSOLE_MODE.ENABLE_VIRTUAL_TERMINAL_INPUT |
                CONSOLE_MODE.ENABLE_WINDOW_INPUT));

    calloc.free(mode);
  }
}

