
#ifndef _WORKERS_H
#define _WORKERS_H

/*

MAJ: Ci-desous, c'était marrant un temps, maintenant les buffers sont traités
     séquentiellement.

Le buffer encodé fait deux fois la taille du buffer clair.
Chaque indice du buffer clair correspond à deux indices du buffer encodé.
Que ce soit à l'encodage ou au décodage il faut parcourir les buffer
de manière à pour chaque i clair avoir (i*2) et (i*2+1) du buffer encodé.


Graph des index de buffer pour 4 threads (de 0 à 3), pour 4 étapes:

|          |               CLEAR                 |
|----------|-------|---------|---------|---------|
| Thread 0 |   0   |    4    |    8    |   12    |
| Thread 1 |   1   |    5    |    9    |   13    |
| Thread 2 |   2   |    6    |   10    |   14    |
| Thread 3 |   3   |    7    |   11    |   15    |

|          |              ENCODED                |
|----------|-------|---------|---------|---------|
| Thread 0 | (0,1) |  (8,9)  | (16,17) | (24,25) |
| Thread 1 | (2,3) | (10,11) | (18,19) | (26,27) |
| Thread 2 | (4,5) | (12,13) | (20,21) | (28,29) |
| Thread 3 | (6,7) | (14,15) | (22,23) | (30,31) |

On peut raisonner de la même façon pour n threads.

 */

#include "structs.h"

void* worker_encoder(void* args);

void* worker_decoder(void* args);

#endif // _WORKERS_H
