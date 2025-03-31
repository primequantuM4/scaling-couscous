import 'package:example/components/mouse_event.dart';

import 'input_manager.dart';

abstract class InputHandler {
  void startListening() => InputManager().registerHandler(this);
  void stopListening() => InputManager().unregisterHandler(this);
  void getCursorPosition(void Function(int x, int y) callback) =>
      InputManager().getCursorPosition(callback);
  void handleInput(String input);

  set onMouseEvent(Function(MouseEvent) callback) =>
      InputManager().onEvent = callback;
}
