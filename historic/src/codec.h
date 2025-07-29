/**
 * @Author: jRimbault
 * @Date:   2017-01-09
 * @Description:
 */

#ifndef _SWITCHES_H
#define _SWITCHES_H

/*
 * Left bit shift
 */
char quartet_1(char);

/*
 * Right bit shift
 */
char quartet_2(char);

/*
 * Receives a half byte (4bits) and returns the corresponding encoded byte
 */
char encode_switch(char, char*);

/*
 * Receives an encoded byte and returns the original byte
 */
char decode_switch(char, char*);

#endif // _SWITCHES_H
