.PHONY: build

build: export RUSTFLAGS=--emit=asm -C lto=fat -C target-cpu=native
build:
	@cargo build --release
	@strip target/release/codech

bench: build
	@./bench.py -s 48 -hr
	@./bench.py -s 384 -hr
	@./bench.py -s 768

clean:
	cargo clean
