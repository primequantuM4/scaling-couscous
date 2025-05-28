import 'package:example/components/input_handler.dart';
import 'package:example/core/canvas_buffer.dart';
import 'package:example/core/component.dart';

abstract class FocusableComponent extends Component implements InputHandler {
  bool isFocused = false;
  late CanvasBuffer canvas;

  void attachCanvas(CanvasBuffer canvas) {
    this.canvas = canvas;
  }

  void blur() {
    isFocused = false;
    stopListening();
    onBlur();
    canvas.clearArea(getBounds());
    canvas.flushArea(getBounds());

    return;
  }

  void focus() {
    isFocused = true;
    startListening();
    onFocus();

    canvas.clearArea(getBounds());
    canvas.flushArea(getBounds());

    canvas.render();
    return;
  }

  void onFocus();
  void onBlur();

  void clear();
  void draw();

  @override
  void handleInput(String input);
}
