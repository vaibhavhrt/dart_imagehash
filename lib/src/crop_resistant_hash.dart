// filepath: /Users/vaibhav/development/Photo Tidy AI/imagehash/lib/src/crop_resistant_hash.dart
import 'dart:math';
import 'package:image/image.dart';
import 'hash_base.dart';
import 'perceptual_hash.dart';

/// Computes a crop-resistant hash of an image.
///
/// This hash is designed to be more resistant to cropping operations by:
/// 1. Dividing the image into a grid of cells
/// 2. Computing a perceptual hash for each cell
/// 3. Combining the cell hashes into a single hash
///
/// [image] The image to hash
/// [hashSize] The size of each individual cell hash
/// [gridSize] The number of cells in the grid (e.g., 2 = 2x2 grid)
///
/// Returns an [ImageHash] object containing the combined hash
ImageHash cropResistantHash(
  Image image, 
  {int hashSize = 8, 
   int gridSize = 2}
) {
  // Calculate the total size of the hash (gridSize squared * hashSize squared bits)
  final totalHashSize = hashSize * gridSize;
  
  // Calculate the cell size (width and height)
  final cellWidth = image.width ~/ gridSize;
  final cellHeight = image.height ~/ gridSize;
  
  // All bits from all cells
  final allBits = <bool>[];
  
  // For each cell in the grid
  for (int gridY = 0; gridY < gridSize; gridY++) {
    for (int gridX = 0; gridX < gridSize; gridX++) {
      // Extract the cell from the image
      final cell = copyCrop(
        image,
        x: gridX * cellWidth,
        y: gridY * cellHeight,
        width: cellWidth,
        height: cellHeight,
      );
      
      // Compute a perceptual hash for the cell
      final cellHash = perceptualHash(cell, hashSize: hashSize);
      
      // Add the cell's bits to the overall hash
      allBits.addAll(cellHash.bits);
    }
  }
  
  return ImageHash(allBits, totalHashSize);
}

/// A more advanced crop-resistant hash that uses feature points.
///
/// This is a simplified version inspired by the Python implementation.
/// For a more robust implementation, you would need to implement or use
/// a feature detection algorithm like SIFT, SURF, or ORB.
///
/// [image] The image to hash
/// [hashSize] The size of each individual segment hash
/// [segments] The number of segments to extract
///
/// Returns an [ImageHash] object containing the combined hash
ImageHash cropResistantSegmentedHash(
  Image image, 
  {int hashSize = 8, 
   int segments = 4}
) {
  // Resize the image to a reasonable size for feature extraction
  final processedImage = copyResize(
    image,
    width: 512,
    height: (512 * image.height / image.width).round(),
    interpolation: Interpolation.cubic,
  );
  
  // Convert to grayscale for feature detection
  final grayImage = grayscale(processedImage);
  
  // Detect edges (simplified edge detection using Sobel filter)
  final edgeImage = sobelFilter(grayImage);
  
  // Find high energy points (simplified feature detection)
  final featurePoints = _findFeaturePoints(edgeImage, segments);
  
  // Extract segments around feature points
  final allBits = <bool>[];
  final segmentSize = min(grayImage.width, grayImage.height) ~/ 4;
  
  for (final point in featurePoints) {
    // Ensure the segment is fully within the image
    final x = min(max(point.x - segmentSize ~/ 2, 0), grayImage.width - segmentSize);
    final y = min(max(point.y - segmentSize ~/ 2, 0), grayImage.height - segmentSize);
    
    // Extract the segment
    final segment = copyCrop(
      grayImage,
      x: x,
      y: y,
      width: segmentSize,
      height: segmentSize,
    );
    
    // Compute a perceptual hash for the segment
    final segmentHash = perceptualHash(segment, hashSize: hashSize);
    
    // Add the segment's bits to the overall hash
    allBits.addAll(segmentHash.bits);
  }
  
  return ImageHash(allBits, hashSize * segments);
}

/// Applies a simple Sobel filter for edge detection.
///
/// [image] The grayscale image to process
///
/// Returns an image with edges highlighted
Image sobelFilter(Image image) {
  final result = Image(width: image.width, height: image.height);
  
  // Define Sobel kernels
  final sobelX = [
    [-1, 0, 1],
    [-2, 0, 2],
    [-1, 0, 1]
  ];
  
  final sobelY = [
    [-1, -2, -1],
    [0, 0, 0],
    [1, 2, 1]
  ];
  
  // Apply the filter (skip border pixels)
  for (int y = 1; y < image.height - 1; y++) {
    for (int x = 1; x < image.width - 1; x++) {
      double gx = 0;
      double gy = 0;
      
      // Apply kernels
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          final pixel = image.getPixel(x + kx, y + ky);
          gx += pixel.r * sobelX[ky + 1][kx + 1];
          gy += pixel.r * sobelY[ky + 1][kx + 1];
        }
      }
      
      // Calculate gradient magnitude
      final magnitude = sqrt(gx * gx + gy * gy).round();
      final clampedMagnitude = min(255, max(0, magnitude));
      
      // Set the pixel in the result image
      result.setPixelRgba(x, y, clampedMagnitude, clampedMagnitude, clampedMagnitude, 255);
    }
  }
  
  return result;
}

/// A simple point class for feature detection
class _Point {
  final int x;
  final int y;
  final double energy;
  
  _Point(this.x, this.y, this.energy);
}

/// Finds high-energy feature points in an image.
///
/// This is a simplified method that looks for high-contrast areas.
/// [image] The edge-detected image
/// [count] The number of feature points to find
///
/// Returns a list of feature points
List<_Point> _findFeaturePoints(Image image, int count) {
  final points = <_Point>[];
  
  // Compute the energy at each pixel (using a sliding window)
  final windowSize = 16;
  
  for (int y = windowSize; y < image.height - windowSize; y += windowSize) {
    for (int x = windowSize; x < image.width - windowSize; x += windowSize) {
      double energy = 0;
      
      // Sum up the pixel values in the window (higher values = more edges)
      for (int wy = -windowSize ~/ 2; wy < windowSize ~/ 2; wy++) {
        for (int wx = -windowSize ~/ 2; wx < windowSize ~/ 2; wx++) {
          final pixel = image.getPixel(x + wx, y + wy);
          energy += pixel.r;
        }
      }
      
      points.add(_Point(x, y, energy));
    }
  }
  
  // Sort by energy (highest first)
  points.sort((a, b) => b.energy.compareTo(a.energy));
  
  // Return the top [count] points
  return points.take(count).toList();
}
