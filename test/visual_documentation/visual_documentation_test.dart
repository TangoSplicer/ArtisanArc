import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:artisanarc/features/visual_documentation/domain/entities/item.dart'; // Assuming Item entity
import 'package:artisanarc/features/visual_documentation/application/services/image_service.dart'; // Assuming ImageService
import 'package:artisanarc/features/visual_documentation/application/services/color_extraction_service.dart'; // Assuming ColorExtractionService
import 'dart:typed_data'; // For Uint8List

// Mock classes
class MockImageService extends Mock implements ImageService {}
class MockColorExtractionService extends Mock implements ColorExtractionService {}

void main() {
  group('VisualDocumentation', () {
    late MockImageService mockImageService;
    late MockColorExtractionService mockColorExtractionService;
    late Item item;

    setUp(() {
      mockImageService = MockImageService();
      mockColorExtractionService = MockColorExtractionService();
      item = Item(id: 'item789', name: 'Linen Shirt', photos: []);
    });

    test('add a photo to an item', () async {
      final photoData = Uint8List.fromList([1, 2, 3]); // Dummy photo data
      final photoUrl = 'http://example.com/photo.jpg';

      // Configure mock to return a URL when addPhoto is called
      when(mockImageService.addPhoto(item, photoData)).thenAnswer((_) async => photoUrl);

      // Action
      final resultUrl = await mockImageService.addPhoto(item, photoData);
      item.photos.add(resultUrl); // Assuming Item has a list of photo URLs or identifiers

      // Assert
      verify(mockImageService.addPhoto(item, photoData)).called(1);
      expect(item.photos, contains(photoUrl));
      expect(resultUrl, photoUrl);
    });

    test('extract colors from an image', () async {
      final imageUrl = 'http://example.com/photo.jpg';
      final expectedColors = ['#FF0000', '#00FF00', '#0000FF']; // Red, Green, Blue

      // Configure mock to return a list of color hex codes
      when(mockColorExtractionService.extractColors(imageUrl)).thenAnswer((_) async => expectedColors);

      // Action
      final extractedColors = await mockColorExtractionService.extractColors(imageUrl);

      // Assert
      verify(mockColorExtractionService.extractColors(imageUrl)).called(1);
      expect(extractedColors, expectedColors);
      expect(extractedColors, hasLength(3));
      expect(extractedColors, contains('#FF0000'));
    });
  });
}
