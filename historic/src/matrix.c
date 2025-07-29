/**
 * @author: jRimbault
 * @date:   2017-11-21
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/** I don't want to get a double, so here's my own pow function */
int pow_int(int n, int p)
{
    if (p > 1) {
        return n * pow_int(n, p - 1);
    }
    return n;
}

/**
 * Parses key file, create matrix
 *
 * @param  filename file containing the matrix
 *
 * @return          matrix G4C
 */
unsigned char* get_matrix(char* filename)
{
    FILE* key_file = fopen(filename, "r");
    if (!key_file) {
        printf("Couldn't access key file. Use --help.\n");
        exit(10);
    }

    fseek(key_file, 5, SEEK_SET);
    char string_matrix[36];
    if (!fread(string_matrix, 35, 1, key_file)) { exit(11); }
    string_matrix[35] = 0;
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
    return matrix;
}

/**
 * Returns directly usable matrix
 */
char* matrix(char* filename)
{
    unsigned char* g4c = get_matrix(filename);
    char* matrix = calloc(16, sizeof(char));
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
    return matrix;
}
