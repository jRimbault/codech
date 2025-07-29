package io.jrimbault.codech;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.function.Function;

public class Main {
    public static void main(String[] args) throws IOException {
        var codec = new Codec(Matrix.fromFile(args[0]));
        if (args[1].equals("--encode") || args[1].equals("-e")) {
            work(codec::encode, args[2], args[3]);
        } else {
            work(codec::decode, args[2], args[3]);
        }
    }

    private static void work(Function<byte[], byte[]> codec, String source, String dest) throws IOException {
        var content = Files.readAllBytes(Paths.get(source));
        var result = codec.apply(content);
        Files.write(Paths.get(dest), result);
    }
}
