#!/usr/bin/env bash
#/ Script Name: bench.sh
#/ Author: jRimbault
#/ Date:   2017-06-30
#/
#/ Description:
#/   Benchmarking script for the codec project.
#/   It will make a file of random bytes and then try to use
#/   the codec to time the encode and the decode of this file.
#/   Then it will compare the signature of the 3 resulting files.
#/
#/ Run Information:
#/   This script is called by the Makefile target `bench`
#/
#/ Usage: bench.sh -f <size in Mo>
#/
#/ Options:
#/   --help, -h         displays this help
#/   --file, -f         file size to benchmark
#/   --separator, -s    prints a line across the screen at the end
#/   --no-colors, -nc   disable colors
usage() {
  grep '^#/' "$0" | cut -c4-
  exit 0
}

set -eu

readonly workdir="$(dirname "${BASH_SOURCE[0]}")"
readonly original="$(mktemp --suffix=.original)"
readonly encoded="$(mktemp --suffix=.encoded)"
readonly decoded="$(mktemp --suffix=.decoded)"
readonly binary="$workdir"/build/Codech
readonly key="$workdir"/key.txt

hr() {
  local start=$'\e(0' end=$'\e(B' line='qqqqqqqqqqqqqqqq'
  local cols=${COLUMNS:-$(tput cols)}
  while ((${#line} < cols)); do line+="$line"; done
  printf '%s%s%s\n' "$start" "${line:0:cols}" "$end"
}

readonly NOCOL="\\033[0m" # No color
__colored() {
  if [[ "$color" = "true" ]]; then
    echo -e "${1}${2}${NOCOL}"
  else
    echo "$2"
  fi
}
green() { __colored "\\033[0;32m" "$*"; }
red() { __colored "\\033[0;31m" "$*"; }

parse_args() {
  size=64
  separator=false
  color=true
  while [[ $# -gt 0 ]]; do
    case "$1" in
      "-h"|"--help")
        usage
        ;;
      "-f"|"--file")
        size="$2"
        ;;
      "-s"|"--separator")
        separator=true
        ;;
      "-nc"|"--no-colors")
        color=false
        ;;
    esac
    shift
  done
}

timeit() {
  /usr/bin/time -f "%e" "$@" 2>&1
}

checksum_file() {
  md5sum "$1" | cut -d' ' -f1
}

main() {
  local seconds sum_original sum_decoded
  if (( size > 1023 )); then
    echo "Making a $(python3 -c "print(round($size/1024, 2))") Go file..."
  else
    echo "Making a $size Mo file..."
  fi
  dd if=/dev/urandom of="$original"  bs=1M  count="$size" 2> /dev/null
  echo " › $(green Done)"

  echo "Checksum original file..."
  sum_original=$(checksum_file "$original")
  echo " › $(green "$sum_original")"

  echo "Encoding..."
  seconds=$(timeit "$binary" "$key" --encode "$original" "$encoded")
  echo " › $(green "${seconds}s")"
  rm "$original"

  echo "Decoding..."
  seconds=$(timeit "$binary" "$key" --decode "$encoded" "$decoded")
  echo " › $(green "${seconds}s")"
  rm "$encoded"

  echo "Checksum decoded file..."
  sum_decoded=$(checksum_file "$decoded")
  rm "$decoded"
  if [[ "$sum_original" = "$sum_decoded" ]]; then
    echo " › $(green "$sum_decoded")"
  else
    echo " › $(red "$sum_decoded")"
    exit 1
  fi

  if [[ "$separator" = "true" ]]; then
    hr
  fi
}

# if binary hasn't been compiled yet
if [[ ! -f "$binary" ]]; then
  echo "$binary not found"
  echo " › execute \`make\`"
  exit 1
fi
# executes only when executed directly not sourced
if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  parse_args "$@"
  main
fi
