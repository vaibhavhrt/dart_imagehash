import 'package:image/image.dart';
import 'hash_base.dart';
import 'package:collection/collection.dart';

/// Computes the average hash (aHash) of an image.
///
/// The average hash works by:
/// 1. Converting the image to grayscale
/// 2. Resizing to a small square (default 8x8)
/// 3. Computing the average gray value
/// 4. Setting bits to 1 if pixel value >= average, 0 otherwise
///
/// [image] The image to hash
/// [hashSize] The size of the hash (width/height of the resized image)
///
/// Returns an [ImageHash] object containing the hash
ImageHash averageHash(Image image, {int hashSize = 8}) {
  if (hashSize < 2) {
    throw ArgumentError('Hash size must be at least 2');
  }
  // Convert to grayscale and resize
  final smallImage = resizeForHash(
    grayscale(image),
    width: hashSize,
    height: hashSize,
  );

  final List<int> pixels = [];
  for (int y = 0; y < hashSize; y++) {
    for (int x = 0; x < hashSize; x++) {
      final pixel = smallImage.getPixel(x, y);
      // For grayscale images, r, g, and b are the same, so we can use any channel
      pixels.add(pixel.r.toInt());
    }
  }

  final avg = pixels.average;
  final bits = pixels.map((p) => p >= avg).toList();

  return ImageHash(bits);
}
