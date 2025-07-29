using System;
using CommandLine;

namespace codech
{
    public class Options
    {
        public Options()
        {
            KeyFile = string.Empty;
            Source = string.Empty;
            Dest = string.Empty;
            Encode = false;
            Decode = false;
            Timings = false;
        }

        [Value(0, Required = true, HelpText = "File containing a G4C key")]
        public string KeyFile { get; init; }

        [Value(1, Required = true, HelpText = "File to encode or decode")]
        public string Source { get; init; }

        [Value(2, Required = true, HelpText = "Output file")]
        public string Dest { get; init; }

        [Option('e', "encode",
            SetName = "action-encode",
            HelpText = "Action to execute on the source file"
        )]
        public bool Encode { get; init; }

        [Option('d', "decode",
            SetName = "action-decode",
            HelpText = "Action to execute on the source file"
        )]
        public bool Decode { get; init; }

        [Option('t', "timings",
            HelpText = "Output codec execution duration (seconds)"
        )]
        public bool Timings { get; init; }

        public override string ToString()
        {
            string props = string.Join(
                $",{Environment.NewLine}   ",
                $"{nameof(KeyFile)}({KeyFile})",
                $"{nameof(Source)}({Source})",
                $"{nameof(Dest)}({Dest})",
                $"{nameof(Encode)}({Encode})",
                $"{nameof(Decode)}({Decode})",
                $"{nameof(Timings)}({Timings})"
            );
            return $"{nameof(Options)} {{{Environment.NewLine}   {props}{Environment.NewLine}}}";
        }
    }
}
