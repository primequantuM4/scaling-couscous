import 'package:example/components/colors.dart';
import 'package:example/components/font_style.dart';
import 'package:example/core/buffer_cell.dart';
import 'package:test/test.dart';

void main() {
  group('BufferCell equality', () {
    test('Should be equal when all fields match', () {
      final cell1 = BufferCell(
        char: 'A',
        fg: Colors.red,
        bg: ColorRGB(0, 0, 0),
        styles: {FontStyle.Bold},
      );
      final cell2 = BufferCell(
        char: 'A',
        fg: Colors.red,
        bg: ColorRGB(0, 0, 0),
        styles: {FontStyle.Bold},
      );
      expect(cell1 == cell2, isTrue);
    });

    test('Should not be equal when one or more field differs', () {
      final cell1 = BufferCell(
        char: 'A',
        fg: Colors.red,
        bg: ColorRGB(0, 0, 0),
        styles: {FontStyle.Bold},
      );
      final cell2 = BufferCell(
        char: 'A',
        fg: Colors.red,
        bg: ColorRGB(0, 0, 0),
        styles: {FontStyle.Italic},
      );

      expect(cell1 == cell2, isFalse);
    });
  });
}
