import 'package:flutter_test/flutter_test.dart';
import 'package:textile_management/features/compliance_tracker/domain/entities/item.dart';
import 'package:textile_management/features/compliance_tracker/domain/entities/safety_certification.dart';

void main() {
  group('ComplianceTracker', () {
    test('mark an item with a safety certification', () {
      final item = Item(
        id: 'item1',
        name: 'Organic Cotton T-Shirt',
        certifications: [],
      );
      final certification = SafetyCertification(
        id: 'cert1',
        name: 'GOTS',
        issuingBody: 'Global Organic Textile Standard',
        validityDate: DateTime.now().add(Duration(days: 365)),
      );
      item.certifications.add(certification);
      expect(item.certifications, isNotEmpty);
      expect(item.certifications.first.name, 'GOTS');
    });

    test('filter items by safety certification', () {
      final item1 = Item(
        id: 'item1',
        name: 'Organic Cotton T-Shirt',
        certifications: [
          SafetyCertification(
            id: 'cert1',
            name: 'GOTS',
            issuingBody: 'Global Organic Textile Standard',
            validityDate: DateTime.now().add(Duration(days: 365)),
          ),
        ],
      );
      final item2 = Item(
        id: 'item2',
        name: 'Recycled Polyester Jacket',
        certifications: [
          SafetyCertification(
            id: 'cert2',
            name: 'GRS',
            issuingBody: 'Global Recycled Standard',
            validityDate: DateTime.now().add(Duration(days: 365)),
          ),
        ],
      );
      final item3 = Item(
        id: 'item3',
        name: 'Conventional Cotton Jeans',
        certifications: [],
      );

      final allItems = [item1, item2, item3];
      final gotsCertifiedItems = allItems
          .where((item) => item.certifications.any((cert) => cert.name == 'GOTS'))
          .toList();

      expect(gotsCertifiedItems.length, 1);
      expect(gotsCertifiedItems.first.name, 'Organic Cotton T-Shirt');
    });
  });
}
