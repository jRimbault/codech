#include <stdio.h>
#include <zconf.h>

#include "minunit.h"
#include "Parallel.h"


struct List* exampleList()
{
    struct List* list = List.new();
    for (int i = 0; i < 5; i += 1) {
        List.add(list, Node.new("that's a key", i + 1));
    }
    return list;
}


void* hello(void* word)
{
    printf("Hello, %s!\n", (char*) word);
    return NULL;
}

unsigned int adder_sleepPause = 20;

void* adder(void* i)
{
    /** this is actually a dangerous sharing of one int */
    int* value = (int*) i;
    *value += 1;
    usleep(adder_sleepPause);
    adder_sleepPause += 20;
    printf("{i: %d}\n", *value);
    return NULL;
}


unsigned int node_sleepPause = 20;


void* showNode(void* n)
{
    usleep(node_sleepPause);
    node_sleepPause += 20;
    printf("{%s: %d}\n", Node.key(n), Node.value(n));
    return NULL;
}


static char* tests()
{
    int i = 0;
    Parallel.forLoop(2, hello, "world");
    Parallel.forLoop(5, adder, &i);
    i = 0;
    Parallel.autoLoop(hello, "world");
    Parallel.autoLoop(adder, &i);
    struct List* list = exampleList();
    Parallel.forEach(showNode, list);
    List.free(list);
    return 0;
}


mu_run(tests)
