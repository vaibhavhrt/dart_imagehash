/// A library for perceptual image hashing in Dart.
///
/// This library provides functionality to calculate various image hashes
/// including Average hash (aHash), Perceptual hash (pHash), Difference hash (dHash),
/// Wavelet hash (wHash).
///
/// Example:
/// ```dart
/// import 'package:imagehash/imagehash.dart';
/// import 'package:image/image.dart' as img;
///
/// // Calculate average hash from an image
/// var image = img.decodeImage(File('test.png').readAsBytesSync());
/// var hash = ImageHasher.averageHash(image!);
/// print(hash);
///
/// // Calculate perceptual hash
/// var phash = ImageHasher.perceptualHash(image);
/// print(phash);
///
/// // Compare two hashes
/// var otherHash = ImageHasher.averageHash(img.decodeImage(File('other.png').readAsBytesSync())!);
/// print(hash == otherHash); // Boolean comparison
/// print(hash - otherHash); // Hamming distance
///
/// // Calculate hash directly from bytes
/// var bytes = File('test.png').readAsBytesSync();
/// var hashFromBytes = ImageHasher.averageHashFromBytes(bytes);
/// print(hashFromBytes);
/// ```

library;

export 'src/image_hasher.dart' show ImageHasher, ImageHash;
