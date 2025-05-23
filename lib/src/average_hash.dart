import 'package:image/image.dart';
import 'package:collection/collection.dart';

import 'image_hasher.dart';
import 'image_utils.dart';

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

  final smallImage = resizeForHash(
    grayscale(image),
    width: hashSize,
    height: hashSize,
  );

  final pixels = extractPixelValues(smallImage);

  final avg = pixels.average;
  final bits = pixels.map((p) => p > avg).toList();

  return ImageHash(bits);
}
