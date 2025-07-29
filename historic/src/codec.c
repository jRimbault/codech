/**
 * @Author: jRimbault
 * @Date:   2017-01-09
 * @Description:
 */

#include <string.h>

/*
 * Right 4bits
 * c is char
 * char are one byte
 * `&` is the and operator, the resulting byte of the operation:
 *     `c & 00001111`
 * is the right side of the c byte
 */
char quartet_1(char c)
{
    return (char) (c & 0x0f);
}

/*
 * Left 4bits
 * `>> 4` makes the c byte move 4 bits to the right
 * same operation as above
 */
char quartet_2(char c)
{
    return (char) ((c >> 4) & 0x0f);
}

/*
 * Receives a half byte (4bits) and returns the corresponding encoded byte
 * @param c is half a byte, so always between 0 and 16
 * @Note: ^ is the xor operator
 */
char encode_switch(char c, char* matrix)
{
    return matrix[(int)c];
}

int strpos(char* string, char c)
{
    const char* e = strchr(string, c);
    if (e) {
        return (int) (e - string);
    }
    return -1;
}

/*
 * Receives an encoded byte and returns the original byte
 * The only way to speed things up here would be statistical analysis of
 * the frequency of the different cases, I'm betting it would not bring any
 * major improvement and the distribution would be about even for all cases
 * @Note: ^ is the xor operator
 */
/** This is becoming too clever for its own good */
char decode_switch(char c, char* matrix)
{
    return (char) (strchr(matrix, c) - matrix);
}
