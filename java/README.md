# Projet "encodage"


```sh
make bench
```

Les arrays simple de java sont limités à 2^31 éléments (soit 2Go).
Il faudrait utiliser des ArrayList, mais l'interaction entre les box Byte|byte
array, et List est trop barbante.
Si java avait des type unsigned normaux, ce serait plus facile bien sur.
Un débat de presque 30 ans maintenant.

[![asciicast](https://asciinema.org/a/Wyy8mSKOXQqF9qzneSDiuRAhF.svg)](https://asciinema.org/a/Wyy8mSKOXQqF9qzneSDiuRAhF)
