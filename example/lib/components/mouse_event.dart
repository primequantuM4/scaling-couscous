import 'dart:io';
import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

enum MouseEventType { click, release, hover }

class MouseEvent {
  final MouseEventType type;
  final int x;
  final int y;
  final int button;

  MouseEvent(this.type, this.x, this.y, this.button);

  @override
  String toString() {
    return 'MouseEvent{type: $type, x: $x, y: $y, button: $button}';
  }
}

class MouseHandler {
  String _buffer = '';
  Function(MouseEvent)? onEvent;

  void start() {
    stdin
      ..echoMode = false
      ..lineMode = false;

    stdout.write('\x1B[?1006h\x1B[?1003h');

    if (Platform.isWindows) {
      _enableWindowsAnsi();
    }
    stdin.listen(_onData);
  }

  void stop() {
    if (Platform.isWindows) {
      _restoreWindowsConsoleMode();
    }
    stdout.write('\x1B[?1006l\x1B[?1003l');
  }

  void _onData(List<int> data) {
    _buffer += String.fromCharCodes(data);
    _processBuffer();
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

  void _processBuffer() {
    while (true) {
      int start = _buffer.indexOf('\x1B[<');
      if (start == -1) break;

      int end = _buffer.indexOf('M', start);
      if (end == -1) {
        end = _buffer.indexOf('m', start);
        if (end == -1) break;
      }

      String sequence = _buffer.substring(start, end + 1);
      _buffer = _buffer.substring(end + 1);
      _parseMouseEvent(sequence);
    }

    if (_buffer.contains('q')) {
      stop();
      exit(0);
    }
  }

  void _parseMouseEvent(String sequence) {
    try {
      String data = sequence.substring(3, sequence.length - 1);
      List<String> parts = data.split(';');
      if (parts.length != 3) return;

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

      onEvent?.call(MouseEvent(type, x, y, button));
    } catch (e) {
      print('Error parsing mouse event: $e');
    }
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
}

void main() async {
  final mouseHandler = MouseHandler();

  mouseHandler.onEvent = (event) {
    print('Mouse event: $event');
  };

  mouseHandler.start();

  print('Mouse TUI Test (press q to quit)');
  print('Click and move the mouse to test...');

  await Completer<void>().future;
}
