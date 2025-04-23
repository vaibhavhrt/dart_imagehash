import 'dart:math';
import 'package:collection/collection.dart';
import 'package:image/image.dart';

/// Base class for image hash implementations
class ImageHash {
  /// The bit representation of the hash
  final List<bool> bits;

  /// Creates a new [ImageHash] with the given [bits]
  const ImageHash(this.bits);

  /// The total number of bits in the hash.
  int get length => bits.length;

  /// Creates a hash from a hexadecimal string representation.
  /// Assumes the hash represents a square image (hashSize x hashSize).
  factory ImageHash.fromHex(String hexStr) {
    final totalBits = hexStr.length * 4;
    final hashSide = sqrt(totalBits);

    if (hashSide != hashSide.floor()) {
      throw ArgumentError(
        'Hex string length ($hexStr.length chars, $totalBits bits) '
        'does not represent a square hash.',
      );
    }

    final bits = <bool>[];
    for (int i = 0; i < hexStr.length; i++) {
      final value = int.parse(hexStr[i], radix: 16);
      bits.add((value & 8) != 0); // 1000
      bits.add((value & 4) != 0); // 0100
      bits.add((value & 2) != 0); // 0010
      bits.add((value & 1) != 0); // 0001
    }

    if (bits.length != totalBits) {
      throw ArgumentError(
        'Parsed bits length (${bits.length}) does not match expected length ($totalBits) from hex string.',
      );
    }

    return ImageHash(bits);
  }

  /// Returns the hexadecimal string representation of this hash
  String toHex() {
    final buffer = StringBuffer();
    for (int i = 0; i < bits.length; i += 4) {
      int value = 0;
      if (bits[i]) value += 8; // 2^3
      if (i + 1 < bits.length && bits[i + 1]) value += 4; // 2^2
      if (i + 2 < bits.length && bits[i + 2]) value += 2; // 2^1
      if (i + 3 < bits.length && bits[i + 3]) value += 1; // 2^0
      buffer.write(value.toRadixString(16));
    }
    // Calculate expected hex length (ceil division)
    final expectedLength = (bits.length + 3) ~/ 4;
    // Pad with leading zeros if necessary
    return buffer.toString().padLeft(expectedLength, '0');
  }

  /// Calculates the Hamming distance between this hash and [other]
  /// using the subtraction operator.
  int operator -(ImageHash other) {
    if (length != other.length) {
      throw ArgumentError(
        'ImageHashes must be of the same length: '
        '$length vs ${other.length}',
      );
    }

    return Iterable<int>.generate(length).fold<int>(
      0,
      (previousValue, index) =>
          previousValue + (bits[index] != other.bits[index] ? 1 : 0),
    );
  }

  /// Returns whether this hash is equal to [other]
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageHash &&
        length == other.length &&
        const ListEquality().equals(bits, other.bits);
  }

  /// Returns the hash code for this object
  @override
  int get hashCode => Object.hash(Object.hashAll(bits), bits.length); // Include length for better distribution

  /// Returns the string representation of this hash (hexadecimal)
  @override
  String toString() => toHex();
}

/// Utility function to resize an image to the specified dimensions
///
/// [width] and [height] specify the exact dimensions to resize to
Image resizeForHash(Image image, {required int width, required int height}) {
  return copyResize(
    image,
    width: width,
    height: height,
    interpolation: Interpolation.cubic,
  );
}

/// Extracts pixel values from an image into a list of doubles
///
/// [image] The image to extract pixel values from
///
/// Returns a list of pixel values as doubles
List<double> extractPixelValues(Image image) {
  final List<double> pixels = [];

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      pixels.add(pixel.r.toDouble());
    }
  }
  return pixels;
}

/// Calculates the median value of an array
num median(List<num> values) {
  if (values.isEmpty) {
    throw ArgumentError('Cannot compute median of empty list');
  }

  final sorted = List<num>.from(values)..sort();
  final middle = sorted.length ~/ 2;

  if (sorted.length % 2 == 1) {
    return sorted[middle];
  } else {
    return (sorted[middle - 1] + sorted[middle]) / 2;
  }
}
