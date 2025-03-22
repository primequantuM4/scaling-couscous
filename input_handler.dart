import 'dart:async';
import 'dart:convert';
import 'dart:io';

abstract class InputHandler {
  StreamSubscription<List<int>>? _subscription;
  bool _originalEchoMode = false;
  bool _originalLineMode = false;

  void startListening() {
    try {
      _originalEchoMode = stdin.echoMode;
      _originalLineMode = stdin.lineMode;
      stdin.echoMode = false;
      stdin.lineMode = false;
      _subscription = stdin.listen((event) => handleInput(utf8.decode(event)));
    } catch (e) {}
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;

    if (Platform.isWindows) return;
    try {
      stdin.echoMode = _originalEchoMode;
      stdin.lineMode = _originalLineMode;
    } catch (e) {}
  }

  void handleInput(String input);
}
