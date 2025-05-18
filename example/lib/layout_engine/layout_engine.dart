import 'package:example/core/axis.dart';
import 'package:example/core/component.dart';
import 'package:example/core/position.dart';
import 'package:example/core/rect.dart';
import 'package:example/core/size.dart';
import 'package:example/layout_engine/positioned_component.dart';

class LayoutEngine {
  final List<Component> children;
  final Axis direction;
  final Rect bounds;

  LayoutEngine({
    required this.children,
    required this.direction,
    required this.bounds,
  });

  List<PositionedComponent> compute() {
    int cursorX = bounds.x;
    int cursorY = bounds.y;

    final List<PositionedComponent> result = [];

    for (final child in children) {
      final size = child.measure(
        Size(
          width: bounds.width,
          height: bounds.height,
        ),
      );

      if (child.position?.positionType == PositionType.absolute) {
        result.add(
          PositionedComponent(
            component: child,
            rect: Rect(
              x: child.position!.x,
              y: child.position!.y,
              width: size.width,
              height: size.height,
            ),
          ),
        );
        continue;
      }

      final xVal = direction == Axis.vertical ? bounds.x : cursorX;
      final yVal = direction == Axis.vertical ? cursorY : bounds.y;

      final Rect childBounds;
      if (child.position == null) {
        childBounds = Rect(
          x: xVal,
          y: yVal,
          width: size.width,
          height: size.height,
        );
      } else {
        childBounds = Rect(
          x: xVal + child.position!.x,
          y: yVal + child.position!.y,
          width: size.width,
          height: size.height,
        );
      }

      result.add(PositionedComponent(component: child, rect: childBounds));

      if (direction == Axis.vertical) {
        cursorY += size.height;
      } else {
        cursorX += size.width;
      }
    }

    return result;
  }
}
