import 'package:example/core/canvas_buffer.dart';
import 'package:example/core/position.dart';
import 'package:example/core/rect.dart';
import 'package:example/core/size.dart';

abstract class Component {
  final Position? position;

  Component({this.position});

  Size measure(Size maxSize);
  void render(CanvasBuffer buffer, Rect bounds);
}
