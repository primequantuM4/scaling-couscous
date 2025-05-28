import 'package:example/components/input_manager.dart';
import 'package:example/components/text_field_component.dart';
import 'package:example/core/app.dart';

void main() async {
  final tf1 = TextfieldComponent(placeHolder: "Name");
  final tf2 = TextfieldComponent(placeHolder: "Email");
  final tf3 = TextfieldComponent(placeHolder: "Password");

  final inputManager = InputManager();
  final focusManager = inputManager.focusManager;

  focusManager.register(tf1);
  focusManager.register(tf2);
  focusManager.register(tf3);

  App(children: [
    tf1,
    tf2,
    tf3,
  ]).run();
}
