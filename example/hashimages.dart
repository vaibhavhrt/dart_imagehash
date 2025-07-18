#!/usr/bin/env dart

import 'dart:io';
import 'package:image/image.dart';
import 'package:dart_imagehash/dart_imagehash.dart';

/// Hash function definitions with their names and implementations
final hashFunctions = [
  ('ahash', (Image img) => ImageHasher.averageHash(img)),
  ('phash', (Image img) => ImageHasher.perceptualHash(img)),
  ('dhash', (Image img) => ImageHasher.differenceHash(img)),
  ('whash', (Image img) => ImageHasher.waveletHash(img)),
];

/// Remove alpha channel from image and convert to RGB
Image alphaRemover(Image image) {
  if (image.numChannels == 4) {
    // Convert RGBA to RGB by removing alpha channel
    final rgb = Image(width: image.width, height: image.height, numChannels: 3);

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        rgb.setPixel(
          x,
          y,
          ColorRgb8(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()),
        );
      }
    }
    return rgb;
  }
  return image;
}

/// Load image and apply hash function
ImageHash Function(String) imageLoader(ImageHash Function(Image) hashFunc) {
  return (String path) {
    final file = File(path);
    final bytes = file.readAsBytesSync();
    final image = decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image: $path');
    }
    return hashFunc(alphaRemover(image));
  };
}

/// Apply z-transform preprocessing before hashing
ImageHash Function(String) withZTransformPreprocess(
  ImageHash Function(Image) hashFunc, [
  int hashSize = 8,
]) {
  return (String path) {
    final file = File(path);
    final bytes = file.readAsBytesSync();
    var image = decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image: $path');
    }

    image = alphaRemover(image);

    // Convert to grayscale and resize
    image = grayscale(image);
    image = copyResize(image, width: hashSize, height: hashSize);

    // Apply z-transform preprocessing
    final pixels = <int>[];
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        pixels.add(pixel.r.toInt());
      }
    }

    // Calculate percentiles for z-transform
    pixels.sort();
    final percentiles = <double>[];
    for (int i = 0; i < 100; i++) {
      final index = (i / 99 * (pixels.length - 1)).round();
      percentiles.add(pixels[index].toDouble());
    }

    // Apply z-transform
    final transformedImage = Image(
      width: hashSize,
      height: hashSize,
      numChannels: 1,
    );

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final originalPixel = image.getPixel(x, y);
        final value = originalPixel.r.toInt();

        // Find position in percentiles
        double transformedValue = 0;
        for (int i = 0; i < percentiles.length - 1; i++) {
          if (value >= percentiles[i] && value <= percentiles[i + 1]) {
            transformedValue = i / 99 * 255;
            break;
          }
        }

        final newValue = transformedValue.round().clamp(0, 255);
        transformedImage.setPixel(
          x,
          y,
          ColorRgb8(newValue, newValue, newValue),
        );
      }
    }

    return hashFunc(transformedImage);
  };
}

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart hashimages.dart <image_file1> [image_file2] ...');
    exit(1);
  }

  // Create hash function openers
  final hashFuncOpeners = <(String, ImageHash Function(String))>[];

  // Add regular hash functions
  for (final (name, func) in hashFunctions) {
    hashFuncOpeners.add((name, imageLoader(func)));
  }

  // Add z-transform versions (excluding colorhash equivalent)
  for (final (name, func) in hashFunctions) {
    hashFuncOpeners.add(('$name-z', withZTransformPreprocess(func)));
  }

  // Process each file
  for (final path in args) {
    try {
      final hashes = <String>[];
      for (final (name, hashFunc) in hashFuncOpeners) {
        try {
          final hash = hashFunc(path);
          hashes.add(hash.toString());
        } catch (e) {
          print('Error processing $path with $name: $e');
          hashes.add('ERROR');
        }
      }
      print('$path ${hashes.join(' ')}');
    } catch (e) {
      print('Error processing $path: $e');
    }
  }
}
