import 'package:artisanarc/features/commissions/data/commission_model.dart';
import 'package:artisanarc/features/commissions/data/commission_repository.dart';
import 'package:artisanarc/features/commissions/domain/commission_service.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryCommissionRepository implements CommissionRepository {
  final Map<String, Commission> _records = {};

  @override
  Future<void> deleteCommission(String id) async => _records.remove(id);

  @override
  Future<Commission?> getCommissionById(String id) async => _records[id];

  @override
  Future<List<Commission>> getCommissions() async => _records.values.toList();

  @override
  Future<void> saveCommission(Commission commission) async {
    _records[commission.id] = commission;
  }
}

void main() {
  late CommissionService service;

  setUp(() {
    service = CommissionService(MemoryCommissionRepository());
  });

  test('calculates the remaining balance from local total and deposit',
      () async {
    final commission = await service.saveCommission(
      customerName: 'Alex Taylor',
      totalAmount: 48,
      depositAmount: 15.50,
      dueDate: DateTime(2026, 9, 1),
    );

    expect(commission.balanceDue, 32.50);
    expect(commission.status, CommissionStatus.enquiry);
  });

  test('rejects a deposit larger than the local order total', () async {
    await expectLater(
      service.saveCommission(
        customerName: 'Alex Taylor',
        totalAmount: 20,
        depositAmount: 21,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('allows only the intended commission lifecycle transitions', () async {
    final enquiry = await service.saveCommission(
      customerName: 'Alex Taylor',
      totalAmount: 40,
    );

    final confirmed =
        await service.changeStatus(enquiry, CommissionStatus.confirmed);
    final inProgress =
        await service.changeStatus(confirmed, CommissionStatus.inProgress);
    final ready =
        await service.changeStatus(inProgress, CommissionStatus.ready);
    final delivered =
        await service.changeStatus(ready, CommissionStatus.delivered);

    expect(delivered.status, CommissionStatus.delivered);
    expect(service.nextStatusesFor(delivered), isEmpty);
    await expectLater(
      service.changeStatus(enquiry, CommissionStatus.ready),
      throwsA(isA<StateError>()),
    );
  });

  test('keeps private customer details in the deliberate share summary',
      () async {
    final commission = await service.saveCommission(
      customerName: 'Alex Taylor',
      contactNote: 'Collection message preferred',
      totalAmount: 36,
      depositAmount: 12,
      linkedProjectName: 'Granny Square Market Tote',
    );

    final summary = service.buildShareSummary(commission);
    expect(summary, contains('Alex Taylor'));
    expect(summary, contains('Balance due: £24.00'));
    expect(summary, contains('Granny Square Market Tote'));
  });
}
