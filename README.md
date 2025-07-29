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

All implementations are tested in a Docker environment with Ubuntu 22.04 base
image.

### Language Versions

| Language       | Version |
| -------------- | ------- |
| C (GCC)        | 11.4.0  |
| Rust           | 1.88.0  |
| Go             | 1.21.5  |
| Java (OpenJDK) | 17.0.15 |
| Node.js        | 18.20.8 |
| C# (.NET)      | 8.0.412 |
| Python         | 3.10.12 |
| PHP            | 8.1.2   |
| Ruby           | 3.0.2   |

### Working Implementations (10/10)

- **C** - Modern implementation with CMake, threading, and comprehensive tests
- **Rust** - High-performance implementation with Rayon parallelization
- **Historic C** - Original school homework submission using custom
  worker/scheduler system
- **C#** - .NET implementation with CommandLineParser
- **Go** - Standard library implementation
- **Java** - Implementation with 2GB file size limitation
- **Node.js** - TypeScript implementation
- **PHP** - Pure PHP implementation
- **Python** - Pure Python implementation
- **Ruby** - Pure Ruby implementation

## Performance Benchmarks

Benchmarks performed on 4MB files using hyperfine with checksum verification to
ensure correctness.

### Encode Performance

| Language   | Time (ms) | Relative |
| ---------- | --------- | -------- |
| Historic C | 18.0      | 1.00x    |
| C          | 19.6      | 1.09x    |
| Rust       | 20.6      | 1.14x    |
| Go         | 39.3      | 2.18x    |
| Java       | 74.6      | 4.14x    |
| Node.js    | 79.0      | 4.38x    |
| Python     | 389.3     | 21.60x   |
| Ruby       | 790.6     | 43.87x   |
| PHP        | 810.7     | 44.98x   |
| C#         | 1298.0    | 72.02x   |

#### Detailed Results

```
Benchmark 1: rust-encode
  Time (mean ± σ):      20.6 ms ±   1.3 ms    [User: 6.3 ms, System: 16.3 ms]
  Range (min … max):    18.5 ms …  23.0 ms    20 runs

Benchmark 2: c-encode
  Time (mean ± σ):      19.6 ms ±   0.9 ms    [User: 30.5 ms, System: 15.9 ms]
  Range (min … max):    17.9 ms …  21.4 ms    20 runs

Benchmark 3: historic-encode
  Time (mean ± σ):      18.0 ms ±   0.9 ms    [User: 22.4 ms, System: 12.7 ms]
  Range (min … max):    16.8 ms …  20.1 ms    20 runs

Benchmark 4: csharp-encode
  Time (mean ± σ):      1.298 s ±  0.026 s    [User: 1.501 s, System: 0.193 s]
  Range (min … max):    1.229 s …  1.330 s    20 runs

Benchmark 5: go-encode
  Time (mean ± σ):      39.3 ms ±   2.4 ms    [User: 37.2 ms, System: 44.3 ms]
  Range (min … max):    33.8 ms …  44.4 ms    20 runs

Benchmark 6: java-encode
  Time (mean ± σ):      74.6 ms ±   3.6 ms    [User: 67.4 ms, System: 33.8 ms]
  Range (min … max):    69.1 ms …  85.3 ms    20 runs

Benchmark 7: nodejs-encode
  Time (mean ± σ):      79.0 ms ±   3.8 ms    [User: 56.2 ms, System: 26.4 ms]
  Range (min … max):    74.8 ms …  88.2 ms    20 runs

Benchmark 8: php-encode
  Time (mean ± σ):     810.7 ms ±  22.5 ms    [User: 483.1 ms, System: 326.7 ms]
  Range (min … max):   772.2 ms … 870.1 ms    20 runs

Benchmark 9: python-encode
  Time (mean ± σ):     389.3 ms ±  14.6 ms    [User: 1763.0 ms, System: 157.5 ms]
  Range (min … max):   372.9 ms … 420.3 ms    20 runs

Benchmark 10: ruby-encode
  Time (mean ± σ):     790.6 ms ±  11.9 ms    [User: 734.9 ms, System: 55.2 ms]
  Range (min … max):   772.0 ms … 831.4 ms    20 runs

Summary
  historic-encode ran
    1.09 ± 0.08 times faster than c-encode
    1.14 ± 0.09 times faster than rust-encode
    2.18 ± 0.18 times faster than go-encode
    4.14 ± 0.29 times faster than java-encode
    4.38 ± 0.31 times faster than nodejs-encode
   21.60 ± 1.38 times faster than python-encode
   43.87 ± 2.35 times faster than ruby-encode
   44.98 ± 2.63 times faster than php-encode
   72.02 ± 3.97 times faster than csharp-encode
```

