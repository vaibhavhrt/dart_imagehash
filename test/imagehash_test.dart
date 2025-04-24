import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:image/image.dart' as img;

import 'package:dart_imagehash/dart_imagehash.dart';

// Create a simple test image
img.Image createTestImage(
  int width,
  int height, {
  bool alternatePattern = false,
}) {
  final image = img.Image(width: width, height: height);
  // Fill with a pattern that will be more distinct between original and different
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int r, g, b;
      if (alternatePattern) {
        // Create a completely different pattern for the second image
        r = ((y % 8) < 4) ? 255 : 0; // Horizontal stripes
        g = r;
        b = r;
      } else {
        // Original pattern - vertical stripes
        r = ((x % 8) < 4) ? 255 : 0; // Vertical stripes
        g = r;
        b = r;
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
  // Add small modifications that shouldn't affect the hash too much
  for (int y = 0; y < modified.height; y++) {
    for (int x = 0; x < modified.width; x++) {
      if ((x + y) % 32 == 0) {
        // Reduced frequency of modifications
        final pixel = modified.getPixel(x, y);
        modified.setPixelRgba(
          x,
          y,
          (pixel.r + 10).clamp(0, 255), // Reduced intensity of changes
          (pixel.g + 10).clamp(0, 255),
          (pixel.b + 10).clamp(0, 255),
          255,
        );
      }
    }
  }
  return modified;
}

void main() {
  late img.Image original;
  late img.Image modified;
  late img.Image different;
  late Uint8List originalBytes;

  setUp(() {
    // Create test images
    original = createTestImage(100, 100);
    modified = createModifiedImage(original);
    different = createTestImage(100, 100, alternatePattern: true);
    originalBytes = Uint8List.fromList(img.encodePng(original));
  });

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
    // Similarity thresholds (percentage of total bits)
    final similarityThreshold = 0.35; // 35% different for similar images
    final dissimilarityThreshold = 0.35; // 35% different for dissimilar images

    test('Average Hash generates consistent results', () {
      final hash1 = ImageHasher.averageHash(original);
      final hash2 = ImageHasher.averageHash(original);

      expect(hash1 == hash2, true);
    });

    test('Average Hash detects similar images', () {
      final hash1 = ImageHasher.averageHash(original);
      final hash2 = ImageHasher.averageHash(modified);

      final distance = hash1 - hash2;
      final threshold = hash1.bits.length * similarityThreshold;
      expect(distance < threshold, true);
    });

    test('Average Hash differentiates dissimilar images', () {
      final hash1 = ImageHasher.averageHash(original);
      final hash2 = ImageHasher.averageHash(different);

      final distance = hash1 - hash2;
      final threshold = hash1.bits.length * dissimilarityThreshold;
      expect(distance > threshold, true);
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

    test('Perceptual Hash detects similar images', () {
      final hash1 = ImageHasher.perceptualHash(original);
      final hash2 = ImageHasher.perceptualHash(modified);

      final distance = hash1 - hash2;
      final threshold = hash1.bits.length * similarityThreshold;
      expect(distance < threshold, true);
    });

    test('Perceptual Hash differentiates dissimilar images', () {
      final hash1 = ImageHasher.perceptualHash(original);
      final hash2 = ImageHasher.perceptualHash(different);

      final distance = hash1 - hash2;
      final threshold = hash1.bits.length * dissimilarityThreshold;
      expect(distance > threshold, true);
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

    test('Difference Hash detects similar images', () {
      final hash1 = ImageHasher.differenceHash(original);
      final hash2 = ImageHasher.differenceHash(modified);

      final distance = hash1 - hash2;
      final threshold = hash1.bits.length * similarityThreshold;
      expect(distance < threshold, true);
    });

    test('Difference Hash differentiates dissimilar images', () {
      final hash1 = ImageHasher.differenceHash(original);
      final hash2 = ImageHasher.differenceHash(different);

      final distance = hash1 - hash2;
      final threshold = hash1.bits.length * dissimilarityThreshold;
      expect(distance > threshold, true);
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

    test('Vertical Difference Hash detects similar images', () {
      final hash1 = ImageHasher.differenceHashVertical(original);
      final hash2 = ImageHasher.differenceHashVertical(modified);

      final distance = hash1 - hash2;
      final threshold = hash1.bits.length * similarityThreshold;
      expect(distance < threshold, true);
    });

    test('Vertical Difference Hash differentiates dissimilar images', () {
      final hash1 = ImageHasher.differenceHashVertical(original);
      final hash2 = ImageHasher.differenceHashVertical(different);

      final distance = hash1 - hash2;
      final threshold = hash1.bits.length * dissimilarityThreshold;
      expect(distance > threshold, true);
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

    test('Wavelet Hash detects similar images', () {
      final hash1 = ImageHasher.waveletHash(original);
      final hash2 = ImageHasher.waveletHash(modified);

      final distance = hash1 - hash2;
      final threshold = hash1.bits.length * similarityThreshold;
      expect(distance < threshold, true);
    });

    test('Wavelet Hash differentiates dissimilar images', () {
      final hash1 = ImageHasher.waveletHash(original);
      final hash2 = ImageHasher.waveletHash(different);

      final distance = hash1 - hash2;
      final threshold = hash1.bits.length * dissimilarityThreshold;
      expect(distance > threshold, true);
    });

    test('Wavelet Hash from bytes matches image-based hash', () {
      final hashFromImage = ImageHasher.waveletHash(original);
      final hashFromBytes = ImageHasher.waveletHashFromBytes(originalBytes);

      expect(hashFromImage == hashFromBytes, true);
    });
  });
}
