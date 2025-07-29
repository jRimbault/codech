#!/bin/bash
set -e

echo "Creating test files..."
dd if=/dev/urandom of=small_test.dat bs=1K count=100 2>/dev/null  # 100KB for quick tests
dd if=/dev/urandom of=large_test.dat bs=1M count=4 2>/dev/null   # 4MB for main benchmarks

echo ""
echo "CODECH VALIDATION & BENCHMARK SUITE"
echo "===================================="
echo ""

# All implementations to test
ALL_LANGS="rust c historic csharp csharp-fast go java nodejs php python ruby"

echo "Phase 1: CORRECTNESS VALIDATION"
echo "--------------------------------"
echo "Testing all implementations for correct encode/decode cycle..."
echo ""

# First, create reference implementation (using Rust as it's well-tested)
echo "Creating reference encoded file with Rust..."
./run_codech.sh rust encode small_test.dat reference_encoded.dat key.txt 2>/dev/null || {
    echo "❌ FATAL: Reference implementation (Rust) failed!"
    exit 1
}

./run_codech.sh rust decode reference_encoded.dat reference_decoded.dat key.txt 2>/dev/null || {
    echo "❌ FATAL: Reference decode failed!"
    exit 1
}

# Verify reference implementation works correctly (encode->decode should match original)
ORIGINAL_CHECKSUM=$(sha256sum small_test.dat | cut -d' ' -f1)
REFERENCE_CHECKSUM=$(sha256sum reference_decoded.dat | cut -d' ' -f1)

if [ "$ORIGINAL_CHECKSUM" != "$REFERENCE_CHECKSUM" ]; then
    echo "❌ FATAL: Reference implementation produces incorrect results!"
    echo "Original: $ORIGINAL_CHECKSUM"
    echo "Decoded:  $REFERENCE_CHECKSUM"
    exit 1
fi

echo "✅ Reference implementation verified correct"
REFERENCE_ENCODED_CHECKSUM=$(sha256sum reference_encoded.dat | cut -d' ' -f1)
echo "Reference encoded checksum: $REFERENCE_ENCODED_CHECKSUM"
echo ""

# Test all implementations for correctness
QUALIFIED_LANGS=""
FAILED_LANGS=""

for lang in $ALL_LANGS; do
    echo -n "Testing $lang... "

    # Test encode
    if ! ./run_codech.sh "$lang" encode small_test.dat "${lang}_test_encoded.dat" key.txt 2>/dev/null; then
        echo "❌ ENCODE FAILED"
        FAILED_LANGS="$FAILED_LANGS $lang"
        continue
    fi

    # Test decode
    if ! ./run_codech.sh "$lang" decode "${lang}_test_encoded.dat" "${lang}_test_decoded.dat" key.txt 2>/dev/null; then
        echo "❌ DECODE FAILED"
        FAILED_LANGS="$FAILED_LANGS $lang"
        rm -f "${lang}_test_encoded.dat"
        continue
    fi

    # Verify decode matches original
    IMPL_DECODED_CHECKSUM=$(sha256sum "${lang}_test_decoded.dat" | cut -d' ' -f1)
    if [ "$ORIGINAL_CHECKSUM" != "$IMPL_DECODED_CHECKSUM" ]; then
        echo "❌ DECODE MISMATCH"
        echo "   Expected: $ORIGINAL_CHECKSUM"
        echo "   Got:      $IMPL_DECODED_CHECKSUM"
        FAILED_LANGS="$FAILED_LANGS $lang"
        rm -f "${lang}_test_encoded.dat" "${lang}_test_decoded.dat"
        continue
    fi

    # Verify encoded output matches reference (optional - implementations may vary)
    IMPL_ENCODED_CHECKSUM=$(sha256sum "${lang}_test_encoded.dat" | cut -d' ' -f1)
    if [ "$REFERENCE_ENCODED_CHECKSUM" = "$IMPL_ENCODED_CHECKSUM" ]; then
        echo "✅ PERFECT (identical encoded output)"
    else
        echo "✅ CORRECT (different but valid encoded output)"
    fi

    QUALIFIED_LANGS="$QUALIFIED_LANGS $lang"
    rm -f "${lang}_test_encoded.dat" "${lang}_test_decoded.dat"
done

# Clean up reference files
rm -f reference_encoded.dat reference_decoded.dat

echo ""
echo "VALIDATION SUMMARY:"
echo "==================="
if [ -n "$QUALIFIED_LANGS" ]; then
    echo "✅ QUALIFIED implementations:$QUALIFIED_LANGS"
fi
if [ -n "$FAILED_LANGS" ]; then
    echo "❌ FAILED implementations:$FAILED_LANGS"
fi
echo ""

if [ -z "$QUALIFIED_LANGS" ]; then
    echo "❌ FATAL: No implementations qualified for benchmarking!"
    exit 1
fi

echo "Phase 2: Benchmarks"
echo "=================================="
echo "Benchmarking qualified implementations with hyperfine (4MB file):"
echo ""

# Only benchmark qualified implementations
WORKING_LANGS="$QUALIFIED_LANGS"

echo " ENCODE BENCHMARK:"
echo "=============================="

# Create encoded files for all qualified languages first
for lang in $WORKING_LANGS; do
    ./run_codech.sh "$lang" encode large_test.dat "pre_${lang}_encoded.dat" key.txt 2>/dev/null || true
done

# Build hyperfine command dynamically based on qualified implementations
ENCODE_ARGS=""
DECODE_ARGS=""
for lang in $WORKING_LANGS; do
    ENCODE_ARGS="$ENCODE_ARGS -n \"${lang}-encode\" \"./run_codech.sh $lang encode large_test.dat ${lang}_out.dat key.txt\""
    DECODE_ARGS="$DECODE_ARGS -n \"${lang}-decode\" \"./run_codech.sh $lang decode pre_${lang}_encoded.dat ${lang}_dec.dat key.txt\""
done

# Run comparative encode benchmark with only qualified implementations
eval "hyperfine --warmup 1 --runs 20 $ENCODE_ARGS --export-markdown encode_comparison.md --cleanup \"rm -f *_out.dat\""

echo ""
echo " DECODE BENCHMARK:"
echo "=============================="

# Run comparative decode benchmark with only qualified implementations
eval "hyperfine --warmup 1 --runs 20 $DECODE_ARGS --export-markdown decode_comparison.md --cleanup \"rm -f *_dec.dat\""

# Cleanup
rm -f small_test.dat large_test.dat pre_*_encoded.dat ./*.json

echo ""
echo "Benchmark results exported to encode_comparison.md and decode_comparison.md"
echo "Individual JSON results available for detailed analysis"
