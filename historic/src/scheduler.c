/**
 * @Author: jRimbault
 * @Date:   2017-01-08
 * @Description:
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include "structs.h"
#include "matrix.h"
#include "workers.h"

/** Shortened version of my file_to_string function */
char* get_file(char* filename, size_t* filesize)
{
    FILE* file = fopen(filename, "rb");
    if (!file) {
        fprintf(stderr, "File \"%s\" not readable. Use --help.\n", filename);
        exit(25);
    }

    fseek(file, 0, SEEK_END);
    *filesize = (size_t) ftell(file);
    rewind(file);

    /** Reads whole file into buffer */
    char* buffer = calloc(*filesize, sizeof(char));
    if (!fread(buffer, *filesize, 1, file)) { exit(1); }
    fclose(file);
    return buffer;
}

void write_file(char* filename, char* buffer, size_t filesize)
{
    FILE* output = fopen(filename, "wb");
    if (!output) {
        fprintf(stderr,
                "Output file \"%s\" not accessible.\nUse --help.\n",
                filename
        );
        exit(25);
    }
    fwrite(buffer, sizeof(char), filesize, output);
    fclose(output);
}

/**
 * Opens the input and output files, creates buffers,
 * triggers the encode and decode loops
 */
void scheduler(arguments* arguments)
{
    thread_args args;
    args.threads = arguments->threads;
    args.loops = calloc(args.threads, sizeof(pthread_t));
    /** Parses key file, create matrix */
    args.matrix = matrix(arguments->key_file);
    args.buffer_input = get_file(arguments->input_file, &args.size);

    /** ENCODE */
    if (arguments->operation == 1) {
        args.buffer_output = malloc((args.size * 2) * sizeof(char));
        for (int i = 0; i < arguments->threads; i++) {
            int err = pthread_create(
                    &args.loops[i], NULL, (void*) &worker_encoder,
                    &args
            );
            if (err != 0) {
                fprintf(stderr, "Can't create thread: [%s]\n", strerror(err));
            }
        }
    }
    /** DECODE */
    if (arguments->operation == 2) {
        args.size /= 2;
        args.buffer_output = malloc((args.size) * sizeof(char));
        for (int i = 0; i < arguments->threads; i++) {
            int err = pthread_create(
                    &args.loops[i], NULL, (void*) &worker_decoder,
                    &args
            );
            if (err != 0) {
                fprintf(stderr, "Can't create thread: [%s]\n", strerror(err));
            }
        }
    }

    for (int i = 0; i < arguments->threads; i++) {
        pthread_join(args.loops[i], NULL);
    }

    /** Dumps output buffer to output file */
    write_file(
            arguments->output_file, args.buffer_output,
            arguments->operation == 1 ? args.size * 2 : args.size
    );

    free(args.buffer_input);
    free(args.buffer_output);
    free(args.loops);
    free(args.matrix);
}
