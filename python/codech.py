#!/usr/bin/env python3

import argparse
import itertools
import math
import multiprocessing
import typing
from dataclasses import dataclass
from typing import Callable, List, Sequence, Union


def main(args) -> int:
    with open(args.keyfile) as stream:
        key = [int(c, 2) for c in stream.read()[5:40].split()]
    matrix = build_matrix(key)
    if args.encode:
        return work(Worker(matrix, encode), args.source, args.dest)
    if args.decode:
        return work(Worker(matrix, decode), args.source, args.dest)

    return 1


EncodeLookup = typing.NewType("EncodeLookup", typing.List[int])
DecodeLookup = typing.NewType("DecodeLookup", typing.Dict[int, int])


@dataclass
class Matrix:
    encode: EncodeLookup
    decode: DecodeLookup


@dataclass
class Worker:
    matrix: Matrix
    codec: Callable[..., Sequence[int]]
    # codec: Callable[[Matrix, Sequence[int]], Sequence[int]]

    def __call__(self, stream: Sequence[int]) -> Sequence[int]:
        return self.codec(self.matrix, stream)


def work(worker: Worker, source: str, dest: str) -> int:
    with open(source, "rb") as stream:
        # single process is better under a certain amount
        # result = worker(stream.read())
        with multiprocessing.Pool(num_workers()) as pool:
            result = pool.map(worker, stream)

    with open(dest, "wb") as out:
        # single process
        # out.write(bytearray(result))
        for part in result:
            out.write(bytearray(part))

    return 0


def encode(matrix: Matrix, stream: Sequence[int]) -> Sequence[int]:
    lookup = matrix.encode
    return [el for ch in stream for el in (lookup[ch & 0x0F], lookup[(ch >> 4) & 0x0F])]


def decode(matrix: Matrix, stream: Sequence[int]) -> Sequence[int]:
    lookup = matrix.decode
    return [
        lookup[stream[i]] | (lookup[stream[i + 1]] << 4)
        for i in range(0, len(stream), 2)
    ]


def build_matrix(key: List[int]) -> Matrix:
    encode_lookup = typing.cast(
        EncodeLookup,
        [
            key[0] ^ key[1] ^ key[2] ^ key[3],
            key[3],
            key[2],
            key[2] ^ key[3],
            key[1],
            key[1] ^ key[3],
            key[1] ^ key[2],
            key[1] ^ key[2] ^ key[3],
            key[0],
            key[0] ^ key[3],
            key[0] ^ key[2],
            key[0] ^ key[2] ^ key[3],
            key[0] ^ key[1],
            key[0] ^ key[1] ^ key[3],
            key[0] ^ key[1] ^ key[2],
            0,
        ],
    )
    decode_lookup = typing.cast(
        DecodeLookup, {e: i for i, e in enumerate(encode_lookup)}
    )
    return Matrix(encode_lookup, decode_lookup)


def num_workers() -> int:
    return 2 ** int(math.log2(multiprocessing.cpu_count()))


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("keyfile")
    parser.add_argument("source")
    parser.add_argument("dest")
    group = parser.add_argument_group()
    group.add_argument("-e", "--encode", action="store_true")
    group.add_argument("-d", "--decode", action="store_true")
    return parser.parse_args()


if __name__ == "__main__":
    exit(main(parse_args()))
