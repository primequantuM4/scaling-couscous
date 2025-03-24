import 'dart:async';
import 'dart:io';

import 'package:example/components/colors.dart';
import 'package:example/components/text_component_style.dart';

class Spinner {
  final List<String> frames;
  final AnsiColorType color;
  final Duration interval;
  bool _running = false;
  int _index = 0;
  Timer? _timer;

  Spinner({
    AnsiColorType? color,
    this.frames = const ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'],
    this.interval = const Duration(milliseconds: 100),
  }) : color = color ?? ColorRGB(255, 255, 255);

  void start({String message = ''}) {
    if (_running) return;
    _running = true;

    _timer = Timer.periodic(interval, (_) {
      final TextComponentStyle frameStyle =
          TextComponentStyle().foreground(color);
      stdout.write('\r${frameStyle.render(frames[_index])} $message');
      _index = (_index + 1) % frames.length;
    });
  }

  void stop({String message = 'Done'}) {
    if (!_running) return;
    _running = false;
    _timer?.cancel();
    stdout.write("\x1B[2K");
    stdout.write('\r$message\n');
  }
}

