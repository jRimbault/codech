# C Implementation Bug Report

## Issue: Small File Infinite Loop

### Summary
The C implementation hangs (infinite loop) when processing files smaller than 16 bytes due to a bug in the parallel processing chunk size calculation.

### Root Cause
The `getChunkSize()` function in `codech/main.c:201-208` has a critical flaw:

```c
size_t getChunkSize(size_t size, size_t max)
{
    if (max == 0) {
        return size;
    }
    const size_t even_mask = 0xfffffffffffffffe;
    return (size / max) & even_mask;  // BUG: Returns 0 for small files
}
```

### Problem Analysis

1. **Function Call**: `getChunkSize(size, 8)` called from `splitFileIntoParts()` (line 215)
2. **Bug Trigger**: When `file_size < 8`, division `size / 8` returns 0
3. **Even Masking**: Result 0 masked with `0xfffffffffffffffe` still equals 0
4. **Consequence**: `chunkSize = 0` passed to `splitMemoryBufferIntoChunks()`

### Cascading Failure

In `splitMemoryBufferIntoChunks()` (line 154-162):
```c
for (size_t i = 0; i < size; i += chunkSize) {  // chunkSize = 0
    // Infinite loop when chunkSize = 0
    // i never increments, loop runs forever
}
```

### Test Results

| File Size | Calculation | Result | Status |
|-----------|-------------|--------|---------|
| 1 byte    | `1/8 = 0` → `0 & even_mask = 0` | **INFINITE LOOP** |
| 3 bytes   | `3/8 = 0` → `0 & even_mask = 0` | **INFINITE LOOP** |
| 8 bytes   | `8/8 = 1` → `1 & even_mask = 0` | **INFINITE LOOP** |
| 13 bytes  | `13/8 = 1` → `1 & even_mask = 0` | **INFINITE LOOP** |
| 16 bytes  | `16/8 = 2` → `2 & even_mask = 2` | **WORKS** |
| 26 bytes  | `26/8 = 3` → `3 & even_mask = 2` | **WORKS** |

### Affected Files
Any file where `(file_size / 8) < 2`, which means **all files < 16 bytes**.

### Core Algorithm Impact
The G4C encoding/decoding algorithm itself works correctly. This is purely a parallel processing bug in the chunking logic.

### Reproduction
```bash
# These commands will hang indefinitely:
printf "Hello World!" > test.txt  # 12 bytes
./Codech key.txt --encode test.txt output.dat

printf "A" > tiny.txt  # 1 byte  
./Codech key.txt --encode tiny.txt output.dat
```

### Workaround
Files ≥ 16 bytes work correctly. The issue only affects small files in parallel processing mode.

### Related Issues
- Similar to Go implementation's divide-by-zero bug with small files
- Both implementations have flawed parallel processing logic for edge cases
- Core G4C algorithm handles all file sizes correctly when chunking works