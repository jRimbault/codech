package codech

import (
	"io/ioutil"
	"strconv"
	"strings"
)

// Matrix encode matrix
type Matrix = [16]uint8

// ReverseMatrix decode matrix
type ReverseMatrix = [255]uint8

func getMatrix(filename string) (Matrix, ReverseMatrix) {
	matrix := buildMatrix(getKey(filename))
	return matrix, buildReverseMatrix(matrix)
}

func buildMatrix(key [4]uint8) Matrix {
	return Matrix{
		key[0] ^ key[1] ^ key[2] ^ key[3],
		key[3],
		key[2],
		key[2] ^ key[3],
		key[1],
		key[1] ^ key[3],
		key[1] ^ key[2],
		key[1] ^ key[2] ^ key[3],
		key[0],
		key[0] ^ key[3],
		key[0] ^ key[2],
		key[0] ^ key[2] ^ key[3],
		key[0] ^ key[1],
		key[0] ^ key[1] ^ key[3],
		key[0] ^ key[1] ^ key[2],
		0,
	}
}

func buildReverseMatrix(matrix Matrix) ReverseMatrix {
	lookup := ReverseMatrix{}
	for i, n := range matrix {
		lookup[n] = uint8(i)
	}
	return lookup
}

func getKey(filename string) [4]uint8 {
	content, err := ioutil.ReadFile(filename)
	if err != nil {
		panic("")
	}
	text := string(content[5:40])
	nums := [4]uint8{0, 0, 0, 0}
	for i, literalNum := range strings.Split(text, " ") {
		value, err := strconv.ParseUint(literalNum, 2, 8)
		if err != nil {
			panic("")
		}
		nums[i] = uint8(value)
	}
	return nums
}
