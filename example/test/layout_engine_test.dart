import 'package:example/components/text_component.dart';
import 'package:example/components/text_component_style.dart';
import 'package:example/core/axis.dart';
import 'package:example/core/component.dart';
import 'package:example/core/rect.dart';
import 'package:example/layout_engine/layout_engine.dart';
import 'package:test/test.dart';

void main() {
  group('initial width and height fitting pre size requirements', () {
    test('calculated width and expected width should match', () {
      final firstText = "hello world!";
      final secondText = "what is your name";

      final List<Component> children = [
        TextComponent(firstText, style: TextComponentStyle()),
        TextComponent(secondText, style: TextComponentStyle()),
      ];
      final direction = Axis.horizontal;
      final bounds = Rect(
        x: 0,
        y: 0,
        width: 80,
        height: 24,
      ); // arbitrary number of width and height;
      final engine = LayoutEngine(
          children: children, direction: direction, bounds: bounds);
      final expectedWidth = firstText.length + secondText.length + 1;
      final actualWidth = engine.fitWidth();

      final expectedHeight = 1;
      final actualHeight = engine.fitHeight();

      expect(expectedWidth, actualWidth);
      expect(expectedHeight, actualHeight);
    });
  });
}
