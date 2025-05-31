import 'package:example/core/canvas_buffer.dart';
import 'package:example/core/component.dart';

class Renderer {
  final CanvasBuffer buffer;

  final List<Component> _dirtyComponents = [];

  Renderer({
    required this.buffer,
  });

  void markDirty(Component comp) => _dirtyComponents.add(comp);

  void requestRedraw() {
    print("i am being requested");
    for (var component in _dirtyComponents) {
      buffer.clearArea(component.getBounds());
      buffer.flushArea(component.getBounds());
      component.render(buffer, component.getBounds());
    }

    _dirtyComponents.clear();
    render();
  }

  void render() {
    buffer.render();
  }
}
