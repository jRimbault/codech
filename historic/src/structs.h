
#ifndef _STRUCTS_H
#define _STRUCTS_H

#include <pthread.h>

typedef struct thread_args
{
    pthread_t* loops;
    char* matrix;
    char* buffer_input;
    char* buffer_output;
    size_t size;
    int threads;
} thread_args;

typedef struct arguments
{
    char* input_file;
    char* output_file;
    char* key_file;
    int operation;
    int threads;
} arguments;

#endif // _STRUCTS_H
