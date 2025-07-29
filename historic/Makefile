# Compiler
CC=gcc --std=c11 -g
# Flags
CFLAGS=-Wall -lpthread -lm -O3
# OBJECTS
BUILD:=build
SRCDIR:=src
MATRIX:=matrix
WORKERS:=workers
CODEC:=codec
SCHEDULER:=scheduler
MAIN:=main

ARG_THREAD=4

codec:
	@echo "Building $@..."
	@$(CC) $(CFLAGS) -o $(BUILD)/$(MATRIX).o -c $(SRCDIR)/$(MATRIX).c
	@$(CC) $(CFLAGS) -o $(BUILD)/$(WORKERS).o -c $(SRCDIR)/$(WORKERS).c
	@$(CC) $(CFLAGS) -o $(BUILD)/$(CODEC).o -c $(SRCDIR)/$(CODEC).c
	@$(CC) $(CFLAGS) -o $(BUILD)/$(SCHEDULER).o -c $(SRCDIR)/$(SCHEDULER).c
	@$(CC) $(CFLAGS) -o $(BUILD)/$(MAIN).o -c $(SRCDIR)/$(MAIN).c

	@$(CC) -o $@ \
		$(BUILD)/$(MATRIX).o \
		$(BUILD)/$(WORKERS).o \
		$(BUILD)/$(CODEC).o \
		$(BUILD)/$(SCHEDULER).o \
		$(BUILD)/$(MAIN).o \
		$(CFLAGS)
	@echo " › $@ built"

bench: codec
	@strip codec
	@./bench.sh -f 64 -s -t $(ARG_THREAD)
	@./bench.sh -f 512 -s -t $(ARG_THREAD)
	@./bench.sh -f 1024 -t $(ARG_THREAD)

# Clean
clean:
	@rm -f build/*.o
	@rm -f codec

extraclean:
	@rm -f build/original
	@rm -f build/encoded
	@rm -f build/decoded
	@rm -f build/codec
	@rm -f build/*.o
	@rm -f codec
