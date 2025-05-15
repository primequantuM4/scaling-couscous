import 'package:example/core/canvas_buffer.dart';
import 'package:example/core/rect.dart';
import 'package:example/core/size.dart';

abstract class Component {
    Size measure(Size maxSize);
    void render(CanvasBuffer buffer, Rect bounds);
}
