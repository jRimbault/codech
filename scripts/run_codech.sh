#!/bin/bash
set -e

LANG=${1:-rust}
ACTION=${2:-encode}
INPUT=${3:-test.txt}
OUTPUT=${4:-output}
KEY=${5:-key.txt}

case $LANG in
    rust)
        cd /app/rust
        ./target/release/codech "../$KEY" "$ACTION" "../$INPUT" "../$OUTPUT"
        ;;
    c)
        cd /app/c/build
        ./Codech "../../$KEY" "--$ACTION" "../../$INPUT" "../../$OUTPUT"
        ;;
    historic)
        cd /app/historic/build
        ./codec "--$ACTION" "../../$INPUT" "../../$OUTPUT" --key "../../$KEY"
        ;;
    csharp)
        cd /app/csharp
        ./bin/Release/net8.0/linux-x64/publish/codech "../$KEY" "../$INPUT" "../$OUTPUT" "--$ACTION"
        ;;
    csharp-fast)
        cd /app/csharp-fast
        ./bin/Release/net8.0/linux-x64/publish/Codech "../$KEY" "../$INPUT" "../$OUTPUT" "--$ACTION"
        ;;
    go|golang)
        cd /app/golang
        ./codech "../$KEY" "--$ACTION" "../$INPUT" "../$OUTPUT"
        ;;
    java)
        cd /app/java
        java -cp build io.jrimbault.codech.Main "../$KEY" "--$ACTION" "../$INPUT" "../$OUTPUT"
        ;;
    node|nodejs|typescript)
        cd /app/nodejs
        node codech.js "../$KEY" "../$INPUT" "../$OUTPUT" "--$ACTION" 2>/dev/null || node dist/codech.js "../$KEY" "../$INPUT" "../$OUTPUT" "--$ACTION"
        ;;
    php)
        cd /app/php
        php codech.php "../$KEY" "--$ACTION" "../$INPUT" "../$OUTPUT"
        ;;
    python)
        cd /app/python
        python3 codech.py "../$KEY" "../$INPUT" "../$OUTPUT" "--$ACTION"
        ;;
    ruby)
        cd /app/ruby
        ruby codech.rb "../$KEY" "--$ACTION" "../$INPUT" "../$OUTPUT"
        ;;
    *)
        echo "Usage: run_codech.sh <language> <encode|decode> <input> <output> <keyfile>"
        echo "Languages: rust, c, historic, csharp, csharp-fast, go, java, nodejs, php, python, ruby"
        exit 1
        ;;
esac