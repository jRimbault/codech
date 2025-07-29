.PHONY: build

build: codech

codech: main.go src/*.go
	go build
	strip $@

bench: build
	@./bench.sh -f 64 -s
	@./bench.sh -f 512 -s
	@./bench.sh -f 1024
