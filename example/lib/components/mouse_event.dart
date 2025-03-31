enum MouseEventType { click, release, hover }

class MouseEvent {
  final MouseEventType type;
  final int x;
  final int y;
  final int button;

  MouseEvent(this.type, this.x, this.y, this.button);

  @override
  String toString() {
    return 'MouseEvent{type: $type, x: $x, y: $y, button: $button}';
  }
}
