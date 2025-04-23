import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:imagehash/imagehash.dart';

/// Calculate similarity percentage based on hash distance
double calculateSimilarity(ImageHash hash1, ImageHash hash2) {
  final distance = hash1 - hash2;
  final maxDistance = hash1.bits.length;
  return 100.0 * (1.0 - (distance / maxDistance));
}

/// Compare images using the specified algorithm and print results
void compareWithAlgorithm(
  String algorithmName,
  img.Image image1,
  img.Image image2,
  String imageName1,
  String imageName2,
  ImageHash Function(img.Image) hashFunction,
) {
  print('\n$algorithmName - Comparing $imageName1 and $imageName2:');
  print(
    '-' * (algorithmName.length + imageName1.length + imageName2.length + 15),
  );

  final hash1 = hashFunction(image1);
  final hash2 = hashFunction(image2);

  // Calculate similarity score (0-100%, where 100% means identical)
  final similarityScore = calculateSimilarity(hash1, hash2);

  print('Hash 1 ($imageName1):  ${hash1.toHex()}');
  print('Hash 2 ($imageName2): ${hash2.toHex()}');
  print('Hamming distance: ${hash1 - hash2}');
  print('Similarity: ${similarityScore.toStringAsFixed(2)}%');
}

void main() {
  try {
    print('Starting Image Hash Example...');

    final script = File(Platform.script.toFilePath());
    final currentDir = script.parent;
    final sampleImagesDir = Directory('${currentDir.path}/../sample_images');

    final cat1 = File('${sampleImagesDir.path}/cat1.JPG');
    // Slightly modified image of cat1, cropped a bit and added some drawing
    final modifiedCatImage = File('${sampleImagesDir.path}/cat1-modified.JPG');
    // Different image of the same cat
    final cat2 = File('${sampleImagesDir.path}/cat2.JPG');

    // Load sample images
    final image1 = img.decodeImage(cat1.readAsBytesSync())!;
    final image2 = img.decodeImage(modifiedCatImage.readAsBytesSync())!;
    final image3 = img.decodeImage(cat2.readAsBytesSync())!;

    print('Image Hash Comparison Example');
    print('============================');
    print(
      'Comparing images: cat1.JPG vs cat1-modified.JPG (similar) and cat1.JPG vs cat2.JPG (different)',
    );

    // Compare using Average Hash (aHash)
    compareWithAlgorithm(
      'Average Hash (aHash)',
      image1,
      image2,
      'cat1.JPG',
      'cat1-modified.JPG',
      (img) => averageHash(img),
    );

    compareWithAlgorithm(
      'Average Hash (aHash)',
      image1,
      image3,
      'cat1.JPG',
      'cat2.JPG',
      (img) => averageHash(img),
    );

    // Compare using Perceptual Hash (pHash)
    compareWithAlgorithm(
      'Perceptual Hash (pHash)',
      image1,
      image2,
      'cat1.JPG',
      'cat1-modified.JPG',
      (img) => perceptualHash(img),
    );

    compareWithAlgorithm(
      'Perceptual Hash (pHash)',
      image1,
      image3,
      'cat1.JPG',
      'cat2.JPG',
      (img) => perceptualHash(img),
    );

    // Compare using Difference Hash (dHash)
    compareWithAlgorithm(
      'Difference Hash (dHash)',
      image1,
      image2,
      'cat1.JPG',
      'cat1-modified.JPG',
      (img) => differenceHash(img),
    );

    compareWithAlgorithm(
      'Difference Hash (dHash)',
      image1,
      image3,
      'cat1.JPG',
      'cat2.JPG',
      (img) => differenceHash(img),
    );

    // Compare using Wavelet Hash (wHash)
    compareWithAlgorithm(
      'Wavelet Hash (wHash)',
      image1,
      image2,
      'cat1.JPG',
      'cat1-modified.JPG',
      (img) => waveletHash(img),
    );

    compareWithAlgorithm(
      'Wavelet Hash (wHash)',
      image1,
      image3,
      'cat1.JPG',
      'cat2.JPG',
      (img) => waveletHash(img),
    );
  } catch (e, stackTrace) {
    print('Error occurred: $e');
    print('Stack trace: $stackTrace');
  }
}
