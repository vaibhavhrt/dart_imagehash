// filepath: /Users/vaibhav/development/Photo Tidy AI/imagehash/lib/src/wavelet_hash.dart
import 'package:image/image.dart';
import 'hash_base.dart';

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
  Image image, 
  {int hashSize = 8, 
   String mode = 'haar', 
   int scale = 4}
) {
  if (mode != 'haar') {
    throw ArgumentError('Only haar wavelet mode is supported');
  }
  
  // Size of the resized image
  final imageSize = hashSize * scale;
  
  // Convert to grayscale and resize
  final smallImage = resizeForHash(
    grayscale(image),
    width: imageSize,
    height: imageSize
  );
  
  // Extract pixel values to double array
  final pixels = List<double>.filled(imageSize * imageSize, 0);
  int idx = 0;
  for (int y = 0; y < imageSize; y++) {
    for (int x = 0; x < imageSize; x++) {
      final pixel = smallImage.getPixel(x, y);
      pixels[idx++] = pixel.r.toDouble();
    }
  }
  
  // Apply Haar wavelet decomposition
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
      lowFreq[y * hashSize + x] = coeffs[y * (imageSize ~/ hashSize) * imageSize + x * (imageSize ~/ hashSize)];
    }
  }
  
  // Compute the median value of the coefficients
  final med = median(lowFreq);
  
  // Compute the hash: 1 if coefficient >= median, 0 otherwise
  final bits = <bool>[];
  for (int i = 0; i < lowFreq.length; i++) {
    bits.add(lowFreq[i] >= med);
  }
  
  return ImageHash(bits);
}

/// Performs a 2D Haar wavelet decomposition on a square image.
///
/// [data] The linearized 2D array of pixel values
/// [size] The current width/height of the square image
/// [targetSize] The desired width/height after decomposition
///
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
  
  // Compute averages and differences
  for (int i = 0; i < half; i++) {
    final avg = (data[i * 2] + data[i * 2 + 1]) / 2;
    final diff = (data[i * 2] - data[i * 2 + 1]) / 2;
    
    result[i] = avg;
    result[i + half] = diff;
  }
  
  return result;
}
