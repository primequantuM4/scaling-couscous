import 'colors.dart';
import 'font_style.dart';

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
    bgColor = color;
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
