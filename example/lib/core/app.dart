import 'dart:math';

import 'package:example/components/colors.dart';
import 'package:example/components/input_handler.dart';
import 'package:example/components/text_component.dart';
import 'package:example/components/text_component_style.dart';
import 'package:example/core/axis.dart';
import 'package:example/core/canvas_buffer.dart';
import 'package:example/core/component.dart';
import 'package:example/core/interactable_registry.dart';
import 'package:example/core/position.dart';
import 'package:example/core/rect.dart';
import 'package:example/core/row.dart';
import 'package:example/core/size.dart';
import 'package:example/layout_engine/layout_engine.dart';
import 'package:example/manager/command_mode_handler.dart';
import 'package:example/manager/focus_manager.dart';
import 'package:example/manager/input_dispatcher.dart';
import 'package:example/manager/input_manager.dart';
import 'package:example/renderer/renderer.dart';

class App extends Component with ParentComponent {
  @override
  final List<Component> children;
  final Axis direction;

  App({
    required this.children,
    this.direction = Axis.vertical,
  });

  @override
  Size measure(Size maxSize) {
    int totalHeight = 0;
    int maxWidth = 0;

    // TODO: handle when direction is horizontal
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
    final LayoutEngine engine = LayoutEngine(
      children: children,
      direction: direction,
      bounds: bounds,
    );

    final positionedItems = engine.compute();

    for (var item in positionedItems) {
      final component = item.component;
      component.render(
        buffer,
        item.rect,
      );
    }
  }

  @override
  int fitHeight() {
    // TODO: implement fitHeight
    throw UnimplementedError();
  }

  @override
  int fitWidth() {
    // TODO: implement fitWidth
    throw UnimplementedError();
  }
}

extension AppRunner on App {
  void run() {
    final terminalWidth = 80;
    final terminalHeight = 44;

    final buffer = CanvasBuffer(width: terminalWidth, height: terminalHeight);
    final Renderer renderer = Renderer(buffer: buffer);

    final InputDispatcher dispatcher = InputDispatcher(renderer: renderer);
    final FocusManager focusManager = FocusManager();
    final InteractableRegistry registry = InteractableRegistry();

    registry.registerInteractables(this, focusManager);

    final List<InputHandler> handlers = [
      focusManager,
      CommandModeHandler(),
    ];

    for (var handler in handlers) {
      dispatcher.registerHandler(handler);
    }
    final InputManager inputManager = InputManager(dispatcher: dispatcher);

    inputManager.getCursorPosition((x, y) {
      buffer.setTerminalOffset(x + 1, y + 1);
    });

    final measuredSize = measure(Size(
      width: terminalWidth,
      height: terminalHeight,
    ));

    final bounds = Rect(
      x: 0,
      y: 0,
      width: measuredSize.width,
      height: measuredSize.height,
    );

    render(buffer, bounds);
    buffer.render();
  }
}

void main() {
  App(children: [
    TextComponent(
      'Water',
      style: TextComponentStyle()
          .foreground(ColorRGB(255, 255, 255))
          .paddingTop(2)
          .paddingLeft(2)
          .paddingRight(2)
          .paddingBottom(2)
          .italic()
          .background(ColorRGB(51, 153, 255)),
    ),
    TextComponent(
      '',
      style: TextComponentStyle(),
    ),
    TextComponent(
      'Fire',
      style: TextComponentStyle()
          .foreground(ColorRGB(255, 255, 255))
          .paddingTop(2)
          .paddingLeft(2)
          .paddingRight(10)
          .paddingBottom(2)
          .marginLeft(10)
          .underline()
          .background(ColorRGB(255, 68, 34)),
    ),
    Row(children: [
      TextComponent(
        'Ice',
        style: TextComponentStyle()
            .foreground(ColorRGB(255, 255, 255))
            .paddingTop(2)
            .paddingLeft(2)
            .paddingRight(2)
            .paddingBottom(2)
            .italic()
            .background(ColorRGB(102, 204, 255)),
      ),
      TextComponent(
        '',
        style: TextComponentStyle(),
      ),
      TextComponent(
        'Ghost',
        style: TextComponentStyle()
            .foreground(ColorRGB(255, 255, 255))
            .paddingLeft(2)
            .paddingRight(2)
            .underline()
            .background(ColorRGB(102, 102, 182)),
      ),
    ])
  ]).run();
}
