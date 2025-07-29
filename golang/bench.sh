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
#/   --binary, -b       set binary (change the default)
usage() {
  grep '^#/' "$0" | cut -c4-
  exit 0
}

set -eu

readonly workdir="$(dirname "${BASH_SOURCE[0]}")"
readonly original="$(mktemp --suffix=.original)"
readonly encoded="$(mktemp --suffix=.encoded)"
readonly decoded="$(mktemp --suffix=.decoded)"
readonly key="$workdir"/key.txt
binary="$workdir"/codech

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
      "-b"|"--binary")
        binary="$2"
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

execute() {
  local seconds speed
  echo -en "$1...\r"
  seconds=$(timeit "$binary" "$key" "$2" "$3" "$4")
  speed="$(python3 -c "print(round($size / $seconds, 2))") Mo/s"
  echo -en "\r$1 › $(green "${seconds}s") ($speed)\n"
  rm "$3"
}

main() {
  local sum_original sum_decoded msg speed
  if (( size > 1023 )); then
    msg="Making a $(python3 -c "print(round($size/1024, 2))") Go file"
    echo -en "$msg...\r"
  else
    msg="Making a $size Mo file"
    echo -en "$msg...\r"
    sleep 2
  fi
  dd if=/dev/urandom of="$original"  bs=1M  count="$size" 2> /dev/null
  echo -en "\r$msg › $(green Done)\n"

  echo -en "Checksum...\r"
  sum_original=$(checksum_file "$original")
  echo -en "\rChecksum › $(green "$sum_original")\n"

  execute Encoding --encode "$original" "$encoded"
  execute Decoding --decode "$encoded" "$decoded"

  echo -en "Checksum...\r"
  sum_decoded=$(checksum_file "$decoded")
  rm "$decoded"
  if [[ "$sum_original" = "$sum_decoded" ]]; then
    echo -en "\rChecksum › $(green "$sum_decoded")\n"
  else
    echo -en "\rChecksum › $(red "$sum_decoded")\n"
    exit 1
  fi

  if [[ "$separator" = "true" ]]; then
    hr
  fi
}

cleanup() {
  rm "$original" || true
  rm "$encoded" || true
  rm "$decoded" || true
}

trap cleanup SIGHUP SIGINT SIGTERM

# if binary hasn't been compiled yet
if [[ ! -f "$binary" ]]; then
  echo "$binary not found"
  echo " › execute \`make\`"
  cleanup
  exit 1
fi
# executes only when executed directly not sourced
if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  parse_args "$@"
  main
fi
