import 'dart:math';
import 'package:image/image.dart';
import 'hash_base.dart';

/// Computes the perceptual hash (pHash) of an image.
///
/// The perceptual hash works by:
/// 1. Converting the image to grayscale
/// 2. Resizing to a larger square (default 32x32)
/// 3. Computing the DCT (Discrete Cosine Transform)
/// 4. Retaining the low-frequency components (top-left 8x8 or specified hash size)
/// 5. Computing the median value of these components
/// 6. Setting bits to 1 if component value >= median, 0 otherwise
///
/// [image] The image to hash
/// [hashSize] The size of the hash (width/height of the final hash)
/// [highFreqFactor] The factor to determine the size of the initial resized image
///
/// Returns an [ImageHash] object containing the hash
ImageHash perceptualHash(
  Image image, {
  int hashSize = 8,
  int highFreqFactor = 4,
}) {
  if (hashSize < 2) {
    throw ArgumentError('Hash size must be at least 2');
  }

  final imageSize = hashSize * highFreqFactor;
  final smallImage = resizeForHash(
    grayscale(image),
    width: imageSize,
    height: imageSize,
  );

  final pixels = extractPixelValues(smallImage);

  final dct = _applyDCT(pixels, imageSize);

  final components = <double>[];
  for (int y = 0; y < hashSize; y++) {
    for (int x = 0; x < hashSize; x++) {
      // Include the DC component (0,0)
      components.add(dct[y * imageSize + x]);
    }
  }

  // Compute the median value of these components (including DC)
  final med = median(components);

  // Compute the hash: 1 if component > median, 0 otherwise
  final bits = <bool>[];
  for (int y = 0; y < hashSize; y++) {
    for (int x = 0; x < hashSize; x++) {
      // Compare all components in the top-left block against the median
      bits.add(dct[y * imageSize + x] > med);
    }
  }

  return ImageHash(bits);
}

/// Applies the Discrete Cosine Transform to a 2D matrix of pixel values.
///
/// This is a simplified DCT implementation that works for our purposes.
/// [pixels] The linearized 2D array of pixel values
/// [size] The width/height of the square image
///
/// Returns a linearized 2D array of DCT coefficients
List<double> _applyDCT(List<double> pixels, int size) {
  final result = List<double>.filled(size * size, 0);

  for (int u = 0; u < size; u++) {
    for (int v = 0; v < size; v++) {
      var sum = 0.0;

      for (int x = 0; x < size; x++) {
        for (int y = 0; y < size; y++) {
          sum +=
              pixels[y * size + x] *
              cos((2 * x + 1) * u * pi / (2 * size)) *
              cos((2 * y + 1) * v * pi / (2 * size));
        }
      }

      // Apply coefficient
      double alphaU = (u == 0) ? 1 / sqrt(2) : 1.0;
      double alphaV = (v == 0) ? 1 / sqrt(2) : 1.0;
      result[v * size + u] = alphaU * alphaV * sum / 4;
    }
  }

  return result;
}
