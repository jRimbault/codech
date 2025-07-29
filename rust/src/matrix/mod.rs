pub mod error;

use error::MatrixError;
use std::str::FromStr;

/// specific layout to build the other lookups
#[derive(Copy, Clone)]
struct BaseLookup([u8; 16]);

/// specific layout to make direct lookups during the encoding
#[derive(Copy, Clone)]
struct EncodeLookup([[u8; 2]; 256]);

/// specific layout to make direct lookups during the decoding
#[derive(Copy, Clone)]
struct DecodeLookup([u8; 256], [u8; 256]);

/// those data layout should allow for auto vectorization
#[derive(Copy, Clone)]
pub struct Matrix {
    encode: EncodeLookup,
    decode: DecodeLookup,
}

impl From<[u8; 4]> for Matrix {
    fn from(key: [u8; 4]) -> Matrix {
        let base: BaseLookup = key.into();
        Matrix {
            encode: base.into(),
            decode: base.into(),
        }
    }
}

impl FromStr for Matrix {
    type Err = MatrixError;

    fn from_str(value: &str) -> Result<Self, Self::Err> {
        let key = value
            .split_whitespace()
            .take(4)
            .map(|bin| u8::from_str_radix(&bin, 2))
            .collect::<Result<Vec<u8>, _>>()?;
        if key.len() < 4 {
            Err(MatrixError::KeyIsTooShort)
        } else {
            Ok([key[0], key[1], key[2], key[3]].into())
        }
    }
}

impl Matrix {
    pub fn encode(&self, byte: u8) -> [u8; 2] {
        self.encode.0[byte as usize]
    }

    pub fn decode(&self, byte0: u8, byte1: u8) -> u8 {
        self.decode.0[byte0 as usize] | self.decode.1[byte1 as usize]
    }
}

impl From<[u8; 4]> for BaseLookup {
    fn from(key: [u8; 4]) -> BaseLookup {
        BaseLookup([
            key[0] ^ key[1] ^ key[2] ^ key[3],
            key[3],
            key[2],
            key[2] ^ key[3],
            key[1],
            key[1] ^ key[3],
            key[1] ^ key[2],
            key[1] ^ key[2] ^ key[3],
            key[0],
            key[0] ^ key[3],
            key[0] ^ key[2],
            key[0] ^ key[2] ^ key[3],
            key[0] ^ key[1],
            key[0] ^ key[1] ^ key[3],
            key[0] ^ key[1] ^ key[2],
            0,
        ])
    }
}

impl From<BaseLookup> for DecodeLookup {
    fn from(base_lookup: BaseLookup) -> DecodeLookup {
        let mut lookup = [0; 256];
        let mut lookup_shifted = [0; 256];
        for (i, val) in base_lookup.0.iter().enumerate() {
            lookup[*val as usize] = i as u8;
            lookup_shifted[*val as usize] = (i as u8) << 4;
        }
        DecodeLookup(lookup, lookup_shifted)
    }
}

impl From<BaseLookup> for EncodeLookup {
    fn from(base_lookup: BaseLookup) -> EncodeLookup {
        fn encode(lookup: &[u8; 16], byte: u8) -> [u8; 2] {
            const MASK: u8 = 0x0f;
            const SHIFT: u8 = 4;
            [
                lookup[(byte & MASK) as usize],
                lookup[(byte >> SHIFT) as usize],
            ]
        }
        let mut lookup = [[0; 2]; 256];
        for (i, pair) in lookup.iter_mut().enumerate() {
            *pair = encode(&base_lookup.0, i as u8);
        }
        EncodeLookup(lookup)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use rstest::rstest;

    #[test]
    fn should_get_matrix() {
        let text = "01011100 00011101 10100100 10010010";
        let matrix = text.parse::<Matrix>();
        assert!(matrix.is_ok());
    }

    #[rstest(
        text,
        case("01011100 00011101 10102100 10010010"),
        case("abcdefghijklmnopqrstuvwxyza"),
        case("01011100 00011101 10010010"),
        case(""),
        case("01011100 00011101 10102100 10010010 01011100"),
        case("01011100 0001 110110101100 10010010")
    )]
    fn should_not_get_matrix(text: &str) {
        let matrix = text.parse::<Matrix>();
        assert!(matrix.is_err());
    }
}
