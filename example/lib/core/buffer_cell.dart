import 'package:example/components/colors.dart';
import 'package:example/components/font_style.dart';

class BufferCell {
    final String char;
    final AnsiColorType? fg;
    final AnsiColorType? bg;
    final Set<FontStyle> styles;

    BufferCell({
        required this.char,
        this.fg,
        this.bg,
        Set<FontStyle>? styles,
        }): styles = styles ?? {};

    @override
    bool operator ==(Object other) {
          return other is BufferCell && (
            other.char == char &&
            other.fg == fg &&
            other.bg == bg &&
            _setEquals(other.styles, styles)
          );
      }

    @override
    int get hashCode => Object.hash(char, fg, bg, Object.hashAllUnordered(styles));

      bool _setEquals(Set a, Set b) {
          return a.length == b.length && a.containsAll(b);
      }
}
