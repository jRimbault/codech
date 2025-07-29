# Codech Project Context

## Project Overview
This is a school project implementing G4C (4x4 matrix) encoding/decoding across multiple programming languages. The project has been unified from separate git branches into a single branch with all implementations containerized.

## Current Branch: `unified`
Created from the original `rust` branch and contains all language implementations in separate directories.

## Available Branches (merged into unified)
- `rust` - High-performance Rust implementation with Rayon parallelization
- `c` - Modern C implementation with CMake and comprehensive testing
- `historic` - Original C implementation from project submission (worker/scheduler system)
- `csharp` - .NET C# implementation
- `golang` - Go implementation using standard library
- `java` - Java implementation (2GB file limit due to array constraints)
- `nodejs` - TypeScript/Node.js implementation
- `php` - PHP implementation
- `python` - Python implementation
- `ruby` - Ruby implementation

## Directory Structure
```
codech/
├── rust/           # Rust implementation (reference)
├── c/              # Modern C implementation
├── historic/       # Original C implementation (project submission)
├── csharp/         # C# implementation  
├── golang/         # Go implementation
├── java/           # Java implementation
├── nodejs/         # TypeScript/Node.js implementation
├── php/            # PHP implementation
├── python/         # Python implementation
├── ruby/           # Ruby implementation
├── Dockerfile      # Multi-language container with all runtimes
├── docker-compose.yml # Services for each language + benchmarking
├── key.txt         # Sample G4C key file
├── data/           # Volume mount for Docker data persistence
├── benchmarks/     # Benchmark results output
└── README.md       # Comprehensive documentation
```

## Key Files Created/Modified
- **Dockerfile**: Multi-stage build supporting all 10 language runtimes, includes wrapper script `run_codech.sh` and benchmarking script
- **docker-compose.yml**: Individual services for each language, benchmark profile, dev environment
- **README.md**: Updated with unified documentation, Docker usage, performance comparisons
- **.dockerignore**: Optimized for build performance

## Docker Usage
```bash
# Build unified container
docker build -t codech .

# Run specific language
docker run --rm codech ./run_codech.sh <language> <encode|decode> <input> <output> <keyfile>

# Available languages: rust, c, historic, csharp, go, java, nodejs, php, python, ruby

# Interactive session
docker run --rm -it codech bash

# Run all language tests
docker-compose up

# Benchmark all languages
docker run --rm codech ./benchmark.sh
docker-compose --profile benchmark up benchmark

# Development environment
docker-compose --profile dev up dev
```

## Core Algorithm (G4C Encoding)
1. **Key Format**: `G4C=[10001111 11000111 10100100 10010010]` (4 binary numbers)
2. **Encoding**: Each byte split into 2 bytes using 4x4 matrix lookup
3. **Decoding**: Combine 2 bytes back to 1 byte using inverse lookup
4. **Implementation**: Pre-computed lookup tables for O(1) operations

## Key Code References (Rust implementation as reference)
- Key parsing: `rust/src/main.rs:64`
- Core encoding: `rust/src/codec.rs:12-23`  
- Core decoding: `rust/src/codec.rs:25-33`
- Matrix operations: `rust/src/matrix/mod.rs:53-59`
- Lookup generation: `rust/src/matrix/mod.rs:97-113`

## Testing Commands
```bash
# Create test data
dd if=/dev/urandom of=random.dat bs=1M count=1024
echo "G4C=[10001111 11000111 10100100 10010010]" > key.txt

# Test encode/decode cycle (example with Rust)
cd rust/
make
./target/release/codech encode ../random.dat encoded.dat ../key.txt
./target/release/codech decode encoded.dat decoded.dat ../key.txt
```

## Performance Notes
- **Fastest**: Rust (parallel processing with Rayon), C (compiler optimizations)
- **Fast**: Go (efficient concurrency), C# (JIT benefits)  
- **Medium**: Java (2GB limit), Node.js (V8 optimization)
- **Slower**: Python, PHP (interpreted)
- **Historic**: Original C implementation with custom worker system

## Recent Changes
1. Created unified branch from rust branch
2. Merged all language branches (c, csharp, golang, java, nodejs, php, python, ruby, historic)
3. Containerized all implementations with comprehensive Dockerfile
4. Added docker-compose setup with individual services
5. Updated documentation for unified structure
6. Added benchmarking and testing scripts

## Build Status
All implementations should build successfully in the Docker container. Each language directory contains its original build system (Makefile, CMakeLists.txt, package.json, etc.).

## Next Steps Suggestions
- Run benchmarks to validate all implementations work
- Consider adding more languages (Kotlin, Swift, Zig, etc.)
- Add performance profiling for detailed analysis
- Consider adding web interface for online testing