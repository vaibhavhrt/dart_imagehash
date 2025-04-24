# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-04-23

### Added

- New `ImageHasher` utility class with static methods:
  - `averageHash()`
  - `perceptualHash()`
  - `differenceHash()`
  - `differenceHashVertical()`
  - `waveletHash()`
  - `averageHashFromBytes()`
  - `perceptualHashFromBytes()`
  - `differenceHashFromBytes()`
  - `differenceHashVerticalFromBytes()`
  - `waveletHashFromBytes()`

### Changed

- API structure to use static methods through `ImageHasher` class

### Removed

- Direct function exports:
  - `averageHash()`
  - `perceptualHash()`
  - `differenceHash()`
  - `differenceHashVertical()`
  - `waveletHash()`

### Fixed

- Error handling for invalid inputs
- API consistency across all hash types
- Documentation and examples

## [1.0.0] - 2024-04-23

### Added

- Initial release with image hashing functionality
- Support for Average Hash (aHash), Perceptual Hash (pHash), Difference Hash (dHash), and Wavelet Hash (wHash)
- Basic image comparison functionality
