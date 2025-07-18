#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
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

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart basic_demo_hashes.dart <image_file1> [image_file2] ...');
    exit(1);
  }

  final List<String> imageFiles = args;
  final List<Map<String, dynamic>> imageHashes = [];

  for (final path in imageFiles) {
    try {
      final file = File(path);
      final bytes = file.readAsBytesSync();
      final image = decodeImage(bytes);
      if (image == null) {
        stderr.writeln('Failed to decode image: $path');
        continue;
      }

      final processedImage = alphaRemover(image);
      final fileName = path.split('/').last;

      // Generate GitHub URL for the image
      final imageUrl =
          'https://raw.githubusercontent.com/vaibhavhrt/dart_imagehash/main/sample_images/$fileName';

      final hashes = <String, String>{};

      // Calculate all hash types
      for (final (name, func) in hashFunctions) {
        try {
          final hash = func(processedImage);
          hashes[name] = hash.toString();
        } catch (e) {
          stderr.writeln('Error processing $path with $name: $e');
          hashes[name] = 'ERROR';
        }
      }

      imageHashes.add({'name': fileName, 'url': imageUrl, 'hashes': hashes});
    } catch (e) {
      stderr.writeln('Error processing $path: $e');
    }
  }

  // Create final JSON structure
  final jsonOutput = {'algorithm': 'dart', 'images': imageHashes};

  // Write to example website directory
  final outputPath = '../example-website/src/lib/data/basic-demo-dart.json';
  final jsonFile = File(outputPath);

  // Create directories if they don't exist
  jsonFile.parent.createSync(recursive: true);

  final encoder = JsonEncoder.withIndent('  ');
  jsonFile.writeAsStringSync(encoder.convert(jsonOutput));

  print('Generated $outputPath with ${imageFiles.length} images processed');
}
