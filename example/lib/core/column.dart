import 'dart:math';

import 'package:example/core/axis.dart';
import 'package:example/core/canvas_buffer.dart';
import 'package:example/core/component.dart';
import 'package:example/core/position.dart';
import 'package:example/core/rect.dart';
import 'package:example/core/size.dart';
import 'package:example/layout_engine/layout_engine.dart';

class Column extends Component {
  final List<Component> children;

  Column({required this.children});

  @override
  Size measure(Size maxSize) {
    int totalHeight = 0;
    int maxWidth = 0;

    for (final child in children) {
      if (child.position?.positionType == PositionType.absolute) continue;

      final childSize = child.measure(maxSize);
      totalHeight += childSize.height;

      maxWidth = max(childSize.width, maxWidth);
    }

    return Size(width: maxWidth, height: totalHeight);
  }

  @override
  void render(CanvasBuffer buffer, Rect bounds) {
    final engine = LayoutEngine(
        children: children, direction: Axis.vertical, bounds: bounds);

    final positionedItems = engine.compute();

    for (final item in positionedItems) {
      item.component.render(buffer, item.rect);
    }
  }
}
