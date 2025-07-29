using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using CommandLine;

namespace codech
{
    internal class Program
    {
        private static void Main(string[] args)
        {
            Parser.Default.ParseArguments<Options>(args).WithParsed(Run);
        }

        private static void Run(Options opts)
        {
            Codec codec = new(Matrix.FromFile(opts.KeyFile));
            ManualWork(opts, codec.matrix);
        }

        private static void Work(
            Options opts,
            Func<IEnumerable<byte>, IEnumerable<byte>> worker
        )
        {
            const int MAX_SIZE = 4096;
            using (FileStream innerReader = new(opts.Source, FileMode.Open))
            using (FileStream innerRriter = new(opts.Dest, FileMode.Create))
            using (BufferedStream reader = new(innerReader))
            using (BufferedStream writer = new(innerRriter))
            {
                var buffer = new byte[MAX_SIZE];
                while (reader.Read(buffer, 0, buffer.Length) > 0)
                {
                    var result = worker(buffer).ToArray();
                    writer.Write(result, 0, result.Length);
                }
            }
        }

        private static void BufferedWork(
            Options opts,
            Func<IEnumerable<byte>, IEnumerable<byte>> worker
        )
        {
            const int MAX_SIZE = 4096;
            using (FileStream innerReader = new(opts.Source, FileMode.Open))
            using (FileStream innerRriter = new(opts.Dest, FileMode.Create))
            using (BufferedStream reader = new(innerReader))
            using (BufferedStream writer = new(innerRriter))
            {
                var readBuffer = new byte[MAX_SIZE];
                while (reader.Read(readBuffer, 0, readBuffer.Length) > 0)
                {
                    foreach (var b in worker(readBuffer))
                    {
                        writer.WriteByte(b);
                    }
                }
            }
        }

        private static void ManualWork(Options opts, Matrix matrix)
        {
            using (FileStream innerReader = new(opts.Source, FileMode.Open))
            using (FileStream innerRriter = new(opts.Dest, FileMode.Create))
            using (BufferedStream reader = new(innerReader))
            using (BufferedStream writer = new(innerRriter))
            {
                if (opts.Encode)
                {
                    int b;
                    while ((b = reader.ReadByte()) != -1)
                    {
                        var (b1, b2) = matrix.Encode((byte)b);
                        writer.WriteByte(b1);
                        writer.WriteByte(b2);
                    }
                }
                else
                {
                    int b1, b2;
                    while (((b1 = reader.ReadByte()) != -1) && (b2 = reader.ReadByte()) != -1)
                    {
                        writer.WriteByte(matrix.Decode((byte)b1, (byte)b2));
                    }
                }
            }
        }
    }

    internal static class LinqExtension
    {
        public static IEnumerable<(int, T)> Enumerate<T>(this IEnumerable<T> enumerable)
        {
            var i = 0;
            foreach (var item in enumerable)
            {
                yield return (i, item);
                i += 1;
            }
        }
    }
}
