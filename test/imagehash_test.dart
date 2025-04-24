import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:image/image.dart' as img;

import 'package:dart_imagehash/dart_imagehash.dart';

void main() {
  // Create a simple test image
  img.Image createTestImage(
    int width,
    int height, {
    bool alternatePattern = false,
  }) {
    final image = img.Image(width: width, height: height);
    // Fill with a gradient pattern
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int r, g, b;
        if (alternatePattern) {
          // Create a different pattern for the second image
          r = (y * 255 ~/ height); // Switch x and y for r
          g = ((width - x) * 255 ~/ width); // Invert x for g
          b = ((x * y) * 255 ~/ (width * height)); // Multiply instead of add
        } else {
          r = (x * 255 ~/ width);
          g = (y * 255 ~/ height);
          b = ((x + y) * 255 ~/ (width + height));
        }
        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }
    return image;
  }

  // Create a slightly modified version of the image
  img.Image createModifiedImage(img.Image original) {
    final modified = img.copyResize(
      original,
      width: original.width,
      height: original.height,
    );
    // Add some noise
    for (int i = 0; i < 100; i++) {
      final x = (original.width * 0.5).toInt();
      final y = (original.height * 0.5).toInt();
      modified.setPixelRgba(x, y, 255, 0, 0, 255);
    }
    return modified;
  }

  // Create test images
  final original = createTestImage(100, 100);
  final modified = createModifiedImage(original);
  final different = createTestImage(
    100,
    100,
    alternatePattern: true,
  ); // Different pattern with alternate colors

  // Convert images to bytes for testing
  final originalBytes = Uint8List.fromList(img.encodePng(original));

  group('ImageHash base class tests', () {
    test('ImageHash equality', () {
      final hash1 = ImageHash([true, false, true, false]);
      final hash2 = ImageHash([true, false, true, false]);
      final hash3 = ImageHash([true, true, true, false]);

      expect(hash1 == hash2, true);
      expect(hash1 == hash3, false);
    });

    test('Hamming distance calculation', () {
      final hash1 = ImageHash([true, false, true, false]);
      final hash2 = ImageHash([true, false, false, false]);

      expect(hash1 - hash2, 1);
    });

    test('Hex string conversion', () {
      // For a hash with 16 bits total (4x4 grid), we need hashSize = 4
      final bits = [
        true,
        false,
        true,
        false,
        true,
        true,
        false,
        false,
        false,
        true,
        false,
        true,
        false,
        false,
        true,
        true,
      ];
      final hash = ImageHash(bits);
      final hex = hash.toHex();

      expect(hex, "ac53");

      final reconstructed = ImageHash.fromHex(hex);
      expect(reconstructed.bits, bits);
    });
  });

  group('Hash algorithm tests', () {
    test('Average Hash generates consistent results', () {
      final hash1 = ImageHasher.averageHash(original);
      final hash2 = ImageHasher.averageHash(original);

      expect(hash1 == hash2, true);
    });

    test('Average Hash detects similar images', () {
      final hash1 = ImageHasher.averageHash(original);
      final hash2 = ImageHasher.averageHash(modified);

      // The distance should be small for similar images
      expect(hash1 - hash2 < hash1.bits.length / 4, true);
    });

    test('Average Hash differentiates dissimilar images', () {
      final hash1 = ImageHasher.averageHash(original);
      final hash2 = ImageHasher.averageHash(different);

      // The distance should be larger for different images
      expect(hash1 - hash2 > hash1.bits.length / 4, true);
    });

    test('Average Hash from bytes matches image-based hash', () {
      final hashFromImage = ImageHasher.averageHash(original);
      final hashFromBytes = ImageHasher.averageHashFromBytes(originalBytes);

      expect(hashFromImage == hashFromBytes, true);
    });

    test('Perceptual Hash generates consistent results', () {
      final hash1 = ImageHasher.perceptualHash(original);
      final hash2 = ImageHasher.perceptualHash(original);

      expect(hash1 == hash2, true);
    });

    test('Perceptual Hash from bytes matches image-based hash', () {
      final hashFromImage = ImageHasher.perceptualHash(original);
      final hashFromBytes = ImageHasher.perceptualHashFromBytes(originalBytes);

      expect(hashFromImage == hashFromBytes, true);
    });

    test('Difference Hash generates consistent results', () {
      final hash1 = ImageHasher.differenceHash(original);
      final hash2 = ImageHasher.differenceHash(original);

      expect(hash1 == hash2, true);
    });

    test('Difference Hash from bytes matches image-based hash', () {
      final hashFromImage = ImageHasher.differenceHash(original);
      final hashFromBytes = ImageHasher.differenceHashFromBytes(originalBytes);

      expect(hashFromImage == hashFromBytes, true);
    });

    test('Vertical Difference Hash generates consistent results', () {
      final hash1 = ImageHasher.differenceHashVertical(original);
      final hash2 = ImageHasher.differenceHashVertical(original);

      expect(hash1 == hash2, true);
    });

    test('Vertical Difference Hash from bytes matches image-based hash', () {
      final hashFromImage = ImageHasher.differenceHashVertical(original);
      final hashFromBytes = ImageHasher.differenceHashVerticalFromBytes(
        originalBytes,
      );

      expect(hashFromImage == hashFromBytes, true);
    });

    test('Wavelet Hash generates consistent results', () {
      final hash1 = ImageHasher.waveletHash(original);
      final hash2 = ImageHasher.waveletHash(original);

      expect(hash1 == hash2, true);
    });

    test('Wavelet Hash from bytes matches image-based hash', () {
      final hashFromImage = ImageHasher.waveletHash(original);
      final hashFromBytes = ImageHasher.waveletHashFromBytes(originalBytes);

      expect(hashFromImage == hashFromBytes, true);
    });
  });
}
