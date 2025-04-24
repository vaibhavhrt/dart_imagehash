import 'dart:typed_data';
import 'package:image/image.dart';

/// Decodes image bytes into an Image object
///
/// [bytes] The raw image bytes to decode
///
/// Returns the decoded Image object
///
/// Throws [FormatException] if the bytes cannot be decoded as an image
Image decodeImageBytes(Uint8List bytes) {
  final image = decodeImage(bytes);
  if (image == null) {
    throw FormatException('Could not decode image bytes');
  }
  return image;
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
