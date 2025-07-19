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

/// Read PNG files from the text file
List<String> readPngFiles() {
  final file = File('png_files.txt');
  if (!file.existsSync()) {
    throw Exception('png_files.txt not found. Run the shell script first.');
  }

  final lines = file.readAsLinesSync();
  return lines.where((line) => line.trim().isNotEmpty).toList();
}

void main(List<String> args) {
  // Read PNG files from the text file
  final imageFiles = readPngFiles();

  if (imageFiles.isEmpty) {
    print('Error: No PNG files found in png_files.txt');
    exit(1);
  }

  print('Found ${imageFiles.length} PNG files for hashing');

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

  generateJsonOutput(imageFiles, hashFuncOpeners);
}

void generateJsonOutput(
  List<String> imageFiles,
  List<(String, ImageHash Function(String))> hashFuncOpeners,
) {
  // Process all images and collect hash data
  final Map<String, List<Map<String, dynamic>>> algorithmClusters = {
    'ahash': [],
    'phash': [],
    'dhash': [],
    'whash': [],
    'ahash-z': [],
    'phash-z': [],
    'dhash-z': [],
    'whash-z': [],
  };

  // Store all hash results
  final Map<String, Map<String, String>> imageHashes = {};

  for (final path in imageFiles) {
    try {
      final hashes = <String, String>{};
      for (final (name, hashFunc) in hashFuncOpeners) {
        try {
          final hash = hashFunc(path);
          hashes[name] = hash.toString();
        } catch (e) {
          stderr.writeln('Error processing $path with $name: $e');
          hashes[name] = 'ERROR';
        }
      }
      imageHashes[path] = hashes;
    } catch (e) {
      stderr.writeln('Error processing $path: $e');
    }
  }

  // Group images by hash for each algorithm
  for (final algorithm in [
    'ahash',
    'phash',
    'dhash',
    'whash',
    'ahash-z',
    'phash-z',
    'dhash-z',
    'whash-z',
  ]) {
    final Map<String, List<String>> hashGroups = {};

    for (final entry in imageHashes.entries) {
      final path = entry.key;
      final hashes = entry.value;
      final hash = hashes[algorithm];

      if (hash != null &&
          hash != 'ERROR' &&
          hash != '0000000000000000' &&
          hash.isNotEmpty) {
        hashGroups.putIfAbsent(hash, () => []).add(path);
      }
    }

    // Create clusters for groups with more than one image
    for (final entry in hashGroups.entries) {
      final hash = entry.key;
      final paths = entry.value;

      if (paths.length > 1) {
        final images =
            paths
                .map((path) {
                  final fileName = path
                      .split('/')
                      .last
                      .replaceAll('.png', '.svg');

                  // Generate GitHub URL based on repository pattern
                  String? imageUrl;
                  String? repoUrl;

                  // Extract repo info from the path structure
                  final parts = path.split('/');
                  if (parts.isNotEmpty) {
                    final repoDir = parts[0];
                    final filePath = parts
                        .sublist(1)
                        .join('/')
                        .replaceAll('.png', '.svg');

                    // Try to guess repo from directory name
                    if (repoDir.contains('eva-icons')) {
                      repoUrl = 'https://github.com/akveo/eva-icons';
                      imageUrl =
                          'https://raw.githubusercontent.com/akveo/eva-icons/master/$filePath';
                    } else if (repoDir.contains('feather')) {
                      repoUrl = 'https://github.com/feathericons/feather';
                      imageUrl =
                          'https://raw.githubusercontent.com/feathericons/feather/master/$filePath';
                    } else if (repoDir.contains('heroicons')) {
                      repoUrl = 'https://github.com/tailwindlabs/heroicons';
                      imageUrl =
                          'https://raw.githubusercontent.com/tailwindlabs/heroicons/master/$filePath';
                    } else if (repoDir.contains('lucide')) {
                      repoUrl = 'https://github.com/lucide-icons/lucide';
                      imageUrl =
                          'https://raw.githubusercontent.com/lucide-icons/lucide/master/$filePath';
                    }
                    // Skip entries that don't match known repositories
                  }

                  // Only return if we have valid GitHub URLs
                  if (repoUrl != null && imageUrl != null) {
                    return {
                      'name': fileName,
                      'url': imageUrl,
                      'repoUrl': repoUrl,
                    };
                  }
                  return null;
                })
                .whereType<Map<String, dynamic>>()
                .toList();

        // Only add cluster if we have valid images
        if (images.isNotEmpty) {
          algorithmClusters[algorithm]!.add({
            'hash': hash,
            'count': images.length,
            'images': images,
          });
        }
      }
    }
  }

  // Create final JSON structure
  final jsonOutput = {'algorithm': 'dart', 'clusters': algorithmClusters};

  // Write to example website directory
  final outputPath = '../example-website/src/lib/data/github-icons-dart.json';
  final jsonFile = File(outputPath);

  // Create directories if they don't exist
  jsonFile.parent.createSync(recursive: true);

  final encoder = JsonEncoder.withIndent('  ');
  jsonFile.writeAsStringSync(encoder.convert(jsonOutput));

  print('Generated $outputPath with ${imageFiles.length} images processed');
  for (final entry in algorithmClusters.entries) {
    print('  ${entry.key}: ${entry.value.length} clusters');
  }
}
