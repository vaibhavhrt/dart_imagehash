// filepath: /Users/vaibhav/development/Photo Tidy AI/imagehash/lib/src/hash_base.dart
import 'package:image/image.dart';

/// Base class for image hash implementations
class ImageHash {
  /// The bit representation of the hash
  final List<bool> bits;
  
  /// The hash size (width and height)
  final int hashSize;

  /// Creates a new [ImageHash] with the given [bits] and [hashSize]
  const ImageHash(this.bits, this.hashSize);

  /// Creates a hash from a hexadecimal string representation
  factory ImageHash.fromHex(String hexStr, int hashSize) {
    // Each hex character represents 4 bits
    // The total number of bits should equal hashSize * hashSize
    if (hexStr.length * 4 != hashSize * hashSize) {
      throw ArgumentError('Hex string length does not match hash size: '
          'expected ${hashSize * hashSize} bits (${(hashSize * hashSize) ~/ 4} hex chars), '
          'got ${hexStr.length * 4} bits (${hexStr.length} hex chars)');
    }
    
    final bits = <bool>[];
    
    for (int i = 0; i < hexStr.length; i++) {
      final value = int.parse(hexStr[i], radix: 16);
      bits.add((value & 8) != 0);  // 8 = 2^3
      bits.add((value & 4) != 0);  // 4 = 2^2
      bits.add((value & 2) != 0);  // 2 = 2^1
      bits.add((value & 1) != 0);  // 1 = 2^0
    }
    
    return ImageHash(bits, hashSize);
  }

  /// Returns the hexadecimal string representation of this hash
  String toHex() {
    final hex = StringBuffer();
    
    for (int i = 0; i < bits.length; i += 4) {
      int value = 0;
      if (i < bits.length && bits[i]) value |= 8;
      if (i + 1 < bits.length && bits[i + 1]) value |= 4;
      if (i + 2 < bits.length && bits[i + 2]) value |= 2;
      if (i + 3 < bits.length && bits[i + 3]) value |= 1;
      hex.write(value.toRadixString(16));
    }
    
    return hex.toString();
  }

  /// Calculates the Hamming distance between this hash and [other]
  int distance(ImageHash other) {
    if (hashSize != other.hashSize) {
      throw ArgumentError('Hash sizes do not match');
    }
    
    int diff = 0;
    for (int i = 0; i < bits.length; i++) {
      if (bits[i] != other.bits[i]) {
        diff++;
      }
    }
    
    return diff;
  }

  /// Returns whether this hash is equal to [other]
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    if (other is ImageHash) {
      if (hashSize != other.hashSize) return false;
      
      for (int i = 0; i < bits.length; i++) {
        if (bits[i] != other.bits[i]) return false;
      }
      
      return true;
    }
    
    return false;
  }

  /// Returns the hash code for this object
  @override
  int get hashCode => Object.hash(hashSize, Object.hashAll(bits));

  /// Returns the string representation of this hash
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
    interpolation: Interpolation.average,
  );
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
