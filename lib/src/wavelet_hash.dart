import 'package:image/image.dart';

import 'image_hasher.dart';
import 'image_utils.dart';

/// Computes the wavelet hash (wHash) of an image.
///
/// The wavelet hash works by:
/// 1. Converting the image to grayscale
/// 2. Resizing to a square (default 8x8 * scale)
/// 3. Applying a Haar wavelet decomposition
/// 4. Computing the hash from the lowest frequency components
///
/// [image] The image to hash
/// [hashSize] The size of the hash (width/height of the final hash)
/// [mode] The wavelet mode ('haar' is the only supported mode currently)
/// [scale] The factor to determine the size of the initial resized image
///
/// Returns an [ImageHash] object containing the hash
ImageHash waveletHash(
  Image image, {
  int hashSize = 8,
  String mode = 'haar',
  int scale = 4,
}) {
  if (mode != 'haar') {
    throw ArgumentError('Only haar wavelet mode is supported');
  }

  final imageSize = hashSize * scale;
  final smallImage = resizeForHash(
    grayscale(image),
    width: imageSize,
    height: imageSize,
  );

  final pixels = extractPixelValues(smallImage);

  var coeffs = pixels;
  var size = imageSize;

  // Perform wavelet decomposition until we reach the desired hash size
  while (size > hashSize) {
    size ~/= 2;
    coeffs = _haarWavelet2D(coeffs, size * 2, size);
  }

  // Extract the low-frequency coefficients from the top-left quadrant
  final lowFreq = List<double>.filled(hashSize * hashSize, 0);
  for (int y = 0; y < hashSize; y++) {
    for (int x = 0; x < hashSize; x++) {
      lowFreq[y * hashSize + x] =
          coeffs[y * (imageSize ~/ hashSize) * imageSize +
              x * (imageSize ~/ hashSize)];
    }
  }

  final med = median(lowFreq);

  // Compute the hash: 1 if coefficient >= median, 0 otherwise
  final bits = lowFreq.fold<List<bool>>([], (acc, val) {
    acc.add(val >= med);
    return acc;
  });

  return ImageHash(bits);
}

/// Returns a linearized 2D array of wavelet coefficients
List<double> _haarWavelet2D(List<double> data, int size, int targetSize) {
  final result = List<double>.from(data);

  // Perform wavelet transform on rows
  for (int y = 0; y < size; y++) {
    final row = List<double>.filled(size, 0);
    for (int x = 0; x < size; x++) {
      row[x] = data[y * size + x];
    }

    final transformedRow = _haarWavelet1D(row, targetSize);

    for (int x = 0; x < size; x++) {
      result[y * size + x] = transformedRow[x];
    }
  }

  // Perform wavelet transform on columns
  for (int x = 0; x < size; x++) {
    final col = List<double>.filled(size, 0);
    for (int y = 0; y < size; y++) {
      col[y] = result[y * size + x];
    }

    final transformedCol = _haarWavelet1D(col, targetSize);

    for (int y = 0; y < size; y++) {
      result[y * size + x] = transformedCol[y];
    }
  }

  return result;
}

/// Performs a 1D Haar wavelet decomposition.
///
/// [data] The array of values
/// [targetSize] The desired length after decomposition
///
/// Returns an array of wavelet coefficients
List<double> _haarWavelet1D(List<double> data, int targetSize) {
  final result = List<double>.from(data);
  final half = data.length ~/ 2;

  for (int i = 0; i < half; i++) {
    final avg = (data[i * 2] + data[i * 2 + 1]) / 2;
    final diff = (data[i * 2] - data[i * 2 + 1]) / 2;

    result[i] = avg;
    result[i + half] = diff;
  }

  return result;
}
