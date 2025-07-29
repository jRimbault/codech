package io.jrimbault.codech;

public class Codec {
    private static final byte MASK = 0x0F;
    private final Matrix matrix;

    public Codec(Matrix matrix) {
        this.matrix = matrix;
    }

    public byte[] encode(byte[] stream) {
        return encode(matrix, stream);
    }

    public byte[] decode(byte[] stream) {
        return decode(matrix, stream);
    }

    private static byte[] encode(Matrix matrix, byte[] stream) {
        var list = new byte[stream.length * 2];
        for (var i = 0; i < stream.length; i += 1) {
            list[i * 2] = matrix.encode[stream[i] & MASK];
            list[i * 2 + 1] = matrix.encode[(stream[i] >> 4) & MASK];
        }
        return list;
    }

    private static byte[] decode(Matrix matrix, byte[] stream) {
        var list = new byte[stream.length / 2];
        for (var i = 0; i < stream.length; i += 2) {
            var a = stream[i];
            var b = stream[i + 1];
            var p1 = matrix.decode[a & 0xFF];
            var p2 = matrix.decode[b & 0xFF] << 4;
            list[i / 2] = ((byte) (p1 | p2));
        }
        return list;
    }
}
