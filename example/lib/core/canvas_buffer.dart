import 'dart:io';

import 'package:example/components/colors.dart';
import 'package:example/components/font_style.dart';
import 'package:example/components/text_component_style.dart';
import 'package:example/core/buffer_cell.dart';

class CanvasBuffer {
    final int width;
    final int height;

    final List<List<BufferCell>> _screenBuffer;

    CanvasBuffer({required this.width, required this.height}): 
        _screenBuffer = List.generate(height, (_) => List.filled(width, BufferCell(char: ' ')));

    void drawChar(int x, int y, String char, {
        AnsiColorType? fg,
        AnsiColorType? bg,
        Set<FontStyle>? styles,
        }) {

        if (x >= 0 && x < width && y >= 0 && y < height) {
            _screenBuffer[y][x] = BufferCell(char: char, fg: fg, bg: bg, styles: styles);
        }
    }
    void drawAt(int x, int y, String data, TextComponentStyle style) {
        for (int i = 0; i < data.length; i++) {
            drawChar(x + i, y, data[i], fg: style.color, bg: style.bgColor, styles: style.styles);
        }
    }

    void render() {
        for (var row in _screenBuffer) {
            final buffer = StringBuffer();
            BufferCell? lastCell;

            for (final cell in row) {
                if (lastCell == null || !_sameStyle(cell, lastCell)) {
                    if (lastCell == null) buffer.write('\x1B[0m');
                    buffer.write(_ansiCode(cell));
                    lastCell = cell;
                }
                buffer.write(cell.char);
            }
            buffer.write('\x1B[0m');
            stdout.write(buffer.toString());
        }

    }

    bool _sameStyle(BufferCell cell, BufferCell lastCell) {
        return cell == lastCell;
    }

    String _ansiCode(BufferCell cell) {
        final style = TextComponentStyle();
        style.color = cell.fg;
        style.bgColor = cell.bg;
        style.styles = cell.styles;

        return style.render('');
    }

    // for testing purposes
    List<List<BufferCell>> getDrawnCanvas() {
        return _screenBuffer;
    }
}

