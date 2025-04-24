import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:dart_imagehash/dart_imagehash.dart';

/// Calculate similarity percentage based on hash distance
double calculateSimilarity(ImageHash hash1, ImageHash hash2) {
  final distance = hash1 - hash2;
  final maxDistance = hash1.bits.length;
  return 100.0 * (1.0 - (distance / maxDistance));
}

/// Compare images using the specified algorithm and print results
void compareWithAlgorithm(
  String algorithmName,
  Image image1,
  Image image2,
  String imageName1,
  String imageName2,
  ImageHash Function(Image) hashFunction,
) {
  print('\n$algorithmName - Comparing $imageName1 and $imageName2:');
  print(
    '-' * (algorithmName.length + imageName1.length + imageName2.length + 15),
  );

  final hash1 = hashFunction(image1);
  final hash2 = hashFunction(image2);

  // Calculate similarity score (0-100%, where 100% means identical)
  final similarityScore = calculateSimilarity(hash1, hash2);

  print('Hash 1 ($imageName1):  ${hash1.toString()}');
  print('Hash 2 ($imageName2): ${hash2.toString()}');
  print('Hamming distance: ${hash1 - hash2}');
  print('Similarity: ${similarityScore.toStringAsFixed(2)}%');
}

/// Compare images using the specified algorithm and print results, using bytes directly
void compareWithAlgorithmFromBytes(
  String algorithmName,
  Uint8List bytes1,
  Uint8List bytes2,
  String imageName1,
  String imageName2,
  ImageHash Function(Uint8List) hashFunction,
) {
  print(
    '\n$algorithmName (from bytes) - Comparing $imageName1 and $imageName2:',
  );
  print(
    '-' * (algorithmName.length + imageName1.length + imageName2.length + 15),
  );

  final hash1 = hashFunction(bytes1);
  final hash2 = hashFunction(bytes2);

  // Calculate similarity score (0-100%, where 100% means identical)
  final similarityScore = calculateSimilarity(hash1, hash2);

  print('Hash 1 ($imageName1):  ${hash1.toString()}');
  print('Hash 2 ($imageName2): ${hash2.toString()}');
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
    final image1 = decodeImage(cat1.readAsBytesSync())!;
    final image2 = decodeImage(modifiedCatImage.readAsBytesSync())!;
    final image3 = decodeImage(cat2.readAsBytesSync())!;

    // Get image bytes
    final cat1Bytes = Uint8List.fromList(cat1.readAsBytesSync());
    final modifiedCatBytes = modifiedCatImage.readAsBytesSync();

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
      (img) => ImageHasher.averageHash(img),
    );

    compareWithAlgorithm(
      'Average Hash (aHash)',
      image1,
      image3,
      'cat1.JPG',
      'cat2.JPG',
      (img) => ImageHasher.averageHash(img),
    );

    // Compare using Average Hash (aHash) from bytes
    compareWithAlgorithmFromBytes(
      'Average Hash (aHash)',
      cat1Bytes,
      modifiedCatBytes,
      'cat1.JPG',
      'cat1-modified.JPG',
      (bytes) => ImageHasher.averageHashFromBytes(bytes),
    );

    // Compare using Perceptual Hash (pHash)
    compareWithAlgorithm(
      'Perceptual Hash (pHash)',
      image1,
      image2,
      'cat1.JPG',
      'cat1-modified.JPG',
      (img) => ImageHasher.perceptualHash(img),
    );

    compareWithAlgorithm(
      'Perceptual Hash (pHash)',
      image1,
      image3,
      'cat1.JPG',
      'cat2.JPG',
      (img) => ImageHasher.perceptualHash(img),
    );

    // Compare using Difference Hash (dHash)
    compareWithAlgorithm(
      'Difference Hash (dHash)',
      image1,
      image2,
      'cat1.JPG',
      'cat1-modified.JPG',
      (img) => ImageHasher.differenceHash(img),
    );

    compareWithAlgorithm(
      'Difference Hash (dHash)',
      image1,
      image3,
      'cat1.JPG',
      'cat2.JPG',
      (img) => ImageHasher.differenceHash(img),
    );

    // Compare using Wavelet Hash (wHash)
    compareWithAlgorithm(
      'Wavelet Hash (wHash)',
      image1,
      image2,
      'cat1.JPG',
      'cat1-modified.JPG',
      (img) => ImageHasher.waveletHash(img),
    );

    compareWithAlgorithm(
      'Wavelet Hash (wHash)',
      image1,
      image3,
      'cat1.JPG',
      'cat2.JPG',
      (img) => ImageHasher.waveletHash(img),
    );
  } catch (e, stackTrace) {
    print('Error occurred: $e');
    print('Stack trace: $stackTrace');
  }
}
