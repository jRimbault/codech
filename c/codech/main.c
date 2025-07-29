#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <pthread.h>

#include "File.h"
#include "Parallel.h"
#include "struct/TypeLessList.h"


#define MATRIX_LEN 16
static char matrix[MATRIX_LEN];

typedef struct _memory_map
{
    char* memory;
    size_t size;
} MemoryMap;


int argIs(char* arg, char* longArg, char* shortArg)
{
    if (strncmp(arg, longArg, SIZE_MAX) == 0) {
        return 1;
    }
    if (strncmp(arg, shortArg, SIZE_MAX) == 0) {
        return 1;
    }
    return 0;
}


char* loadKey(FILE* key_file)
{
    fseek(key_file, 5, SEEK_SET);
    char* string = calloc(36, sizeof(char));
    fread(string, 35, 1, key_file);
    string[35] = 0;
    return string;
}


unsigned char* getMatrix(char* filename)
{
    FILE* key_file = fopen(filename, "r");
    if (!key_file) {
        fprintf(stderr, "Couldn't access key file.\n");
        exit(10);
    }
    char* string_matrix = loadKey(key_file);
    fclose(key_file);

    char* key_part = strtok(string_matrix, " ");
    unsigned char* matrix = calloc(4, sizeof(char));
    int i = 0;
    while (key_part != NULL && i < 4) {
        matrix[i] = (unsigned char) strtol(key_part, NULL, 2);
        key_part = strtok(NULL, " ");
        i += 1;
    }
    free(key_part);
    free(string_matrix);
    return matrix;
}


void setMatrix(char* filename)
{
    unsigned char* g4c = getMatrix(filename);
    matrix[15] = 0;
    matrix[1] = g4c[3];
    matrix[2] = g4c[2];
    matrix[3] = g4c[2] ^ g4c[3];
    matrix[4] = g4c[1];
    matrix[5] = g4c[1] ^ g4c[3];
    matrix[6] = g4c[1] ^ g4c[2];
    matrix[7] = g4c[1] ^ g4c[2] ^ g4c[3];
    matrix[8] = g4c[0];
    matrix[9] = g4c[0] ^ g4c[3];
    matrix[10] = g4c[0] ^ g4c[2];
    matrix[11] = g4c[0] ^ g4c[2] ^ g4c[3];
    matrix[12] = g4c[0] ^ g4c[1];
    matrix[13] = g4c[0] ^ g4c[1] ^ g4c[3];
    matrix[14] = g4c[0] ^ g4c[1] ^ g4c[2];
    matrix[0] = g4c[0] ^ g4c[1] ^ g4c[2] ^ g4c[3];
    free(g4c);
}


int q1(char c)
{
    return c & 0x0f;
}


int q2(char c)
{
    return (c >> 4) & 0x0f;
}


char strposMatrix(char c)
{
    return (char) (strchr(matrix, c) - matrix);
}


char addMatrixChars(char a, char b)
{
    return strposMatrix(a) + (strposMatrix(b) << 4);
}


void* encode(void* node)
{
    MemoryMap* mm = Node.value(node);
    mm->size *= 2;
    char* encoded = calloc(mm->size, sizeof(char));
    for (size_t i = 0; i < mm->size / 2; i += 1) {
        encoded[i * 2] = matrix[q1(mm->memory[i])];
        encoded[i * 2 + 1] = matrix[q2(mm->memory[i])];
    }
    free(mm->memory);
    mm->memory = encoded;
    return NULL;
}


void* decode(void* node)
{
    MemoryMap* mm = Node.value(node);
    mm->size /= 2;
    char* decoded = calloc(mm->size, sizeof(char));
    for (size_t i = 0; i < mm->size; i += 1) {
        decoded[i] = addMatrixChars(mm->memory[i * 2], mm->memory[i * 2 + 1]);
    }
    free(mm->memory);
    mm->memory = decoded;
    return NULL;
}


MemoryMap* newMemoryMap(const char* memory, size_t size, size_t start)
{
    MemoryMap* mm = malloc(sizeof(MemoryMap));
    mm->size = size;
    mm->memory = calloc(size, sizeof(char));
    memcpy(mm->memory, &memory[start], size);
    return mm;
}


struct List* splitMemoryBufferIntoChunks(char* memory, size_t size, size_t chunkSize)
{
    struct List* list = List.new();
    for (size_t i = 0; i < size; i += chunkSize) {
        MemoryMap* mm = newMemoryMap(memory, chunkSize, i);
        List.add(list, Node.new("", mm));
    }
    return list;
}


void showOn(struct List* list, FILE* file)
{
    for (size_t i = 0; i < List.length(list); ++i) {
        MemoryMap* mm = Node.value(List.iter(list, i));
        fwrite(mm->memory, sizeof(char), mm->size, file);
    }
}


void printListTo(struct List* list, char* filename)
{
    FILE* file = fopen(filename, "wb");
    showOn(list, file);
    fclose(file);
}


void freeMemoryMap(MemoryMap* mm)
{
    if (!mm) {
        return;
    }
    free(mm->memory);
    free(mm);
}


void freeMemoryMapList(struct List* list)
{
    for (size_t i = 0; i < List.length(list); i += 1) {
        freeMemoryMap(Node.value(List.iter(list, i)));
    }
    List.free(list);
}


size_t getChunkSize(size_t size, size_t max)
{
    if (max == 0) {
        return size;
    }
    const size_t even_mask = 0xfffffffffffffffe;
    return (size / max) & even_mask;
}


struct List* splitFileIntoParts(char* file)
{
    char* memory;
    size_t size = File.read(file, &memory);
    size_t chunkSize = getChunkSize(size, 8);
    struct List* parts = splitMemoryBufferIntoChunks(memory, size, chunkSize);
    free(memory);
    return parts;
}


int work(void* (* task)(void*), char* fileIn, char* fileOut)
{
    struct List* parts = splitFileIntoParts(fileIn);
    Parallel.forEach(task, parts);
    printListTo(parts, fileOut);
    freeMemoryMapList(parts);
    return 0;
}


int main(int argc, char** argv)
{
    if (argc < 5) {
        return 1;
    }
    setMatrix(argv[1]);
    if (argIs(argv[2], "--encode", "-e")) {
        work(encode, argv[3], argv[4]);
    } else if (argIs(argv[2], "--decode", "-d")) {
        work(decode, argv[3], argv[4]);
    }
    return 0;
}
