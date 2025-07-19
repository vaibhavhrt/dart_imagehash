# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.2] - 2025-07-19

### Changed

- Updated Dart SDK requirement to ^3.8.1 (latest stable)
- Updated lints dependency to ^6.0.0
- Added project website link to README

### Added

- Project website at https://vaibhavhrt.github.io/dart_imagehash/

## [2.0.1] - 2025-04-28

### Fixed

- Moved the main image hash example from `example/hash_example.dart` to `example/main.dart`.

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
