import 'input_manager.dart';

abstract class InputHandler {
  void startListening() => InputManager().registerHandler(this);
  void stopListening() => InputManager().unregisterHandler(this);
  void handleInput(String input);
}
