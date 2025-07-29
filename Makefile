.PHONY: build bench clean lint shellcheck docker-build docker-test docker-benchmark help

# Default target
help:
	@echo "Available targets:"
	@echo "  build         - Build Rust implementation"
	@echo "  bench         - Run Rust benchmarks" 
	@echo "  clean         - Clean Rust build artifacts"
	@echo "  lint          - Run shellcheck on all shell scripts"
	@echo "  shellcheck    - Alias for lint"
	@echo "  docker-build  - Build Docker container with all implementations"
	@echo "  docker-test   - Run basic Docker functionality tests"
	@echo "  docker-benchmark - Run hyperfine benchmarking suite in Docker"
	@echo "  dev           - Full development workflow (lint -> docker-build -> docker-test)"
	@echo "  help          - Show this help message"

# Rust-specific targets
build:
	@cargo build --release
	@strip target/release/codech

bench: build
	@./bench.py -s 48 -hr
	@./bench.py -s 384 -hr
	@./bench.py -s 768

clean:
	cargo clean

# Shell script linting
lint: shellcheck

shellcheck:
	@echo "Running shellcheck validation..."
	@./scripts/lint.sh

# Docker targets
docker-build: lint
	@echo "Building Docker container with shellcheck-validated scripts..."
	docker build -t codech .

docker-test: docker-build
	@echo "Running basic Docker functionality tests..."
	docker run --rm codech ./run_codech.sh rust encode /app/test.txt /app/test_out.dat /app/key.txt
	docker run --rm codech ./run_codech.sh rust decode /app/test_out.dat /app/test_decoded.txt /app/key.txt
	@echo "✅ Docker test completed successfully"

docker-benchmark: docker-build
	@echo "Running hyperfine benchmark suite..."
	docker run --rm codech ./benchmark.sh

# Development workflow
dev: lint docker-build docker-test
	@echo "🎉 Development workflow completed successfully!"
