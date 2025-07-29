using System.Diagnostics;

namespace Codech;

class Program
{
    static int Main(string[] args)
    {
        try
        {
            if (args.Length != 4)
            {
                Console.WriteLine("Usage: codech <keyfile> <input> <output> <--encode|--decode>");
                return 1;
            }

            var keyFile = args[0];
            var inputFile = args[1];
            var outputFile = args[2];
            var action = args[3];

            // Read and parse key
            var keyContent = File.ReadAllText(keyFile);
            var matrix = Matrix.FromKey(keyContent);
            var codec = new Codec(matrix);

            var stopwatch = Stopwatch.StartNew();

            if (action == "--encode")
            {
                EncodeFile(codec, inputFile, outputFile);
            }
            else if (action == "--decode")
            {
                DecodeFile(codec, inputFile, outputFile);
            }
            else
            {
                Console.WriteLine($"Invalid action: {action}. Use --encode or --decode");
                return 1;
            }

            stopwatch.Stop();
            
            // Uncomment for timing information
            // Console.WriteLine($"Operation completed in {stopwatch.ElapsedMilliseconds}ms");

            return 0;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error: {ex.Message}");
            return 1;
        }
    }

    static void EncodeFile(Codec codec, string inputFile, string outputFile)
    {
        // For smaller files, read entirely into memory for maximum speed
        var fileInfo = new FileInfo(inputFile);
        
        if (fileInfo.Length < 100 * 1024 * 1024) // < 100MB, use in-memory processing
        {
            var inputData = File.ReadAllBytes(inputFile);
            var outputData = codec.Encode(inputData);
            File.WriteAllBytes(outputFile, outputData);
        }
        else
        {
            // For larger files, use streaming to avoid memory issues
            using var input = File.OpenRead(inputFile);
            using var output = File.Create(outputFile);
            codec.EncodeStream(input, output);
        }
    }

    static void DecodeFile(Codec codec, string inputFile, string outputFile)
    {
        // For smaller files, read entirely into memory for maximum speed
        var fileInfo = new FileInfo(inputFile);
        
        if (fileInfo.Length < 200 * 1024 * 1024) // < 200MB, use in-memory processing
        {
            var inputData = File.ReadAllBytes(inputFile);
            var outputData = codec.Decode(inputData);
            File.WriteAllBytes(outputFile, outputData);
        }
        else
        {
            // For larger files, use streaming to avoid memory issues
            using var input = File.OpenRead(inputFile);
            using var output = File.Create(outputFile);
            codec.DecodeStream(input, output);
        }
    }
}
