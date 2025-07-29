#!/usr/bin/env python3

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
import time

WORKDIR = os.path.dirname(__file__)
BINARY = os.path.join(WORKDIR, "codech.py")
KEY = os.path.join(WORKDIR, "key.txt")


def main(args):
    original, encoded, decoded = filenames(args.file)
    if args.size:
        make_file(args, original, args.size)
    else:
        size = (os.path.getsize(args.file) / 1024) / 1024
    original_sum = checksum_file(original)
    print(f"Checksum › {colorize(args, Colors.OKGREEN, original_sum)}")
    execute(
        args,
        original,
        encoded,
        "Encoding",
        "--encode",
        size if not args.size else args.size,
    )
    execute(
        args,
        encoded,
        decoded,
        "Decoding",
        "--decode",
        size if not args.size else args.size,
    )
    decoded_sum = checksum_file(decoded)
    color, exitcode = (
        (Colors.OKGREEN, 0) if original_sum == decoded_sum else (Colors.FAIL, 1)
    )
    print(f"Checksum › {colorize(args, color, decoded_sum)}")
    if args.horizontal_ruler:
        hr()
    return exitcode


def colorize(args, color, message):
    if os.name == "nt" or args.no_color:
        return message
    return f"{color}{message}{Colors.ENDC}"


def filenames(original):
    return original, f"{original}.encoded", f"{original}.decoded"


class Colors:
    OKBLUE = "\033[94m"  # write operation succeeded
    OKGREEN = "\033[92m"  # readonly operation succeeded
    OKPURPLE = "\033[95m"  # readonly (fetch) operation succeeded
    WARNING = "\033[93m"  # operation succeeded with non-default result
    FAIL = "\033[91m"  # operation did not succeed
    ENDC = "\033[0m"  # reset color


def execute(args, source, dest, word, flag, size):
    def checked_division(num, den):
        if den == 0:
            return "too fast to measure, try with the option -t"
        return f"{num / den:.2f} MB/s"

    print(f"{word}...", end="\r")
    res = execute_codec(args, flag, source, dest)
    if not args.timings:
        seconds = float(res)
        print(
            f"{word} › {colorize(args, Colors.OKGREEN, f'{seconds:.2f}s')} ({checked_division(size, seconds)})"
        )
    else:
        timings = [float(r) for r in res.split()]
        speeds = []
        if flag == "--encode":
            speeds.append(checked_division(size, timings[0]))
            speeds.append(checked_division(size, timings[1]))
            speeds.append(checked_division(size * 2, timings[2]))
        if flag == "--decode":
            speeds.append(checked_division(size * 2, timings[0]))
            speeds.append(checked_division(size, timings[1]))
            speeds.append(checked_division(size, timings[2]))
        total = sum(timings)
        stats = (
            f"{word} › {colorize(args, Colors.OKGREEN, f'{total:.3f}s')} ({checked_division(size, total)})",
            f"  reading  › {timings[0]:.3f}s ({speeds[0]})",
            f"  {word.lower()} › {timings[1]:.3f}s ({speeds[1]})",
            f"  writing  › {timings[2]:.3f}s ({speeds[2]})",
        )
        print("\n".join(stats))


def execute_codec(args, action, source, dest):
    cmd = f"{args.binary} {args.key} {action} {source} {dest}".split()
    if args.timings:
        cmd.append("--timings")
    else:
        cmd = "/usr/bin/time -f %e".split() + cmd
    return subprocess.check_output(cmd, stderr=subprocess.STDOUT).decode("utf-8")


def checksum_file(filename):
    print("Checksum...", end="\r")
    return (
        subprocess.check_output(f"md5sum {filename}".split()).split()[0].decode("utf-8")
    )


def make_file(args, filename, size):
    display_size, unit = (size, "MB") if size < 1023 else (round(size / 1024, 2), "GB")
    print(f"Making a {display_size} {unit} file...", end="\r")
    silent_run(f"dd if=/dev/urandom of={filename} bs=1M count={size}".split())
    print(
        f"Making a {display_size} {unit} file › {colorize(args, Colors.OKGREEN, 'Done')}"
    )


def hr():
    _, columns = tuple(map(int, subprocess.check_output(("stty", "size")).split()))
    print("―" * columns)


def silent_run(cmd):
    with open(os.devnull) as devnull:
        subprocess.run(cmd, stdout=devnull, stderr=devnull)


def cleanup(original):
    for tmp in filenames(original):
        try:
            os.remove(tmp)
        except:
            pass


def parse_args():
    parser = argparse.ArgumentParser(
        description="Benchmarking script for the codech project."
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--size", "-s", type=int, help="file size to benchmark (in MegaByte)",
    )
    group.add_argument(
        "--file",
        "-f",
        help="specific file to encode and decode",
        default=tempfile.mktemp(),
    )
    parser.add_argument(
        "--horizontal-ruler",
        "-hr",
        action="store_true",
        help="prints a line across the screen at the end",
    )
    parser.add_argument("--no-color", "-nc", action="store_true", help="disable colors")
    parser.add_argument(
        "--binary", "-b", help=f"set binary (default is '{BINARY[2:]}')", default=BINARY
    )
    parser.add_argument(
        "--key", "-k", help=f"set key file (default is '{KEY[2:]}')", default=KEY
    )
    parser.add_argument(
        "--timings",
        "-t",
        action="store_true",
        help="measure without counting I/O interactions",
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    if not args.size:
        copy = tempfile.mktemp()
        shutil.copyfile(args.file, copy)
        args.file = copy
    exitcode = 0
    try:
        exitcode = main(args)
    except KeyboardInterrupt:
        exitcode = 1
        print()
    except Exception as error:
        exitcode = 1
        print(error)
    cleanup(args.file)
    exit(exitcode)
