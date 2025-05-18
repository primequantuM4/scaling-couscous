import 'package:example/core/component.dart';
import 'package:example/core/rect.dart';

class PositionedComponent {
  final Component component;
  final Rect rect;

  PositionedComponent({
    required this.component,
    required this.rect,
  });
}
