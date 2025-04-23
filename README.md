# imagehash

A Dart package for perceptual image hashing, inspired by the [Python imagehash library](https://github.com/JohannesBuchner/imagehash).

Image hashing algorithms generate compact, fixed-length fingerprints from images that allow you to:

- Find visually similar images (even with small transformations)
- Detect duplicate or near-duplicate images
- Perform content-based image retrieval

## Features

This package provides multiple image hashing algorithms:

- **Average Hash (aHash)**
- **Perceptual Hash (pHash)**
- **Difference Hash (dHash)**
- **Wavelet Hash (wHash)**

## Getting started

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  imagehash: latest_version
```

Then run:

```bash
dart pub get
```

## Usage

```dart
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:imagehash/imagehash.dart';

void main() {
  // Load images
  final image1 = img.decodeImage(File('image1.jpg').readAsBytesSync())!;
  final image2 = img.decodeImage(File('image2.jpg').readAsBytesSync())!;

  // Calculate hashes
  final hash1 = averageHash(image1);
  final hash2 = averageHash(image2);

  // Calculate the similarity (0-1, where 1 is identical)
  final hashDistance = hash1 - hash2;
  final similarity = 1.0 - (hashDistance / (hash1.hashSize * hash1.hashSize));

  print('Hash 1: ${hash1}');
  print('Hash 2: ${hash2}');
  print('Distance: $hashDistance');
  print('Similarity: ${(similarity * 100).toStringAsFixed(2)}%');

  // Try other hashing algorithms
  final pHash1 = perceptualHash(image1);
  final pHash2 = perceptualHash(image2);
  print('Perceptual Hash distance: ${pHash1 - pHash2}');
}
```

For a more comprehensive example that demonstrates comparing images with all four hash algorithms, check out the [example](example) included in this package. The example demonstrates how to:

- Calculate and compare hashes for similar and different images
- Display similarity percentages for each algorithm
- Handle file loading with relative paths

## Hash Comparison

Image hashes are compared using the Hamming distance - the number of bits that differ between two hashes. A smaller distance indicates more similar images.

```dart
// Get the Hamming distance
int distance = hash1 - hash2;

// Boolean comparison (only true if exactly equal)
bool identical = hash1 == hash2;

// Convert hash to hex string
String hexString = hash1.toString(); // or hash1.toHex()

// Create hash from hex string
var hash = ImageHash.fromHex('f8e0a060c020f8e0', 8);
```

## Additional information

This package is a Dart implementation of the algorithms found in the [Python imagehash library](https://github.com/JohannesBuchner/imagehash). For more information about the theory behind perceptual hashing, see:

- [Perceptual Hashing](https://www.hackerfactor.com/blog/index.php?/archives/432-Looks-Like-It.html)
- [pHash.org](https://www.phash.org/)
- [Difference Hashing](https://www.hackerfactor.com/blog/index.php?/archives/529-Kind-of-Like-That.html)
