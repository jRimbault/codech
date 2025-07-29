# Profiling

Manually :

```bash
dd if=/dev/urandom of=./random.data bs=1M count=288
perf record -g ./target/[debug|release]/codech key.txt -e random.data random.data.encoded
perf script | stackcollapse-perf.pl | flamegraph.pl > flame-[debug|release].svg
```

Or use (and modify) the `profile` script. (from this repo's root dir)
