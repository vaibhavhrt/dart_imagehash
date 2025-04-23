import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:imagehash/imagehash.dart';

/// Calculate similarity percentage based on hash distance
double calculateSimilarity(ImageHash hash1, ImageHash hash2) {
  final distance = hash1.distance(hash2);
  final maxDistance = hash1.bits.length;
  return 100.0 * (1.0 - (distance / maxDistance));
}

/// Compare images using the specified algorithm and print results
void compareWithAlgorithm(
  String algorithmName,
  img.Image image1,
  img.Image image2,
  ImageHash Function(img.Image) hashFunction,
) {
  print('\n$algorithmName:');
  print('-' * (algorithmName.length + 1));

  final hash1 = hashFunction(image1);
  final hash2 = hashFunction(image2);

  // Calculate similarity score (0-100%, where 100% means identical)
  final similarityScore = calculateSimilarity(hash1, hash2);

  print('Hash 1 (seven.PNG):  ${hash1.toHex()}');
  print('Hash 2 (seven2.PNG): ${hash2.toHex()}');
  print('Hamming distance: ${hash1.distance(hash2)}');
  print('Similarity: ${similarityScore.toStringAsFixed(2)}%');
}

void main() {
  try {
    print('Starting Image Hash Example...');

    // Find the sample images
    final directory = Directory(
      '/Users/vaibhav/development/Photo Tidy AI/imagehash',
    );
    final sampleImagesDir = Directory('${directory.path}/sample_images');

    if (!sampleImagesDir.existsSync()) {
      print(
        'Error: Sample images directory not found at ${sampleImagesDir.path}',
      );
      print('Current working directory: ${Directory.current.path}');
      return;
    }

    final sevenFile = File('${sampleImagesDir.path}/seven.PNG');
    final sevenTwoFile = File('${sampleImagesDir.path}/seven2.PNG');

    if (!sevenFile.existsSync()) {
      print('Error: seven.PNG not found at ${sevenFile.path}');
      return;
    }

    if (!sevenTwoFile.existsSync()) {
      print('Error: seven2.PNG not found at ${sevenTwoFile.path}');
      return;
    }

    // Load sample images
    final image1 = img.decodeImage(sevenFile.readAsBytesSync())!;
    final image2 = img.decodeImage(sevenTwoFile.readAsBytesSync())!;

    print('Image Hash Comparison Example');
    print('============================');
    print('Comparing two similar images: seven.PNG and seven2.PNG');

    // Compare using Average Hash (aHash)
    compareWithAlgorithm(
      'Average Hash (aHash)',
      image1,
      image2,
      (img) => averageHash(img),
    );

    // Compare using Perceptual Hash (pHash)
    compareWithAlgorithm(
      'Perceptual Hash (pHash)',
      image1,
      image2,
      (img) => perceptualHash(img),
    );

    // Compare using Difference Hash (dHash)
    compareWithAlgorithm(
      'Difference Hash (dHash)',
      image1,
      image2,
      (img) => differenceHash(img),
    );

    // Compare using Wavelet Hash (wHash)
    compareWithAlgorithm(
      'Wavelet Hash (wHash)',
      image1,
      image2,
      (img) => waveletHash(img),
    );

    // Compare using Color Hash
    compareWithAlgorithm('Color Hash', image1, image2, (img) => colorHash(img));

    // Compare using Crop-Resistant Hash
    compareWithAlgorithm(
      'Crop-Resistant Hash',
      image1,
      image2,
      (img) => cropResistantHash(img),
    );
  } catch (e, stackTrace) {
    print('Error occurred: $e');
    print('Stack trace: $stackTrace');
  }
}
