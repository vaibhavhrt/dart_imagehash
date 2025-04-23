// filepath: /Users/vaibhav/development/Photo Tidy AI/imagehash/lib/src/difference_hash.dart
import 'package:image/image.dart';
import 'hash_base.dart';

/// Computes the difference hash (dHash) of an image.
///
/// The difference hash works by:
/// 1. Converting the image to grayscale
/// 2. Resizing to a small rectangle (default 9x8 or 8x9, one dimension larger)
/// 3. Computing the difference between adjacent pixels
/// 4. Setting bits to 1 if the left pixel > right pixel (or top > bottom), 0 otherwise
///
/// [image] The image to hash
/// [hashSize] The size of the hash (width/height of the resized image minus 1)
/// [horizontal] If true, compare horizontally (left to right), otherwise vertically (top to bottom)
///
/// Returns an [ImageHash] object containing the hash
ImageHash differenceHash(
  Image image, 
  {int hashSize = 8, 
   bool horizontal = true}
) {
  // For horizontal comparison, we need width = hashSize+1, height = hashSize
  // For vertical comparison, we need width = hashSize, height = hashSize+1
  final width = horizontal ? hashSize + 1 : hashSize;
  final height = horizontal ? hashSize : hashSize + 1;
  
  // Convert to grayscale and resize
  final resizedImage = resizeForHash(
    grayscale(image), 
    width: width, 
    height: height
  );
  
  // Compute the hash based on pixel value differences
  final bits = <bool>[];
  
  if (horizontal) {
    // For each row, compare adjacent pixels horizontally
    for (int y = 0; y < hashSize; y++) {
      for (int x = 0; x < hashSize; x++) {
        final leftPixel = resizedImage.getPixel(x, y);
        final rightPixel = resizedImage.getPixel(x + 1, y);
        // True if left pixel is greater than right pixel
        bits.add(leftPixel.r > rightPixel.r);
      }
    }
  } else {
    // For each column, compare adjacent pixels vertically
    for (int y = 0; y < hashSize; y++) {
      for (int x = 0; x < hashSize; x++) {
        final topPixel = resizedImage.getPixel(x, y);
        final bottomPixel = resizedImage.getPixel(x, y + 1);
        // True if top pixel is greater than bottom pixel
        bits.add(topPixel.r > bottomPixel.r);
      }
    }
  }
  
  return ImageHash(bits);
}

/// Convenience method for horizontal difference hash
ImageHash horizontalDifferenceHash(Image image, {int hashSize = 8}) {
  return differenceHash(image, hashSize: hashSize, horizontal: true);
}

/// Convenience method for vertical difference hash
ImageHash verticalDifferenceHash(Image image, {int hashSize = 8}) {
  return differenceHash(image, hashSize: hashSize, horizontal: false);
}
