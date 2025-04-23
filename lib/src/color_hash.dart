// filepath: /Users/vaibhav/development/Photo Tidy AI/imagehash/lib/src/color_hash.dart
import 'package:image/image.dart';
import 'hash_base.dart';

/// Computes the color hash of an image.
///
/// The color hash works by:
/// 1. Resizing the image to a small square (default 8x8)
/// 2. Extracting RGB color histograms
/// 3. Comparing pixel values to the median in each channel
///
/// [image] The image to hash
/// [hashSize] The size of the hash (width/height of the resized image)
///
/// Returns an [ImageHash] object containing the hash that has 3x the bits of a standard hash (RGB channels)
ImageHash colorHash(Image image, {int hashSize = 8}) {
  // Resize the image (keep colors)
  final smallImage = resizeForHash(
    image,
    width: hashSize,
    height: hashSize,
  );
  
  // Extract separate R, G, B values
  final rValues = <int>[];
  final gValues = <int>[];
  final bValues = <int>[];
  
  for (int y = 0; y < hashSize; y++) {
    for (int x = 0; x < hashSize; x++) {
      final pixel = smallImage.getPixel(x, y);
      rValues.add(pixel.r.toInt());
      gValues.add(pixel.g.toInt());
      bValues.add(pixel.b.toInt());
    }
  }
  
  // Calculate median values for each channel
  final rMedian = median(rValues.map((e) => e.toDouble()).toList());
  final gMedian = median(gValues.map((e) => e.toDouble()).toList());
  final bMedian = median(bValues.map((e) => e.toDouble()).toList());
  
  // Compute the hash for each channel: 1 if value >= median, 0 otherwise
  final bits = <bool>[];
  
  // R channel bits
  for (int i = 0; i < rValues.length; i++) {
    bits.add(rValues[i] >= rMedian);
  }
  
  // G channel bits
  for (int i = 0; i < gValues.length; i++) {
    bits.add(gValues[i] >= gMedian);
  }
  
  // B channel bits
  for (int i = 0; i < bValues.length; i++) {
    bits.add(bValues[i] >= bMedian);
  }
  
  // Return a hash with 3x the bits (one for each channel)
  return ImageHash(bits);
}
