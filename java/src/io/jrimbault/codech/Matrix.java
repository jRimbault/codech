package io.jrimbault.codech;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class Matrix {
    public final byte[] encode;
    public final byte[] decode;

    private Matrix(byte[] encode) {
        this.encode = encode;
        this.decode = new byte[255];
        for (var i = 0; i < encode.length; i += 1) {
            this.decode[encode[i] & 0xFF] = (byte) i;
        }
    }

    public static Matrix fromFile(String filename) throws IOException {
        return new Matrix(matrixFromKey(readKey(filename)));
    }

    private static byte[] matrixFromKey(List<Byte> key) {
        var matrix = new byte[16];
        matrix[15] = 0;
        matrix[1] = key.get(3);
        matrix[2] = key.get(2);
        matrix[3] = (byte) (key.get(2) ^ key.get(3));
        matrix[4] = key.get(1);
        matrix[5] = (byte) (key.get(1) ^ key.get(3));
        matrix[6] = (byte) (key.get(1) ^ key.get(2));
        matrix[7] = (byte) (key.get(1) ^ key.get(2) ^ key.get(3));
        matrix[8] = key.get(0);
        matrix[9] = (byte) (key.get(0) ^ key.get(3));
        matrix[10] = (byte) (key.get(0) ^ key.get(2));
        matrix[11] = (byte) (key.get(0) ^ key.get(2) ^ key.get(3));
        matrix[12] = (byte) (key.get(0) ^ key.get(1));
        matrix[13] = (byte) (key.get(0) ^ key.get(1) ^ key.get(3));
        matrix[14] = (byte) (key.get(0) ^ key.get(1) ^ key.get(2));
        matrix[0] = (byte) (key.get(0) ^ key.get(1) ^ key.get(2) ^ key.get(3));
        return matrix;
    }

    private static List<Byte> readKey(String filename) throws IOException {
        return Arrays.asList(Files.readString(Paths.get(filename))
            .substring(5, 40)
            .split(" "))
            .stream()
            .map(bin -> (byte) Integer.parseInt(bin, 2))
            .collect(Collectors.toList());
    }
}
