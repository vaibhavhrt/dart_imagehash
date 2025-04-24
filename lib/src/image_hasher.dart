import 'dart:math';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:image/image.dart';
import 'average_hash.dart' as ah;
import 'perceptual_hash.dart' as ph;
import 'difference_hash.dart' as dh;
import 'wavelet_hash.dart' as wh;
import 'image_utils.dart';

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

/// A utility class that provides static methods to calculate various types of image hashes.
///
/// This class encapsulates all the different hash calculation methods
/// and provides a unified interface for working with image hashes.
/// All methods are static and can be used without creating an instance.
class ImageHasher {
  /// Private constructor to prevent instantiation
  const ImageHasher._();

  /// Decodes image bytes into an Image object
  ///
  /// [bytes] The raw image bytes to decode
  ///
  /// Returns the decoded Image object
  ///
  /// Throws [FormatException] if the bytes cannot be decoded as an image
  static Image _decodeImageBytes(Uint8List bytes) {
    return decodeImageBytes(bytes);
  }

  /// Calculate average hash from an image
  ///
  /// [image] The image to calculate hash from
  /// [hashSize] The size of the hash (default: 8)
  static ImageHash averageHash(Image image, {int hashSize = 8}) {
    return ah.averageHash(image, hashSize: hashSize);
  }

  /// Calculate average hash from image bytes
  ///
  /// [bytes] The image bytes to calculate hash from
  /// [hashSize] The size of the hash (default: 8)
  static ImageHash averageHashFromBytes(Uint8List bytes, {int hashSize = 8}) {
    return averageHash(_decodeImageBytes(bytes), hashSize: hashSize);
  }

  /// Calculate perceptual hash from an image
  ///
  /// [image] The image to calculate hash from
  /// [hashSize] The size of the hash (default: 8)
  static ImageHash perceptualHash(Image image, {int hashSize = 8}) {
    return ph.perceptualHash(image, hashSize: hashSize);
  }

  /// Calculate perceptual hash from image bytes
  ///
  /// [bytes] The image bytes to calculate hash from
  /// [hashSize] The size of the hash (default: 8)
  static ImageHash perceptualHashFromBytes(
    Uint8List bytes, {
    int hashSize = 8,
  }) {
    return perceptualHash(_decodeImageBytes(bytes), hashSize: hashSize);
  }

  /// Calculate difference hash from an image
  ///
  /// [image] The image to calculate hash from
  /// [hashSize] The size of the hash (default: 8)
  /// [horizontal] Whether to calculate horizontal difference (default: true)
  static ImageHash differenceHash(
    Image image, {
    int hashSize = 8,
    bool horizontal = true,
  }) {
    return dh.differenceHash(image, hashSize: hashSize, horizontal: horizontal);
  }

  /// Calculate difference hash from image bytes
  ///
  /// [bytes] The image bytes to calculate hash from
  /// [hashSize] The size of the hash (default: 8)
  /// [horizontal] Whether to calculate horizontal difference (default: true)
  static ImageHash differenceHashFromBytes(
    Uint8List bytes, {
    int hashSize = 8,
    bool horizontal = true,
  }) {
    return differenceHash(
      _decodeImageBytes(bytes),
      hashSize: hashSize,
      horizontal: horizontal,
    );
  }

  /// Calculate vertical difference hash from an image
  ///
  /// [image] The image to calculate hash from
  /// [hashSize] The size of the hash (default: 8)
  static ImageHash differenceHashVertical(Image image, {int hashSize = 8}) {
    return dh.differenceHashVertical(image, hashSize: hashSize);
  }

  /// Calculate vertical difference hash from image bytes
  ///
  /// [bytes] The image bytes to calculate hash from
  /// [hashSize] The size of the hash (default: 8)
  static ImageHash differenceHashVerticalFromBytes(
    Uint8List bytes, {
    int hashSize = 8,
  }) {
    return differenceHashVertical(_decodeImageBytes(bytes), hashSize: hashSize);
  }

  /// Calculate wavelet hash from an image
  ///
  /// [image] The image to calculate hash from
  /// [hashSize] The size of the hash (default: 8)
  static ImageHash waveletHash(Image image, {int hashSize = 8}) {
    return wh.waveletHash(image, hashSize: hashSize);
  }

  /// Calculate wavelet hash from image bytes
  ///
  /// [bytes] The image bytes to calculate hash from
  /// [hashSize] The size of the hash (default: 8)
  static ImageHash waveletHashFromBytes(Uint8List bytes, {int hashSize = 8}) {
    return waveletHash(_decodeImageBytes(bytes), hashSize: hashSize);
  }
}
