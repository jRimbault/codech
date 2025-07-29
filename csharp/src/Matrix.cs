using System;
using System.IO;
using System.Linq;

namespace codech
{
    internal class Matrix
    {
        private const byte MASK = 0x0f;
        private readonly byte[] decode;
        private readonly byte[] encode;

        private Matrix(byte[] matrix)
        {
            this.encode = matrix;
            this.decode = new byte[256];
            for (byte i = 0; i < matrix.Length; i += 1)
            {
                this.decode[matrix[i]] = i;
            }
        }

        public (byte, byte) Encode(byte b)
        {
            return (this.encode[b & MASK], this.encode[(b >> 4) & MASK]);
        }

        public byte Decode(byte b1, byte b2)
        {
            byte p1 = this.decode[b1];
            byte p2 = (byte)(this.decode[b2] << 4);
            return (byte)(p1 | p2);
        }

        public static Matrix FromFile(string filename)
        {
            return new(BuildMatrixFromKey(ReadKey(filename)));
        }

        private static byte[] BuildMatrixFromKey(byte[] key)
        {
            return new byte[] {
                (byte) (key[0] ^ key[1] ^ key[2] ^ key[3]),
                key[3],
                key[2],
                (byte) (key[2] ^ key[3]),
                key[1],
                (byte) (key[1] ^ key[3]),
                (byte) (key[1] ^ key[2]),
                (byte) (key[1] ^ key[2] ^ key[3]),
                key[0],
                (byte) (key[0] ^ key[3]),
                (byte) (key[0] ^ key[2]),
                (byte) (key[0] ^ key[2] ^ key[3]),
                (byte) (key[0] ^ key[1]),
                (byte) (key[0] ^ key[1] ^ key[3]),
                (byte) (key[0] ^ key[1] ^ key[2]),
                0,
            };
        }

        private static byte[] ReadKey(string filename)
        {
            return File.ReadAllText(filename)
                       .Substring(5, 35)
                       .Split(' ')
                       .Select(bin => Convert.ToByte(bin, 2))
                       .ToArray();
        }
    }
}