### Decode Performance

| Language   | Time (ms) | Relative |
| ---------- | --------- | -------- |
| Rust       | 18.0      | 1.00x    |
| Historic C | 21.1      | 1.17x    |
| Go         | 24.0      | 1.33x    |
| C          | 24.9      | 1.38x    |
| Java       | 72.0      | 3.99x    |
| Node.js    | 81.7      | 4.53x    |
| Python     | 742.7     | 41.15x   |
| Ruby       | 999.7     | 55.39x   |
| PHP        | 1161.0    | 64.34x   |
| C#         | 1297.0    | 71.85x   |

#### Detailed Results

```
Benchmark 1: rust-decode
  Time (mean ± σ):      18.0 ms ±   1.4 ms    [User: 7.4 ms, System: 12.9 ms]
  Range (min … max):    16.4 ms …  21.3 ms    20 runs

Benchmark 2: c-decode
  Time (mean ± σ):      24.9 ms ±   1.0 ms    [User: 65.6 ms, System: 15.3 ms]
  Range (min … max):    23.8 ms …  26.8 ms    20 runs

Benchmark 3: historic-decode
  Time (mean ± σ):      21.1 ms ±   1.0 ms    [User: 41.0 ms, System: 10.5 ms]
  Range (min … max):    19.9 ms …  23.8 ms    20 runs

Benchmark 4: csharp-decode
  Time (mean ± σ):      1.297 s ±  0.022 s    [User: 1.522 s, System: 0.195 s]
  Range (min … max):    1.232 s …  1.332 s    20 runs

Benchmark 5: go-decode
  Time (mean ± σ):      24.0 ms ±   2.2 ms    [User: 23.5 ms, System: 29.4 ms]
  Range (min … max):    21.1 ms …  31.3 ms    20 runs

Benchmark 6: java-decode
  Time (mean ± σ):      72.0 ms ±   3.9 ms    [User: 62.7 ms, System: 31.0 ms]
  Range (min … max):    68.3 ms …  81.7 ms    20 runs

Benchmark 7: nodejs-decode
  Time (mean ± σ):      81.7 ms ±   2.0 ms    [User: 58.3 ms, System: 24.8 ms]
  Range (min … max):    78.2 ms …  87.2 ms    20 runs

Benchmark 8: php-decode
  Time (mean ± σ):      1.161 s ±  0.014 s    [User: 0.775 s, System: 0.385 s]
  Range (min … max):    1.141 s …  1.188 s    20 runs

Benchmark 9: python-decode
  Time (mean ± σ):     742.7 ms ±  18.7 ms    [User: 673.0 ms, System: 113.1 ms]
  Range (min … max):   713.5 ms … 781.3 ms    20 runs

Benchmark 10: ruby-decode
  Time (mean ± σ):     999.7 ms ±  13.1 ms    [User: 943.8 ms, System: 55.3 ms]
  Range (min … max):   982.5 ms … 1039.3 ms    20 runs

Summary
  rust-decode ran
    1.17 ± 0.11 times faster than historic-decode
    1.33 ± 0.16 times faster than go-decode
    1.38 ± 0.12 times faster than c-decode
    3.99 ± 0.37 times faster than java-decode
    4.53 ± 0.36 times faster than nodejs-decode
   41.15 ± 3.29 times faster than python-decode
   55.39 ± 4.27 times faster than ruby-decode
   64.34 ± 4.95 times faster than php-decode
   71.85 ± 5.59 times faster than csharp-decode
```

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

## Known Issues

Some implementations have bugs in their parallel processing logic that affect
small files:

- **C implementation**: Infinite loop for files < 16 bytes due to zero chunk
  size calculation (see `c/BUG_REPORT.md`)
- **Go implementation**: Panic for files ≤ 31 bytes due to divide-by-zero in
  chunk allocation (see `golang/BUG_REPORT.md`)

These issues only affect the parallel processing wrappers. The core G4C
algorithm works correctly for all file sizes. The benchmark suite uses 4MB
files which avoid these edge cases.

## Build Requirements

Each language implementation maintains its original build system (Makefile,
CMakeLists.txt, package.json, etc.). The Docker container handles all
dependencies and build processes.
