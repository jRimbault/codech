using System.Runtime.CompilerServices;

namespace Codech;

/// <summary>
/// High-performance matrix implementation with pre-computed lookup tables
/// inspired by the Rust version for maximum speed
/// </summary>
public sealed class Matrix
{
    private const byte MASK = 0x0f;
    
    // Pre-computed lookup tables for O(1) operations
    private readonly byte[,] _encodeLookup = new byte[256, 2];
    private readonly byte[] _decodeLookup = new byte[256];
    private readonly byte[] _decodeLookupShifted = new byte[256];

    public Matrix(ReadOnlySpan<byte> key)
    {
        if (key.Length < 4)
            throw new ArgumentException("Key must have at least 4 bytes", nameof(key));

        // Build base lookup table using same algorithm as Rust
        var baseLookup = BuildBaseLookup(key);
        
        // Pre-compute all possible encode operations
        BuildEncodeLookup(baseLookup);
        
        // Pre-compute all possible decode operations
        BuildDecodeLookup(baseLookup);
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    private static byte[] BuildBaseLookup(ReadOnlySpan<byte> key)
    {
        return [
            (byte)(key[0] ^ key[1] ^ key[2] ^ key[3]),
            key[3],
            key[2],
            (byte)(key[2] ^ key[3]),
            key[1],
            (byte)(key[1] ^ key[3]),
            (byte)(key[1] ^ key[2]),
            (byte)(key[1] ^ key[2] ^ key[3]),
            key[0],
            (byte)(key[0] ^ key[3]),
            (byte)(key[0] ^ key[2]),
            (byte)(key[0] ^ key[2] ^ key[3]),
            (byte)(key[0] ^ key[1]),
            (byte)(key[0] ^ key[1] ^ key[3]),
            (byte)(key[0] ^ key[1] ^ key[2]),
            0
        ];
    }

    private void BuildEncodeLookup(byte[] baseLookup)
    {
        for (int i = 0; i < 256; i++)
        {
            _encodeLookup[i, 0] = baseLookup[i & MASK];
            _encodeLookup[i, 1] = baseLookup[i >> 4];
        }
    }

    private void BuildDecodeLookup(byte[] baseLookup)
    {
        for (int i = 0; i < baseLookup.Length; i++)
        {
            _decodeLookup[baseLookup[i]] = (byte)i;
            _decodeLookupShifted[baseLookup[i]] = (byte)(i << 4);
        }
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public (byte, byte) Encode(byte b)
    {
        return (_encodeLookup[b, 0], _encodeLookup[b, 1]);
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public byte Decode(byte b1, byte b2)
    {
        return (byte)(_decodeLookup[b1] | _decodeLookupShifted[b2]);
    }

    public static Matrix FromKey(string keyString)
    {
        // Parse G4C key format: "G4C=[10001111 11000111 10100100 10010010]"
        var keyPart = keyString.AsSpan(5, 35); // Skip "G4C=[" and take the binary part
        var parts = keyPart.ToString().Split(' ', StringSplitOptions.RemoveEmptyEntries);
        
        if (parts.Length < 4)
            throw new ArgumentException("Invalid key format", nameof(keyString));

        var keyBytes = new byte[4];
        for (int i = 0; i < 4; i++)
        {
            keyBytes[i] = Convert.ToByte(parts[i], 2);
        }

        return new Matrix(keyBytes);
    }
}