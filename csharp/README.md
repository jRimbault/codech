# Projet "encodage"

Pour tester:

```sh
dd if=/dev/urandom of=random.dat  bs=1M  count=1024 # génère fichier aléatoire de 1Go
make
```

Ou, plus simplement:

```sh
make bench
```

Maximum atteint sous Windows (très décevant) : 54±2Mo/s (encode & decode)

Même algorithme que les autres versions...

Sous linux (comme toutes les autres benchmarks) :

[![asciicast](https://asciinema.org/a/vav1lWD6Ju78KFT375HWXxake.svg)](https://asciinema.org/a/vav1lWD6Ju78KFT375HWXxake)
