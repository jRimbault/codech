build:
	dotnet publish -c release -r linux-x64 /p:PublishSingleFile=true /p:PublishTrimmed=true

bench: build
	@./bench.py -s 64 -hr
	@./bench.py -s 512 -hr
	@./bench.py -s 1024
