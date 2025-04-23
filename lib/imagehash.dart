/// A library for perceptual image hashing in Dart.
/// 
/// This library provides functionality to calculate various image hashes
/// including Average hash (aHash), Perceptual hash (pHash), Difference hash (dHash),
/// Wavelet hash (wHash), Color hash, and Crop-resistant hash.
/// 
/// Example:
/// ```dart
/// import 'package:imagehash/imagehash.dart';
/// import 'package:image/image.dart' as img;
/// 
/// // Load an image
/// var image = img.decodeImage(File('test.png').readAsBytesSync());
/// 
/// // Calculate average hash
/// var hash = averageHash(image!);
/// print(hash);
/// 
/// // Calculate perceptual hash
/// var phash = perceptualHash(image);
/// print(phash);
/// 
/// // Compare two hashes
/// var otherHash = averageHash(img.decodeImage(File('other.png').readAsBytesSync())!);
/// print(hash == otherHash); // Boolean comparison
/// print(hash.distance(otherHash)); // Hamming distance
/// ```

library;

export 'src/hash_base.dart';
export 'src/average_hash.dart';
export 'src/perceptual_hash.dart';
export 'src/difference_hash.dart';
export 'src/wavelet_hash.dart';
export 'src/color_hash.dart';
export 'src/crop_resistant_hash.dart';
