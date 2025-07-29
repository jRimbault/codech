# Go Implementation Bug Report

## Issue: Small File Divide-by-Zero Panic

### Summary
The Go implementation crashes with a "divide by zero" panic when processing files that result in zero chunk size after the even-alignment calculation.

### Root Cause
The `getChunkSize()` function in `src/codech.go:68-74` has a critical flaw in its even-alignment logic:

```go
func getChunkSize(length int) int {
	res := length / runtime.NumCPU()
	if res%2 == 1 {
		return res - 1                // BUG: Can return 0
	}
	return res
}
```

### Problem Analysis

1. **CPU Count**: Container has 16 CPUs (`runtime.NumCPU() = 16`)
2. **Division**: For files ≤ 31 bytes, `length / 16` gives results 0-1
3. **Even Alignment**: When result is 1 (odd), it's decremented to 0
4. **Consequence**: `chunkSize = 0` passed to `split()` function

### Cascading Failure

In `split()` function (line 76-87):
```go
func split(buf []byte, lim int) [][]byte {
	var chunk []byte
	chunks := make([][]byte, 0, len(buf)/lim+1)  // len(buf)/0 → PANIC
	// ...
}
```

The divide-by-zero occurs when calculating slice capacity: `len(buf)/lim` where `lim = 0`.

### Test Results

| File Size | Calculation | Even Check | Result | Status |
|-----------|-------------|------------|--------|---------|
| 1 byte    | `1/16 = 0`  | `0%2 != 1` | 0 | **PANIC** |
| 15 bytes  | `15/16 = 0` | `0%2 != 1` | 0 | **PANIC** |
| 16 bytes  | `16/16 = 1` | `1%2 == 1` | 0 | **PANIC** |
| 17 bytes  | `17/16 = 1` | `1%2 == 1` | 0 | **PANIC** |
| 31 bytes  | `31/16 = 1` | `1%2 == 1` | 0 | **PANIC** |
| 32 bytes  | `32/16 = 2` | `2%2 != 1` | 2 | **WORKS** |
| 33 bytes  | `33/16 = 2` | `2%2 != 1` | 2 | **WORKS** |

### Affected Files
Any file where `(file_size / CPU_count) ≤ 1`, which with 16 CPUs means **all files ≤ 31 bytes**.

### Error Message
```
panic: runtime error: integer divide by zero

goroutine 1 [running]:
codech/src.split(...)
	/app/golang/src/codech.go:78
```

### Core Algorithm Impact
The G4C encoding/decoding algorithm itself works correctly. This is purely a parallel processing bug in the chunking logic.

### Reproduction
```bash
# These commands will panic:
printf "Hello World!" > test.txt  # 12 bytes
./codech key.txt --encode test.txt output.dat

printf "A" > tiny.txt  # 1 byte  
./codech key.txt --encode tiny.txt output.dat

# This will work:
printf "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456" > large.txt  # 32 bytes
./codech key.txt --encode large.txt output.dat
```

### CPU Dependency
The bug threshold depends on CPU count:
- **1 CPU**: Files ≤ 1 byte fail
- **4 CPUs**: Files ≤ 7 bytes fail  
- **8 CPUs**: Files ≤ 15 bytes fail
- **16 CPUs**: Files ≤ 31 bytes fail

### Related Issues
- Similar to C implementation's infinite loop bug with small files
- Both implementations have flawed parallel processing logic for edge cases
- Core G4C algorithm handles all file sizes correctly when chunking works

### Design Flaw
The even-alignment requirement (forcing chunk sizes to be even) combined with small file handling creates this edge case where chunk size becomes zero.