import 'dart:math';

import 'package:example/components/text_component.dart';
import 'package:example/components/text_component_style.dart';
import 'package:example/core/axis.dart';
import 'package:example/core/component.dart';
import 'package:example/core/position.dart';
import 'package:example/core/rect.dart';
import 'package:example/core/size.dart';
import 'package:example/layout_engine/positioned_component.dart';

// Calculate the needed width for the component to span..
// Expand/Shrink the widths by checking the maximum width that is allowed to be expanded upon
// wrap the text.
// Calculate the needed height for the component to span vertically
// Expand the height by checking the maximum allowed height that is allowed to be expanded upon
// position the component where it needs to be
// Draw it to Canvas Buffer (layout engine is not concerned here).

// horizontal on axis is padding.left + padding.right + (children.length - 1) * childGap + sum(child.width)
// vertical axis is padding.top + padding.bottom + max(child.height)

// vertical on axis is padding.top + padding.bottom + (children.length - 1) * childGap + sum(child.height)
// horizontal axis is padding.left + padding.right + max(child.width)

const int INF = 1000000;

class LayoutEngine {
  final List<Component> children;
  final Axis direction;
  final Rect bounds;
  final int childGap = 1;

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
        final bounds = Rect(
          x: child.position!.x,
          y: child.position!.y,
          width: size.width,
          height: size.height,
        );
        result.add(
          PositionedComponent(
            component: child,
            rect: bounds,
          ),
        );
        child.setBounds(bounds);
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
      child.setBounds(childBounds);

      if (direction == Axis.vertical) {
        cursorY += size.height;
      } else {
        cursorX += size.width;
      }
    }

    return result;
  }

  int fitWidth() {
    if (children.isEmpty) return 0;
    int requiredWidth = 0;

    if (direction == Axis.horizontal) {
      requiredWidth += ((children.length - 1) * childGap);
    }

    for (var child in children) {
      if (direction == Axis.horizontal) {
        requiredWidth += child.fitWidth();
      } else {
        requiredWidth = max(child.fitWidth(), requiredWidth);
      }
    }

    return requiredWidth;
  }

  int fitHeight() {
    if (children.isEmpty) return 0;
    int requiredHeight = 0;

    if (direction == Axis.vertical) {
      requiredHeight += ((children.length - 1) * childGap);
    }

    for (var child in children) {
      if (direction == Axis.vertical) {
        requiredHeight += child.fitHeight();
      } else {
        requiredHeight = max(requiredHeight, child.fitHeight());
      }
    }

    return requiredHeight;
  }
}

void main() {
  final firstText = "hello world!";
  final secondText = "what is your name";

  final List<Component> components = [
    TextComponent(firstText, style: TextComponentStyle()),
    TextComponent(secondText, style: TextComponentStyle()),
  ];

  final engine = LayoutEngine(
      children: components,
      direction: Axis.horizontal,
      bounds: Rect(
        x: 0,
        y: 0,
        width: 80,
        height: 24,
      ));
  print("Expected width: ${firstText.length + 1 + secondText.length}");
  print("Actual width: ${engine.fitWidth()}");
}
