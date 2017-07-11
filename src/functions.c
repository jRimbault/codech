/**
 * @Author: jRimbault nAmari
 * @Date:   2017-01-08 22:00:10
 * @Last Modified by:   erelde
 * @Description:
 */

#ifndef HEADER
#define HEADER
#include "header.h"
#endif

#ifndef FUNCTIONS
#define FUNCTIONS
#include "functions.h"
#endif

#ifndef SWITCHES
#define SWITCHES
#include "switches.h"
#endif

/**
 * Function to check arguments
 * @param  given_arg string received
 * @param  long_arg  1st string it's compared to
 * @param  short_arg 2nd string it's compared to
 * @return           returns 1 if received string is either the 1st or 2nd,
 *                   else it returns 0
 */
int arg_is(char* given_arg,char* long_arg, char* short_arg) {
	if ((!strcmp(given_arg, long_arg)) || (!strcmp(given_arg, short_arg))) {
		return 1;
	}
	return 0;
}

/**
 * Help triggered if asked or if wrong arguments were given.
 */
void help() {
	printf("Usage: codec [--mode inputfile outputfile] [--progress] [--thread 1-4] [--key keyfile] [--help]\n\n"
			"Encode or decode any file with a G4C key.\n\n"
			"Options:\n"
			"    Modes:\n"
			"      Followed by the input file path and the output file path\n"
			"        --encode  -e    encoding mode\n"
			"             or\n"
			"        --decode  -d    decoding mode\n"
			"    --key       -k      followed by keyfile\n"
			"    --help      -h      show this help\n"
			"    --progress  -p      progress indicator !caution in multithreaded mode\n"
			"    --thread    -t      followed by a number 1-4\n\n"
			"Exemples:\n"
			"    To encode a file:\n"
			"        codec -e file.jpg file.jpg.c -k key.txt\n\n"
			"    To decode the resulting file:\n"
			"        codec -d file.jpg.c file.jpg -k key.txt\n\n"
			"Made with ♥ by Jacques Rimbault and Neil Amari.\n"
			"Note: the visible progress increases compute time by *up* to 50%%.\n"
			);
}

/**
 * A simple progress indicator
 * it adds around *up* to 50% execution time
 * @param i   current step
 * @param end maximum
 * @Note: Not 'correctly' implemented in multithreaded workload
 */
void progress_indicator(long i, long end) {
	end = end / 100;
	if ((i % end) == 0) {
		printf(" %ld%%\r", i/end);
		fflush(stdout);
	}
}

/**
 * This the threaded function
 * It splits tasks between threads
 * @param structure containing several arguments:
 *   > g_loops        array containing thread's id
 *   > end            end of the input buffer
 *   > buffer_input   reading buffer
 *   > buffer_output  writing buffer
 *   > matrix         array key matrix
 */
void* threaded_worker(void* structure) {
	thread_args* args = structure;
	long i;
	int  j;

	for (j = 0; j < NUM_THREADS; j++) {
		/*
		 * This pthread_equal could could be the only `if`,
		 * in place of the modulo check, but a pthread_equal
		 * costs more time than an modulo check, so performing it only NUM_THREADS times
		 * instead of (args->end) times is better
		 */
		if (pthread_equal(pthread_self(), args->g_loops[j])) {
			for (i = 0; i < args->end; i++) {
				if (i % NUM_THREADS == j) {
					switch(args->operation) {
						case 1:
							args->buffer_output[i*2]   = encode_switch(quartet_1(args->buffer_input[i]), args->matrix);
							args->buffer_output[i*2+1] = encode_switch(quartet_2(args->buffer_input[i]), args->matrix);
							break;
						case 2:
							args->buffer_output[i]  =  decode_switch((args->buffer_input[i*2]), args->matrix);
							args->buffer_output[i] += (decode_switch(args->buffer_input[i*2+1], args->matrix) << 4);
							break;
					}
					if (args->progress) {
						progress_indicator(i, args->end);
					}
				}
			}
		}
	}
	pthread_exit(NULL);
}

