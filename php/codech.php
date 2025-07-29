#!/usr/bin/env php
<?php

function main(array $argv) {
    $matrix = Matrix::from_file($argv[1]);
    $content = binRead($argv[3]);
    if ($argv[2] === "--encode" || $argv[2] === "-e") {
        $result = encode($matrix, $content);
        file_put_contents(
            "codech.log",
            pack("c*", ...decode($matrix, $result)),
            FILE_APPEND
        );
    } else {
        $result = decode($matrix, $content);
    }
    binWrite($argv[4], $result);
}

function binRead(string $filename): array {
    $handle = fopen($filename, "rb");
    $content = fread($handle, filesize($filename));
    fclose($handle);
    return array_values(unpack("c*", $content));
}

function binWrite(string $filename, array $contents) {
    $handle = fopen($filename, "wb");
    fwrite($handle, pack("c*", ...$contents));
    fclose($handle);
}

/**
 * @param Matrix $matrix
 * @param int[] $bytes
 * @return int[]
 */
function encode(Matrix $matrix, array $bytes): array {
    $encoded = [];
    foreach ($bytes as $byte) {
        $encoded[] = $matrix->encode[$byte & 0x0F];
        $encoded[] = $matrix->encode[($byte >> 4) & 0x0F];
    }
    return $encoded;
}

/**
 * @param Matrix $matrix
 * @param int[] $bytes
 * @return int[]
 */
function decode(Matrix $matrix, array $bytes): array {
    $decoded = [];
    for ($i = 0; $i < count($bytes); $i += 2) {
        [$a, $b] = [$bytes[$i], $bytes[$i + 1]];
        $p1 = $matrix->decode[abs($a)];
        $p2 = $matrix->decode[abs($b)] << 4;
        $decoded[] = $p1 | $p2;
    }
    return $decoded;
}

class Matrix {
    /**
     * @var int[]
     */
    public array $encode;
    /**
     * @var int[]
     */
    public array $decode;

    private function __construct($encode, $decode) {
        $this->encode = $encode;
        $this->decode = $decode;
    }

    public static function from_file(string $filename): Matrix {
        $content = explode(' ', substr(file_get_contents($filename), 5, 35));
        $nums = [];
        foreach ($content as $num_str) {
            $nums[] = intval($num_str, 2);
        }
        $encode = Matrix::flatten($nums);
        $decode = Matrix::reverse($encode);
        return new Matrix($encode, $decode);
    }

    private static function flatten(array $key): array {
        return [
            $key[0] ^ $key[1] ^ $key[2] ^ $key[3],
            $key[3],
            $key[2],
            $key[2] ^ $key[3],
            $key[1],
            $key[1] ^ $key[3],
            $key[1] ^ $key[2],
            $key[1] ^ $key[2] ^ $key[3],
            $key[0],
            $key[0] ^ $key[3],
            $key[0] ^ $key[2],
            $key[0] ^ $key[2] ^ $key[3],
            $key[0] ^ $key[1],
            $key[0] ^ $key[1] ^ $key[3],
            $key[0] ^ $key[1] ^ $key[2],
            0,
        ];
    }

    private static function reverse(array $matrix): array {
        $reverse = array_fill(0, 256, 0);
        for ($i = 0; $i < count($matrix); $i += 1) {
            $reverse[$matrix[$i]] = $i;
        }
        return $reverse;
    }
}

main($argv);
