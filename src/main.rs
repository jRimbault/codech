mod args;
mod build_info;
mod codec;
mod matrix;

use args::{parse_args, Argument};
use codec::{decode, encode};
use matrix::get_matrix;

use exitcode;
use rayon::prelude::*;
use std::env;
use std::fs;
use std::fs::File;
use std::io;
use std::io::prelude::*;
use std::process;

fn main() {
    process::exit(match run() {
        None => exitcode::OK,
        Some(error) => {
            println!("{}", error);
            error.raw_os_error().unwrap_or(1)
        }
    })
}

fn run() -> Option<std::io::Error> {
    let args = parse_args(env::args());
    let matrix = get_matrix(args.value_of(Argument::KeyFile).unwrap());
    if let Err(error) = matrix {
        return Some(error);
    }
    let (matrix, reverse) = matrix.unwrap();
    let source = args.value_of(Argument::Source).unwrap();
    let result = if args.is_present(Argument::Encode) {
        work(|stream| encode(matrix, stream), source)
    } else {
        work(|stream| decode(reverse, stream), source)
    };
    if let Err(error) = result {
        return Some(error);
    }
    let dest = args.value_of(Argument::Dest).unwrap();
    if let Err(error) = write(dest, result.unwrap()) {
        return Some(error);
    }
    None
}

fn work<Worker>(task: Worker, file: &str) -> io::Result<Vec<u8>>
where
    Worker: Fn(&[u8]) -> Vec<u8>,
    Worker: std::marker::Sync,
    Worker: std::marker::Send,
{
    Ok(_work(task, fs::read(file)?, num_cpus::get()))
}

fn _work<Worker>(task: Worker, stream: Vec<u8>, num_workers: usize) -> Vec<u8>
where
    Worker: Fn(&[u8]) -> Vec<u8>,
    Worker: std::marker::Sync,
    Worker: std::marker::Send,
{
    flatten(
        stream
            .par_chunks(chunk_size(stream.len(), num_workers))
            .map(task)
            .collect(),
    )
}

fn flatten<T>(collections: Vec<Vec<T>>) -> Vec<T> {
    let mut result = Vec::new();
    for col in collections {
        result.extend(col);
    }
    result
}

/// chunk size should always be even for the decoding phase
fn chunk_size(stream_len: usize, available_max_workers: usize) -> usize {
    const MASK: usize = std::usize::MAX - 1;
    match stream_len.checked_div(available_max_workers) {
        Some(chunk_size) => {
            if chunk_size & MASK == 0 {
                stream_len
            } else {
                chunk_size & MASK
            }
        }
        None => stream_len, // only one chunk, always even for encoded files
    }
}

fn write(filename: &str, buffer: Vec<u8>) -> io::Result<()> {
    File::create(filename)?.write_all(&buffer)
}

#[cfg(test)]
mod main_tests {
    use super::*;
    use matrix::get_reverse_matrix;
    use matrix::Matrix;
    use rstest::rstest_parametrize;

    static MATRIX: Matrix = [
        126, 146, 164, 54, 199, 85, 99, 241, 143, 29, 43, 185, 72, 218, 236, 0,
    ];

    fn random(n: usize) -> Vec<u8> {
        const MAX_CHUNK: usize = 32;
        (0..(n / MAX_CHUNK) + 1)
            .map(|_| rand::random::<[u8; MAX_CHUNK]>().to_vec())
            .flatten()
            .collect::<Vec<u8>>()[..n]
            .to_vec()
    }

    #[rstest_parametrize(
        n,
        case(1),
        case(2),
        case(3),
        case(4),
        case(5),
        case(6),
        case(7),
        case(8),
        case(9),
        case(10),
        case(11),
        case(12),
        case(13),
        case(14),
        case(15),
        case(16),
        case(32),
        case(63),
        case(64)
    )]
    fn should_test_parallelization(n: usize) {
        let original = random(59577);
        assert_eq!(original.len(), 59577);
        let encoded = _work(|s| encode(MATRIX, s), original.to_vec(), n);
        assert!(encoded.len() % 2 == 0);
        let reverse = get_reverse_matrix(MATRIX);
        let decoded = _work(|s| decode(reverse, s), encoded, n);
        assert_eq!(original, decoded);
    }
}