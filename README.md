# Projet "encodage"


Pour tester:
```sh
dd if=/dev/urandom of=random.dat  bs=1M  count=1024 # génère fichier aléatoire de 1Go
make
./target/release/codech --help
```
Ou, plus simplement:
```sh
make bench
```

[![asciicast](https://asciinema.org/a/t7hLnIpKPYL4ng4IP8GYSHamQ.svg)](https://asciinema.org/a/t7hLnIpKPYL4ng4IP8GYSHamQ)
