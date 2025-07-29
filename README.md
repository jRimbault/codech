# Codech - G4C Encoding Implementation

A multi-language implementation of the G4C (4x4 matrix) encoding/decoding
algorithm. This project originated as school homework with the Historic C
implementation being the original submission. It was later expanded to explore
different programming languages and paradigms, with performance benchmarking as
a secondary objective.

## Algorithm

G4C encoding uses a 4x4 binary matrix to encode each input byte into two output
bytes, effectively doubling the file size. The algorithm:

1. Parses a key file containing 4 binary numbers representing matrix rows
2. Generates encode/decode lookup tables from the matrix
3. Splits each input byte into two bytes using matrix operations
4. Reverses the process for decoding

## Implementations

### Working Implementations (8/10)

- **C** - Modern implementation with CMake, threading, and comprehensive tests
- **Rust** - High-performance implementation with Rayon parallelization
- **Historic C** - Original school homework submission using custom
  worker/scheduler system
- **C#** - .NET implementation with CommandLineParser
- **Go** - Standard library implementation
- **Java** - Implementation with 2GB file size limitation
- **Node.js** - TypeScript implementation
- **Python** - Pure Python implementation

### Failed Implementations (2/10)

- **PHP** - Decode output mismatch
- **Ruby** - Decode produces empty output

## Performance Benchmarks

Benchmarks performed on 4MB files using hyperfine with checksum verification to
ensure correctness.

### Encode Performance

| Language   | Time (ms) | Relative |
| ---------- | --------- | -------- |
| C          | 18.3      | 1.00x    |
| Rust       | 20.0      | 1.09x    |
| Historic C | 20.5      | 1.12x    |
| Go         | 37.8      | 2.06x    |
| Java       | 69.2      | 3.78x    |
| Node.js    | 72.3      | 3.94x    |
| Python     | 357.5     | 19.51x   |
| C#         | 1242.0    | 67.79x   |

### Decode Performance

| Language   | Time (ms) | Relative |
| ---------- | --------- | -------- |
| Rust       | 16.7      | 1.00x    |
| Go         | 18.9      | 1.13x    |
| Historic C | 19.6      | 1.18x    |
| C          | 23.2      | 1.39x    |
| Java       | 70.7      | 4.24x    |
| Node.js    | 75.4      | 4.52x    |
| Python     | 638.0     | 38.24x   |
| C#         | 1108.0    | 66.41x   |

## Docker Usage

All implementations are containerized in a single multi-stage Docker image:

```bash
# Build container
docker build -t codech .

# Run specific implementation
docker run --rm codech ./run_codech.sh <language> <encode|decode> <input> <output> <keyfile>

# Run benchmarks with validation
docker run --rm codech ./benchmark.sh
```

Available languages: `rust`, `c`, `historic`, `csharp`, `go`, `java`, `nodejs`,
`php`, `python`, `ruby`

## Key File Format

```text
G4C=[10001111 11000111 10100100 10010010]
```

Four 8-bit binary numbers representing the 4x4 encoding matrix rows.

## Testing

The benchmark suite includes automated correctness validation using SHA256
checksums. Only implementations that pass encode/decode verification are
included in performance benchmarks.

## Build Requirements

Each language implementation maintains its original build system (Makefile,
CMakeLists.txt, package.json, etc.). The Docker container handles all
dependencies and build processes.
