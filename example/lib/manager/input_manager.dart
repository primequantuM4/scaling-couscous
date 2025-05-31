import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:example/events/input_event.dart';
import 'package:example/manager/input_dispatcher.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class InputManager {
  bool _isInputPaused = false;
  bool _expectingCursorResponse = false;

  void Function(int, int)? _cursorCallback;

  Function(MouseEvent)? onEvent;

  StreamSubscription<List<int>>? _stdinSubscription;

  final InputDispatcher _dispatcher;
  final List<int> _inputBuffer = [];
  final List<int> _cursorInputBuffer = [];

  InputManager({required InputDispatcher dispatcher})
      : _dispatcher = dispatcher {
    _configureStdin();
    _enableMouseInput();

    if (Platform.isWindows) {
      _enableWindowsAnsi();
    }

    _stdinSubscription = stdin.listen(_manageHandlers);
  }

  void _configureStdin() {
    stdin
      ..echoMode = false
      ..lineMode = false;
  }

  void _enableMouseInput() {
    stdout.write('\x1B[?1006h\x1B[?1003h');
  }

  void _enableWindowsAnsi() {
    final handle = GetStdHandle(STD_HANDLE.STD_INPUT_HANDLE);
    var mode = calloc<DWORD>();

    GetConsoleMode(handle, mode);
    SetConsoleMode(
        handle,
        mode.value |
            CONSOLE_MODE.ENABLE_VIRTUAL_TERMINAL_INPUT |
            CONSOLE_MODE.ENABLE_MOUSE_INPUT |
            CONSOLE_MODE.ENABLE_WINDOW_INPUT);
    calloc.free(mode);
  }

  void _restoreWindowsConsoleMode() {
    final handle = GetStdHandle(STD_HANDLE.STD_INPUT_HANDLE);
    var mode = calloc<DWORD>();

    GetConsoleMode(handle, mode);
    SetConsoleMode(
        handle,
        mode.value &
            ~(CONSOLE_MODE.ENABLE_VIRTUAL_TERMINAL_INPUT |
                CONSOLE_MODE.ENABLE_MOUSE_INPUT |
                CONSOLE_MODE.ENABLE_WINDOW_INPUT));

    calloc.free(mode);
  }

  void _manageHandlers(List<int> data) {
    if (_isInputPaused) return;

    if (_expectingCursorResponse) {
      _handleCursorResponse(data);
      return;
    }

    _inputBuffer.addAll(data);

    while (_inputBuffer.isNotEmpty) {
      InputEvent dispatchedEvent;

      if (_inputBuffer.length >= 3 &&
          _inputBuffer[0] == 0x1B &&
          _inputBuffer[1] == 0x5B &&
          _inputBuffer[2] == 0x3C) {
        // 0x1B 0x5B 0x3C == /x1B[<
        // EVENT IS MOUSE EVENT
        final mouseEvents = _processMouseBuffer();
        for (final event in mouseEvents) {
          _dispatcher.dispatchEvent(event);
        }
        return;
      } else if (_inputBuffer[0] == 0x1B && _inputBuffer.length >= 3) {
        final List<int> sequence = _inputBuffer.sublist(0, 3);
        // EVENT IS A NORMAL SPECIAL KEY EVENT

        if (sequence[2] == 0x5A) {
          dispatchedEvent = ShiftTabEvent();
        } else {
          dispatchedEvent = SequenceEvent(sequence: sequence);
        }

        _inputBuffer.removeRange(0, 3);
      } else if (_inputBuffer[0] == 0xE0 && _inputBuffer.length >= 2) {
        final sequence = _inputBuffer.sublist(0, 2);
        if (sequence[1] == 0x5A) {
          dispatchedEvent = ShiftTabEvent();
        } else {
          dispatchedEvent = WindowsSequenceEvent(sequence: sequence);
        }

        _inputBuffer.removeRange(0, 2);
      } else if (_inputBuffer.length == 1) {
        final byte = _inputBuffer.removeAt(0);
        final input = String.fromCharCode(byte);
        // EVENT IS A NORMAL KEY for any device
        if (input == '\t') {
          dispatchedEvent = TabEvent();
        } else if (byte >= 32 && byte <= 126) {
          dispatchedEvent = CharEvent(buffer: input);
        } else {
          dispatchedEvent = UnknownEvent(byte: byte);
        }
      } else {
        // UNKNOWN INPUT EVENT
        dispatchedEvent = UnknownEvent();
      }

      if (_dispatcher.dispatchEvent(dispatchedEvent)) stop();
    }
  }

  void _handleCursorResponse(List<int> data) {
    _cursorInputBuffer.addAll(data);

    String input = String.fromCharCodes(_cursorInputBuffer);

    RegExp regex = RegExp(r'\x1B\[(\d+);(\d+)R');
    Match? match = regex.firstMatch(input);

    if (match != null) {
      _expectingCursorResponse = false;
      _cursorInputBuffer.clear();

      int row = int.parse(match.group(1)!);
      int col = int.parse(match.group(2)!);
      _cursorCallback?.call(col - 1, row - 1);
    }

    return;
  }

  // void _handleInput(List<int> data) {
  //   if (_isInputPaused) return;
  //
  //   if (_expectingCursorResponse) {
  //     _cursorInputBuffer.addAll(data);
  //
  //     String input = String.fromCharCodes(_cursorInputBuffer);
  //
  //     // Look for full response like ESC[55;1R
  //     RegExp regex = RegExp(r'\x1B\[(\d+);(\d+)R');
  //     Match? match = regex.firstMatch(input);
  //
  //     if (match != null) {
  //       _expectingCursorResponse = false;
  //       _cursorInputBuffer.clear();
  //
  //       int row = int.parse(match.group(1)!);
  //       int col = int.parse(match.group(2)!);
  //       _cursorCallback?.call(col - 1, row - 1);
  //     }
  //
  //     return;
  //   }
  //
  //   _inputBuffer.addAll(data);
  //
  //   while (_inputBuffer.isNotEmpty) {
  //     if (!_expectingCursorResponse &&
  //         _inputBuffer[0] == 0x1B &&
  //         _inputBuffer.length >= 3) {
  //       if (_inputBuffer.length >= 3 &&
  //           String.fromCharCodes(_inputBuffer).contains('\x1B[<')) {
  //         _processMouseBuffer();
  //       } else {
  //         _processAnsiSequence();
  //       }
  //     } else if (_inputBuffer[0] == 0xE0 && _inputBuffer.length >= 2) {
  //       _processWindowsSequence();
  //     } else if (_inputBuffer.length == 1) {
  //       _processSingleByte();
  //     } else {
  //       print("Unhandled input: $_inputBuffer");
  //       _inputBuffer.clear();
  //     }
  //   }
  // }

  void stop() {
    stdout.write('\x1B[?1006l\x1B[?1003l');

    if (Platform.isWindows) {
      _restoreWindowsConsoleMode();
    } else {
      stdin
        ..echoMode = true
        ..lineMode = true;
    }
    stdout.write(
        '\x1B[?1049l'); // TODO: make sure ONLY to handle this in full screen mode
    _stdinSubscription?.cancel();
  }

  void pauseInput() {
    _isInputPaused = true;
  }

  void resumeInput() {
    _isInputPaused = false;
  }

  List<MouseEvent> _processMouseBuffer() {
    final List<MouseEvent> mouseEvents = [];
    while (true) {
      int start = _inputBuffer.indexOf(27);
      if (start == -1) break;

      int end = _inputBuffer.indexOf(77, start);
      if (end == -1) {
        end = _inputBuffer.indexOf(109, start);
        if (end == -1) break;
      }

      String sequence =
          String.fromCharCodes(_inputBuffer.sublist(start, end + 1));
      _inputBuffer.removeRange(start, end + 1);
      final event = _parseMouseEvent(sequence);
      if (event != null) mouseEvents.add(event);
    }

    return mouseEvents;
  }

  void getCursorPosition(void Function(int x, int y) callback) {
    stdout.write('\x1B[6n');
    _expectingCursorResponse = true;
    _cursorCallback = callback;
  }

  MouseEvent? _parseMouseEvent(String sequence) {
    try {
      String data = sequence.substring(3, sequence.length - 1);
      List<String> parts = data.split(';');
      if (parts.length != 3) return null;

      int cb = int.parse(parts[0]);
      int x = int.parse(parts[1]) - 1;
      int y = int.parse(parts[2]) - 1;
      bool isRelease = sequence.endsWith('m');
      bool isMotion = (cb & 0x20) != 0;

      MouseEventType type = MouseEventType.click;
      if (isRelease) {
        type = MouseEventType.release;
      } else if (isMotion) {
        type = MouseEventType.hover;
      }

      int button = cb & ~0x20;

      return MouseEvent(type, x, y, button);
    } catch (e) {
      print('Error parsing mouse event: $e');
      return null;
    }
  }

  // void _updateCurrentHandler() {
  //   _currentHandler = _activeHandlers.isNotEmpty ? _activeHandlers.last : null;
  // }

  // void _processAnsiSequence() {
  //   final sequence = _inputBuffer.sublist(0, 3);
  //   _inputBuffer.removeRange(0, 3);
  //
  //   switch (sequence[2]) {
  //     case 0x41:
  //       _triggerKey('\x1B[A');
  //       break;
  //     case 0x42:
  //       _triggerKey('\x1B[B');
  //       break;
  //     case 0x43:
  //       _triggerKey('\x1B[C');
  //       break;
  //     case 0x44:
  //       _triggerKey('\x1B[D');
  //       break;
  //     default:
  //       print("Unhandled ANSI sequence: $sequence");
  //   }
  // }

  // void _processWindowsSequence() {
  //   final sequence = _inputBuffer.sublist(0, 2);
  //   _inputBuffer.removeRange(0, 2);
  //
  //   switch (sequence[1]) {
  //     case 0x48:
  //       _triggerKey('\x1B[A');
  //       break;
  //     case 0x50:
  //       _triggerKey('\x1B[B');
  //       break;
  //     case 0x4B:
  //       _triggerKey('\x1B[D');
  //       break;
  //     case 0x4D:
  //       _triggerKey('\x1B[C');
  //       break;
  //     default:
  //       print("Unhandled Windows sequence: $sequence");
  //   }
  // }

  // void _processSingleByte() {
  //   final byte = _inputBuffer.removeAt(0);
  //   final input = String.fromCharCode(byte);
  //
  //   if (_inCommandMode) {
  //     _handleCommandMode(input);
  //   } else if (input == ':') {
  //     _enterCommandMode();
  //   } else {
  //     // _currentHandler?.handleInput(input);
  //   }
  // }

  // void _triggerKey(String sequence) {
  //   // _currentHandler?.handleInput(sequence);
  // }

  // void _handleCommandMode(String input) {
  //   if (_commandBuffer.isEmpty) {
  //     _inCommandMode = false;
  //     return;
  //   }
  //
  //   if (input == '\r' || input == '\n') {
  //     _inCommandMode = false;
  //     _executeCommand();
  //   } else if ((input == '\b' || input == '\x7F') &&
  //       _commandBuffer.isNotEmpty) {
  //     String value = _commandBuffer.toString();
  //     value = value.substring(0, value.length - 1);
  //     _commandBuffer.clear();
  //     _commandBuffer.write(value);
  //   } else {
  //     _commandBuffer.write(input);
  //   }
  // }
  //
  // void _enterCommandMode() {
  //   _inCommandMode = true;
  //   _commandBuffer.clear();
  //   _commandBuffer.write(':');
  // }
  //
  // void _executeCommand() {
  //   if (_commandBuffer.toString().trim() == ':q') {
  //     if (Platform.isWindows) {
  //       _restoreWindowsConsoleMode();
  //     } else {
  //       stdin
  //         ..echoMode = true
  //         ..lineMode = true;
  //     }
  //     stdout.write('\x1B[?1049l');
  //     stop();
  //     exit(0);
  //   }
  //   _commandBuffer.clear();
  // }
}
