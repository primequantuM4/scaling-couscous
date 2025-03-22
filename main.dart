import 'dart:io';

abstract class Component {
  String render();
  void handleInput(String input);
}

abstract class AnsiColorType {
  String get fg;
  String get bg;
}

class TextComponentInput implements Component {
  List<String> value = [];
  bool focused = true;
  final TextComponentStyle textStyle;

  TextComponentInput({TextComponentStyle? textStyle})
      : textStyle = textStyle ?? TextComponentStyle();

  @override
  String render() {
    final String displayText =
        focused ? '> ${value.join("")}' : ' ${value.join("")} ';
    return textStyle.render(displayText);
  }

  @override
  void handleInput(String input) {
    if (input == '\n') {
      focused = false;
    } else if (input == '\b' && value.isNotEmpty) {
      value.removeLast();
    } else {
      value.add(input);
    }
  }
}

class TextComponentStyle {
  AnsiColorType? color;
  AnsiColorType? bgColor;
  final Set<FontStyle> _fontStyles = {};

  int _paddingLeft = 0;
  int _paddingRight = 0;
  int _paddingTop = 0;
  int _paddingBottom = 0;

  int _marginLeft = 0;
  int _marginRight = 0;
  int _marginTop = 0;
  int _marginBottom = 0;

  TextComponentStyle foreground(AnsiColorType color) {
    this.color = color;
    return this;
  }

  TextComponentStyle background(AnsiColorType color) {
    this.bgColor = color;
    return this;
  }

  TextComponentStyle bold() {
    _fontStyles.add(FontStyle.Bold);
    return this;
  }

  TextComponentStyle italic() {
    _fontStyles.add(FontStyle.Italic);
    return this;
  }

  TextComponentStyle underline() {
    _fontStyles.add(FontStyle.Underline);
    return this;
  }

  TextComponentStyle strikethrough() {
    _fontStyles.add(FontStyle.Strikethrough);
    return this;
  }

  TextComponentStyle paddingTop(int padding) {
    _paddingTop = padding;
    return this;
  }

  TextComponentStyle paddingLeft(int padding) {
    _paddingLeft = padding;
    return this;
  }

  TextComponentStyle paddingRight(int padding) {
    _paddingRight = padding;
    return this;
  }

  TextComponentStyle paddingBottom(int padding) {
    _paddingBottom = padding;
    return this;
  }

  TextComponentStyle marginTop(int margin) {
    _marginTop = margin;
    return this;
  }

  TextComponentStyle marginBottom(int margin) {
    _marginBottom = margin;
    return this;
  }

  TextComponentStyle marginLeft(int margin) {
    _marginLeft = margin;
    return this;
  }

  TextComponentStyle marginRight(int margin) {
    _marginRight = margin;
    return this;
  }

  List<String> _verticalPadding(String codes, int maxWidth, int paddingValue) {
    final List<String> padding = [];
    for (int i = 0; i < paddingValue; i++) {
      final String paddingContent =
          ' ' * _paddingLeft + ' ' * maxWidth + ' ' * _paddingRight;
      final String ansiPadding = '\x1B[${codes}m$paddingContent\x1B[0m';
      padding.add(ansiPadding);
    }

    return padding;
  }

  String _horizontalPadding(String codes, int paddingValue) {
    final paddingContent = ' ' * paddingValue;
    final String padding = '\x1B[${codes}m$paddingContent\x1B[0m';

    return padding;
  }

  String render(String text) {
    final codes = [
      if (color != null) color!.fg,
      if (bgColor != null) bgColor!.bg,
      for (var style in _fontStyles) style.code,
    ].join(";");

    final paddingCode = [
      if (color != null) color!.fg,
      if (bgColor != null) bgColor!.bg,
    ].join(';');

    final lines = text.split('\n');

    final maxWidth =
        lines.fold(0, (max, line) => line.length > max ? line.length : max);

    final paddedLines = lines.map((line) {
      final leftPadding = _horizontalPadding(paddingCode, _paddingLeft);
      final rightPadding = _horizontalPadding(paddingCode, _paddingRight);
      return '$leftPadding\x1B[${codes}m$line\x1B[0m$rightPadding';
    }).toList();

    final List<String> topPadding =
        _verticalPadding(paddingCode, maxWidth, _paddingTop);
    final List<String> bottomPadding =
        _verticalPadding(paddingCode, maxWidth, _paddingBottom);

    final renderedValue = [...topPadding, ...paddedLines, ...bottomPadding];
    final val = renderedValue.join('\n');

    final String render = ('\n' * _marginTop) +
        (' ' * _marginLeft) +
        val +
        (' ' * _marginRight) +
        ('\n' * _marginBottom);
    return render;
  }
}

enum FontStyle {
  Bold(1),
  Italic(3),
  Underline(4),
  Strikethrough(9);

  final int code;
  const FontStyle(this.code);
}

enum Colors implements AnsiColorType {
  black(30, 40),
  red(31, 41),
  green(32, 42),
  yellow(33, 43),
  blue(34, 44),
  magenta(35, 45),
  cyan(36, 46),
  white(37, 47),
  highBlack(90, 100),
  highRed(91, 101),
  highGreen(92, 102),
  highYellow(93, 103),
  highBlue(94, 104),
  highMagenta(95, 105),
  highCyan(96, 106),
  highWhite(97, 107);

  final int code;
  final int bgCode;
  const Colors(this.code, this.bgCode);

  @override
  String get fg => '$code';

  @override
  String get bg => '$bgCode';
}

class ColorRGB implements AnsiColorType {
  final int r, g, b;
  const ColorRGB(this.r, this.g, this.b);

  @override
  String get fg => '38;2;$r;$g;${b}';

  @override
  String get bg => '48;2;$r;$g;${b}';
}

void main() {
  var inputField = TextComponentInput();

  while (true) {
    print("\x1B[3J\x1B[2J\x1B[H"); // Clears the screen
    stdout.write(inputField.render()); // Use stdout.write instead of print

    final String input = stdin.readLineSync() ?? '';
    inputField.handleInput(input);
  }
}

