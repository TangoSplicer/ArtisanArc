import 'package:flutter_test/flutter_test.dart';
import 'package:artisanarc/features/compliance/data/compliance_model.dart';

void main() {
  group('ComplianceTracker', () {
    test('create a new compliance entry', () {
      final entry = ComplianceEntry(
        id: 'c1',
        certification: 'UKCA',
        applicableCraft: 'Toys',
        dateCertified: DateTime.now(),
        notes: 'Initial certification',
      );
      expect(entry.certification, 'UKCA');
      expect(entry.applicableCraft, 'Toys');
    });

    test('filter compliance entries', () {
      final entry1 = ComplianceEntry(
        id: 'c1',
        certification: 'UKCA',
        applicableCraft: 'Toys',
        dateCertified: DateTime.now(),
      );
      final entry2 = ComplianceEntry(
        id: 'c2',
        certification: 'CE',
        applicableCraft: 'Jewelry',
        dateCertified: DateTime.now(),
      );
      
      final entries = [entry1, entry2];
      final filtered = entries.where((e) => e.certification == 'UKCA').toList();
      
      expect(filtered.length, 1);
      expect(filtered.first.id, 'c1');
    });
  });
}
