import 'package:example/core/canvas_buffer.dart';
import 'package:example/core/position.dart';
import 'package:example/core/rect.dart';
import 'package:example/core/size.dart';

abstract class Component {
  final Position? position;

  Rect? _bounds;

  void setBounds(Rect bounds) {
    _bounds = bounds;
  }

  Rect getBounds() {
    if (_bounds == null) throw Exception("Component bounds not set yet");
    return _bounds!;
  }

  Component({this.position});

  Size measure(Size maxSize);
  int fitWidth();
  int fitHeight();
  void render(CanvasBuffer buffer, Rect bounds);
}
