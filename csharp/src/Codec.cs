using System.Collections.Generic;

namespace codech
{
    internal record Codec(Matrix matrix)
    {
        public IEnumerable<byte> Encode(IEnumerable<byte> stream)
        {
            foreach (byte b in stream)
            {
                var (b1, b2) = this.matrix.Encode(b);
                yield return b1;
                yield return b2;
            }
        }

        public IEnumerable<byte> Decode(IEnumerable<byte> stream)
        {
            var enumerator = stream.GetEnumerator();
            while (enumerator.MoveNext())
            {
                var b1 = enumerator.Current;
                enumerator.MoveNext();
                var b2 = enumerator.Current;
                yield return this.matrix.Decode(b1, b2);
            }
        }
    }
}
