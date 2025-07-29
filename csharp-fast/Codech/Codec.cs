using System.Runtime.CompilerServices;

namespace Codech;

/// <summary>
/// High-performance codec with parallel processing and optimized memory operations
/// </summary>
public sealed class Codec
{
    private readonly Matrix _matrix;

    public Codec(Matrix matrix)
    {
        _matrix = matrix;
    }

    /// <summary>
    /// Parallel encode operation inspired by Rust implementation
    /// </summary>
    public byte[] Encode(ReadOnlySpan<byte> input)
    {
        if (input.Length == 0)
            return [];

        var result = new byte[input.Length * 2];
        
        // For small inputs, use single-threaded approach
        if (input.Length < 1024)
        {
            EncodeSequential(input, result);
            return result;
        }

        // For larger inputs, use parallel processing with arrays
        var inputArray = input.ToArray();
        EncodeParallel(inputArray, result);
        return result;
    }

    /// <summary>
    /// Parallel decode operation
    /// </summary>
    public byte[] Decode(ReadOnlySpan<byte> input)
    {
        if (input.Length == 0)
            return [];

        if (input.Length % 2 != 0)
            throw new ArgumentException("Input length must be even for decoding", nameof(input));

        var result = new byte[input.Length / 2];
        
        // For small inputs, use single-threaded approach
        if (input.Length < 2048)
        {
            DecodeSequential(input, result);
            return result;
        }

        // For larger inputs, use parallel processing with arrays
        var inputArray = input.ToArray();
        DecodeParallel(inputArray, result);
        return result;
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    private void EncodeSequential(ReadOnlySpan<byte> input, Span<byte> output)
    {
        for (int i = 0; i < input.Length; i++)
        {
            var (b1, b2) = _matrix.Encode(input[i]);
            output[i * 2] = b1;
            output[i * 2 + 1] = b2;
        }
    }

    private void EncodeParallel(byte[] input, byte[] output)
    {
        // Determine optimal chunk size (similar to Rust's cache-aware chunking)
        var chunkSize = Math.Max(1024, input.Length / Environment.ProcessorCount);
        
        Parallel.For(0, (input.Length + chunkSize - 1) / chunkSize, chunkIndex =>
        {
            var start = chunkIndex * chunkSize;
            var end = Math.Min(start + chunkSize, input.Length);
            var chunkInput = input.AsSpan(start, end - start);
            var chunkOutput = output.AsSpan(start * 2, (end - start) * 2);
            
            EncodeSequential(chunkInput, chunkOutput);
        });
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    private void DecodeSequential(ReadOnlySpan<byte> input, Span<byte> output)
    {
        for (int i = 0; i < output.Length; i++)
        {
            output[i] = _matrix.Decode(input[i * 2], input[i * 2 + 1]);
        }
    }

    private void DecodeParallel(byte[] input, byte[] output)
    {
        // Determine optimal chunk size for decode (processing pairs)
        var outputChunkSize = Math.Max(512, output.Length / Environment.ProcessorCount);
        
        Parallel.For(0, (output.Length + outputChunkSize - 1) / outputChunkSize, chunkIndex =>
        {
            var start = chunkIndex * outputChunkSize;
            var end = Math.Min(start + outputChunkSize, output.Length);
            var chunkInput = input.AsSpan(start * 2, (end - start) * 2);
            var chunkOutput = output.AsSpan(start, end - start);
            
            DecodeSequential(chunkInput, chunkOutput);
        });
    }

    /// <summary>
    /// Memory-efficient streaming encode for very large files
    /// </summary>
    public void EncodeStream(Stream input, Stream output)
    {
        const int bufferSize = 64 * 1024; // 64KB buffer
        var inputBuffer = new byte[bufferSize];
        var outputBuffer = new byte[bufferSize * 2];
        
        int bytesRead;
        while ((bytesRead = input.Read(inputBuffer, 0, bufferSize)) > 0)
        {
            var inputSpan = inputBuffer.AsSpan(0, bytesRead);
            var outputSpan = outputBuffer.AsSpan(0, bytesRead * 2);
            
            EncodeSequential(inputSpan, outputSpan);
            output.Write(outputBuffer, 0, bytesRead * 2);
        }
    }

    /// <summary>
    /// Memory-efficient streaming decode for very large files
    /// </summary>
    public void DecodeStream(Stream input, Stream output)
    {
        const int bufferSize = 64 * 1024; // 64KB buffer (must be even)
        var inputBuffer = new byte[bufferSize];
        var outputBuffer = new byte[bufferSize / 2];
        
        int bytesRead;
        while ((bytesRead = input.Read(inputBuffer, 0, bufferSize)) > 0)
        {
            if (bytesRead % 2 != 0)
                throw new InvalidDataException("Invalid encoded data - odd number of bytes");
                
            var inputSpan = inputBuffer.AsSpan(0, bytesRead);
            var outputSpan = outputBuffer.AsSpan(0, bytesRead / 2);
            
            DecodeSequential(inputSpan, outputSpan);
            output.Write(outputBuffer, 0, bytesRead / 2);
        }
    }
}