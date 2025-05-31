// abstract class InputHandler {
//   void startListening() => InputManager().registerHandler(this);
//   void stopListening() => InputManager().unregisterHandler(this);
//   void getCursorPosition(void Function(int x, int y) callback) =>
//       InputManager().getCursorPosition(callback);
//   void handleInput(String input);
//
//   set onMouseEvent(Function(MouseEvent) callback) =>
//       InputManager().onEvent = callback;
// }

import 'package:example/events/input_event.dart';
import 'package:example/manager/response_input.dart';

abstract class InputHandler {
  ResponseInput handleInput(InputEvent event);
}
