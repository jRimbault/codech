build:
	~/.dotnet/dotnet publish Codech -c release -r linux-x64 /p:PublishSingleFile=true /p:PublishTrimmed=true

bench: build
	@echo "Running C# benchmarks..."
	@cd Codech && ~/.dotnet/dotnet run key.txt test.txt encoded.dat --encode
	@cd Codech && ~/.dotnet/dotnet run key.txt encoded.dat decoded.txt --decode
	@cd Codech && diff test.txt decoded.txt && echo "✅ C# fast implementation works correctly"

clean:
	rm -rf Codech/bin Codech/obj

.PHONY: build bench clean