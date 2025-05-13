import 'package:example/components/text_component_style.dart';
import 'package:example/core/buffer_cell.dart';
import 'package:test/test.dart';
import 'package:example/core/canvas_buffer.dart';

void main() {
    group('Canvas Buffer', () {
        final List<List<BufferCell>> expectedBuffer = [
           [BufferCell(char: 'H'), BufferCell(char: 'e'), BufferCell(char: 'y')],
           [BufferCell(char: 'T'), BufferCell(char: 'h'), BufferCell(char: 'e')]
        ];
        
        final List<String> expectedRenderedBuff = [
            '\x1B[0mHey\x1B[0m',
            '\x1B[0mThe\x1B[0m'
        ];

        test('After creating and writing on canvas using draw at the buffer should match the expected buffer', () {
            final CanvasBuffer canvasBuffer = CanvasBuffer(width: 3, height: 2);
            canvasBuffer.drawAt(0, 0, 'Hey', TextComponentStyle());
            canvasBuffer.drawAt(0, 1, 'The', TextComponentStyle());

            
            expect(canvasBuffer.getRenderedString(), expectedRenderedBuff);
            expect(canvasBuffer.getDrawnCanvas(), expectedBuffer);
            });
        });
}
