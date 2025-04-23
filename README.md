# imagehash

A Dart package for perceptual image hashing, inspired by the [Python imagehash library](https://github.com/JohannesBuchner/imagehash).

Image hashing algorithms generate compact, fixed-length fingerprints from images that allow you to:
- Find visually similar images (even with small transformations)
- Detect duplicate or near-duplicate images
- Perform content-based image retrieval

## Features

This package provides multiple image hashing algorithms:

- **Average Hash (aHash)**: A simple but effective algorithm that compares pixel values to the average
- **Perceptual Hash (pHash)**: Uses DCT transformation to focus on significant image features
- **Difference Hash (dHash)**: Compares adjacent pixels to detect gradients in the image
- **Wavelet Hash (wHash)**: Uses Haar wavelet decomposition to extract frequency information
- **Color Hash**: Extends the hash concept to work with all three RGB channels
- **Crop-Resistant Hash**: More robust to cropping operations by using multiple hashes or feature detection

## Getting started

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  imagehash: ^0.1.0
  image: ^4.0.0  # Required for image processing
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

## Algorithm Selection Guide

- **Average Hash (aHash)**: Fastest algorithm, works well for simple cases
- **Perceptual Hash (pHash)**: More accurate but slower, robust to small changes
- **Difference Hash (dHash)**: Good at detecting edges, robust to brightness changes
- **Wavelet Hash (wHash)**: Good at preserving texture details, robust to noise
- **Color Hash**: Use when color information is important
- **Crop-Resistant Hash**: Use when images might be cropped or for partial matching

## Additional information

This package is a Dart implementation of the algorithms found in the [Python imagehash library](https://github.com/JohannesBuchner/imagehash). For more information about the theory behind perceptual hashing, see:

- [Perceptual Hashing](https://www.hackerfactor.com/blog/index.php?/archives/432-Looks-Like-It.html)
- [pHash.org](https://www.phash.org/)
