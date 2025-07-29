package main

import (
	"os"

	codech "codech/src"
)

func main() {
	keyfile := os.Args[1]
	action := os.Args[2]
	source := os.Args[3]
	dest := os.Args[4]
	codech.Run(keyfile, action, source, dest)
}
