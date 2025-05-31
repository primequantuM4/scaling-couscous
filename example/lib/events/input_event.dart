sealed class InputEvent {
  const InputEvent();
}

class CharEvent extends InputEvent {
  final String buffer;

  const CharEvent({required this.buffer});
}

class SequenceEvent extends InputEvent {
  final List<int> sequence;

  const SequenceEvent({required this.sequence});
}

class WindowsSequenceEvent extends InputEvent {
  final List<int> sequence;
  const WindowsSequenceEvent({required this.sequence});
}

class TabEvent extends InputEvent {}

class ShiftTabEvent extends InputEvent {}

class EscapeEvent extends InputEvent {}

class MouseEvent extends InputEvent {
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

class UnknownEvent extends InputEvent {
  final int? byte;

  const UnknownEvent({this.byte});
}

enum MouseEventType { click, release, hover, error }
