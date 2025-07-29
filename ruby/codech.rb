#!/usr/bin/env ruby

require "ostruct"
require "io/console"


def main(args)
  matrix = Matrix.from_file args.keyfile
  if args.encode
    work(proc { |s| encode(matrix.encode, s) }, args.source, args.dest)
  end
  if args.decode
    work(proc { |s| decode(matrix.decode, s) }, args.source, args.dest)
  end
end

def work(codec, source, dest)
  content = IO.binread(source).unpack("c*")
  IO.binwrite(dest, codec.call(content).pack("c*"))
end

MASK = 0x0F

def encode(matrix, original)
  encoded = []
  for octet in original do
    encoded.push(matrix[octet & MASK])
    encoded.push(matrix[(octet >> 4) & MASK])
  end
  encoded
end

def decode(matrix, encoded)
  decoded = []
  encoded.each_slice(2) do |pair|
    p1 = matrix[pair[0]]
    p2 = matrix[pair[1]] << 4
    decoded.push(p1 | p2)
  end
  decoded
end

class Matrix
  def initialize(encode)
    @encode = encode
    @decode = self.reverse
  end

  def encode
    @encode
  end

  def decode
    @decode
  end

  def self.from_file(filename)
    self.new self.from_key File.read(filename)[5...40].split(" ").map { |bin|
      Integer(bin, 2)
    }
  end

  def self.from_key(key)
    matrix = Array.new(16)
    matrix[0] = key[0] ^ key[1] ^ key[2] ^ key[3]
    matrix[1] = key[3]
    matrix[2] = key[2]
    matrix[3] = key[2] ^ key[3]
    matrix[4] = key[1]
    matrix[5] = key[1] ^ key[3]
    matrix[6] = key[1] ^ key[2]
    matrix[7] = key[1] ^ key[2] ^ key[3]
    matrix[8] = key[0]
    matrix[9] = key[0] ^ key[3]
    matrix[10] = key[0] ^ key[2]
    matrix[11] = key[0] ^ key[2] ^ key[3]
    matrix[12] = key[0] ^ key[1]
    matrix[13] = key[0] ^ key[1] ^ key[3]
    matrix[14] = key[0] ^ key[1] ^ key[2]
    matrix[15] = 0
    matrix
  end

  def reverse
    reverse = Array.new(256)
    @encode.each_with_index { |m, i|
      reverse[m] = i
    }
    reverse
  end
end

def parse_args(argv)
  OpenStruct.new({
    :keyfile => argv[0],
    :action => argv[1],
    :encode => ["-e", "--encode"].include?(argv[1]),
    :decode => ["-d", "--decode"].include?(argv[1]),
    :source => argv[2],
    :dest => argv[3],
  })
end

main parse_args ARGV
