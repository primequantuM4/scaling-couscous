import 'dart:io';
import 'dart:convert';

class MouseInputHandler {
  static final _instance = MouseInputHandler._internal();

  MouseInputHandler._internal();

  factory MouseInputHandler() => _instance;

  void startListening() {
    stdin.echoMode = false;
    stdin.lineMode = false;
    stdout.write('\x1B[?1000h'); // Enable basic mouse tracking
    stdout.write('\x1B[?1006h'); // Enable extended SGR mouse mode

    stdin.listen((List<int> data) {
      final input = utf8.decode(data);
      handleMouseInput(input);
    });
  }

  void stopListening() {
    stdout.write('\x1B[?1000l'); // Disable mouse tracking
    stdout.write('\x1B[?1006l'); // Disable SGR extended mode
  }

  void handleMouseInput(String input) {
    final regex = RegExp(r'\x1B\[(\d+);(\d+);(\d+)([Mm])');
    final match = regex.firstMatch(input);

    print('There is a Mouse Event $input');
    if (match != null) {
      int buttonCode = int.parse(match.group(1)!);
      int x = int.parse(match.group(2)!);
      int y = int.parse(match.group(3)!);
      bool isPressed = match.group(4) == 'M';

      print(
          'Mouse Event -> Button: $buttonCode, X: $x, Y: $y, Pressed: $isPressed');
    }
  }
}

void main() {
  print("Mouse test started. Click anywhere in the terminal.");
  MouseInputHandler().startListening();
}
