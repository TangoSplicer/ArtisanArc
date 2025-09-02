import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageService {
  static Future<List<Color>> extractDominantColors(String imagePath, {int colorCount = 5}) async {
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return [];
      }

      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return [];

      // Resize image for faster processing
      final resized = img.copyResize(image, width: 150);
      
      // Extract pixel colors
      final Map<int, int> colorCounts = {};
      
      for (int y = 0; y < resized.height; y++) {
        for (int x = 0; x < resized.width; x++) {
          final pixel = resized.getPixel(x, y);
          final color = img.getColor(pixel);
          
          // Skip very dark or very light colors
          final brightness = (color.r + color.g + color.b) / 3;
          if (brightness < 30 || brightness > 225) continue;
          
          final colorKey = (color.r << 16) | (color.g << 8) | color.b;
          colorCounts[colorKey] = (colorCounts[colorKey] ?? 0) + 1;
        }
      }

      // Sort by frequency and take top colors
      final sortedColors = colorCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedColors
          .take(colorCount)
          .map((entry) {
            final colorValue = entry.key;
            final r = (colorValue >> 16) & 0xFF;
            final g = (colorValue >> 8) & 0xFF;
            final b = colorValue & 0xFF;
            return Color.fromARGB(255, r, g, b);
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<String> compressAndSaveImage(String originalPath, String targetDirectory) async {
    try {
      final originalFile = File(originalPath);
      final bytes = await originalFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) throw Exception('Could not decode image');

      // Resize if too large
      final resized = image.width > 1024 || image.height > 1024
          ? img.copyResize(image, width: 1024)
          : image;

      // Compress as JPEG with 85% quality
      final compressedBytes = img.encodeJpg(resized, quality: 85);
      
      // Save to target directory
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetPath = p.join(targetDirectory, fileName);
      final targetFile = File(targetPath);
      
      await targetFile.writeAsBytes(compressedBytes);
      return fileName;
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  static Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Silently fail - image might already be deleted
    }
  }

  static Future<String> getImagePath(String fileName, String folder) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return p.join(appDocDir.path, folder, fileName);
  }
}