/**
 * Opens the input and output files, creates buffers,
 * triggers the encode and decode loops
 * @param structure containing several arguments:
 *   > input_file      name
 *   > output_file     name
 *   > keyfile         name
 *   > operation       1 or 2 (encode or decode)
 *   > progress        display progress indicator or not (1 or 0)
 *   > thread_num_arg  number of threads
 */
void file_opener_and_writer(void* structure) {
	arguments* arguments = structure;
	thread_args args_t;
	FILE* input;
	FILE* output;
	FILE* keyfile;
	char  keychar[35];
	long  filelen;
	int   err, i, j;

	/*
	 * Parses key file, create matrix
	 */
	keyfile = fopen(arguments->keyfile, "r");
	if (keyfile) {
		fseek(keyfile, 5, SEEK_SET);
		for (i = 0; i < 35; i++) {
			keychar[i] = getc(keyfile);
		}
		args_t.matrix = (char *)malloc(4*sizeof(char));
		for (j = 0; j < 4; j++) {
			args_t.matrix[j] = 0;
			for (i = 0; i < 8; i++) {
				if (keychar[i+(j*9)] == 49) {
					args_t.matrix[j] = args_t.matrix[j] + pow(2, 7-i);
				}
			}
		}
		fclose(keyfile);
	} else {
		printf("Couldn't access key file. Use --help.\n");
		return;
	}

	/*
	 * Either successfully opens the input and output files,
	 * or fails and print the help() and an error hint.
	 */
	input = fopen(arguments->input_file, "rb");
	if (!input) {
		printf("Input file \"%s\" not accessible.\nUse --help.\n", arguments->input_file);
	} else {
		remove(arguments->output_file);
		output = fopen(arguments->output_file, "wb");
		if (!output) {
			printf("Output file \"%s\" not accessible.\nUse --help.\n", arguments->output_file);
		} else {
			/*
			 * Builds the buffers
			 * of the input and output files
			 * Builds the threads arguments
			 * Extremely reliant on the amount of free RAM
			 */
			fseek(input, 0, SEEK_END);
			filelen = ftell(input);
			rewind(input);
			args_t.buffer_input = (char *)malloc((filelen + 1)*sizeof(char));

			if (arguments->operation == 1) {
				args_t.buffer_output = (char *)malloc((filelen + 1)*sizeof(char)*2);
			}
			if (arguments->operation == 2) {
				args_t.buffer_output = (char *)malloc((filelen + 1)*sizeof(char)/2);
			}

			args_t.progress       = arguments->progress;
			args_t.thread_num_arg = arguments->thread_num_arg;
			args_t.operation      = arguments->operation;
			if(!fread(args_t.buffer_input, filelen, 1, input)) exit(1);

			/*
			 * Either encode or decode
			 * 1 -> encode
			 * 2 -> decode
			 */
			switch(arguments->operation) {
				case 1:
					for(i = 0; i < NUM_THREADS; i++) {
						args_t.end = filelen;
						err = pthread_create(&(args_t.g_loops[i]), NULL, &threaded_worker, (void *)&args_t);
						if (err != 0) {
							printf("Can't create thread :[%s]\n", strerror(err));
						}
					}

					for(i = 0; i < NUM_THREADS; i++) {
						pthread_join(args_t.g_loops[i], NULL);
					}

					fwrite(args_t.buffer_output, sizeof(char), filelen * 2, output);
					break;
				case 2:
					for(i = 0; i < NUM_THREADS; i++) {
						args_t.end = filelen / 2;
						err = pthread_create(&(args_t.g_loops[i]), NULL, &threaded_worker, (void *)&args_t);
						if (err != 0) {
							printf("Can't create thread :[%s]\n", strerror(err));
						}
					}

					for(i = 0; i < NUM_THREADS; i++) {
						pthread_join(args_t.g_loops[i], NULL);
					}

					fwrite(args_t.buffer_output, sizeof(char), filelen / 2, output);
					break;
			}

			/*
			 * Clear buffers
			 */
			free(args_t.buffer_input);
			free(args_t.buffer_output);
			free(args_t.matrix);
			/*
			 * Close output file
			 */
			fclose(output);
		}
		/*
		 * Close input file
		 */
		fclose(input);
	}
	if (arguments->progress) {
		printf("Done!\n");
	}
}
