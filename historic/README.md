# Projet "encodage"

Cette branche correspond au programme au moment du rendu.

Pour tester:
```sh
cd build
dd if=/dev/urandom of=random.dat  bs=1M  count=1024 # génère fichier aléatoire de 1Go
make
./codec --help
```
Ou, plus simplement:
```sh
make bench
```

`make bench` prends un argument optionel `ARG_THREAD=<int>`.

[![asciicast](https://asciinema.org/a/mmmtehNspVw37J2k8pSeAm0yA.png)](https://asciinema.org/a/mmmtehNspVw37J2k8pSeAm0yA)
