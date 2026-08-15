import 'package:uuid/uuid.dart';

import '../data/commission_model.dart';
import '../data/commission_repository.dart';

class CommissionService {
  CommissionService(this._repository);

  final CommissionRepository _repository;
  final Uuid _uuid = const Uuid();

  Future<List<Commission>> getCommissions() => _repository.getCommissions();

  Future<Commission?> getCommissionById(String id) =>
      _repository.getCommissionById(id);

  Future<Commission> saveCommission({
    String? id,
    required String customerName,
    String? contactNote,
    required double totalAmount,
    double depositAmount = 0,
    DateTime? dueDate,
    String? linkedProjectId,
    String? linkedProjectName,
    CommissionStatus status = CommissionStatus.enquiry,
    String? notes,
    DateTime? createdAt,
  }) async {
    final cleanName = customerName.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError.value(
          customerName, 'customerName', 'A customer name is required.');
    }
    _validateAmounts(totalAmount, depositAmount);

    final now = DateTime.now();
    final commission = Commission(
      id: id ?? _uuid.v4(),
      customerName: cleanName,
      contactNote: _cleanOptional(contactNote),
      totalAmount: totalAmount,
      depositAmount: depositAmount,
      dueDate: dueDate,
      linkedProjectId: _cleanOptional(linkedProjectId),
      linkedProjectName: _cleanOptional(linkedProjectName),
      status: status,
      notes: _cleanOptional(notes),
      createdAt: createdAt ?? now,
      updatedAt: now,
    );
    await _repository.saveCommission(commission);
    return commission;
  }

  Future<Commission> changeStatus(
    Commission commission,
    CommissionStatus nextStatus,
  ) async {
    if (commission.status == nextStatus) return commission;
    if (!_allowedTransitions[commission.status]!.contains(nextStatus)) {
      throw StateError(
        'A ${commission.status.label.toLowerCase()} commission cannot move directly to ${nextStatus.label.toLowerCase()}.',
      );
    }
    final updated = commission.copyWith(
      status: nextStatus,
      updatedAt: DateTime.now(),
    );
    await _repository.saveCommission(updated);
    return updated;
  }

  Future<void> deleteCommission(String id) => _repository.deleteCommission(id);

  String buildShareSummary(Commission commission) {
    final due = commission.dueDate == null
        ? 'Not set'
        : _formatDate(commission.dueDate!);
    final project = commission.linkedProjectName?.trim().isNotEmpty == true
        ? commission.linkedProjectName!
        : 'Not linked';
    final contact = commission.contactNote?.trim().isNotEmpty == true
        ? '\nContact: ${commission.contactNote}'
        : '';
    final notes = commission.notes?.trim().isNotEmpty == true
        ? '\nNotes: ${commission.notes}'
        : '';

    return '''ArtisanArc Personal — Commission summary
Customer: ${commission.customerName}$contact
Status: ${commission.status.label}
Project: $project
Due: $due
Order total: ${_formatMoney(commission.totalAmount)}
Deposit paid: ${_formatMoney(commission.depositAmount)}
Balance due: ${_formatMoney(commission.balanceDue)}$notes

This summary was created from a private, offline ArtisanArc record.''';
  }

  List<CommissionStatus> nextStatusesFor(Commission commission) =>
      List.unmodifiable(_allowedTransitions[commission.status]!);

  void _validateAmounts(double totalAmount, double depositAmount) {
    if (!totalAmount.isFinite || totalAmount < 0) {
      throw ArgumentError.value(
          totalAmount, 'totalAmount', 'Order total cannot be negative.');
    }
    if (!depositAmount.isFinite || depositAmount < 0) {
      throw ArgumentError.value(
          depositAmount, 'depositAmount', 'Deposit cannot be negative.');
    }
    if (depositAmount > totalAmount) {
      throw ArgumentError.value(depositAmount, 'depositAmount',
          'Deposit cannot exceed the order total.');
    }
  }

  String? _cleanOptional(String? value) {
    final clean = value?.trim();
    return clean == null || clean.isEmpty ? null : clean;
  }

  String _formatMoney(double value) => '£${value.toStringAsFixed(2)}';

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

const Map<CommissionStatus, List<CommissionStatus>> _allowedTransitions = {
  CommissionStatus.enquiry: [
    CommissionStatus.confirmed,
    CommissionStatus.cancelled,
  ],
  CommissionStatus.confirmed: [
    CommissionStatus.inProgress,
    CommissionStatus.cancelled,
  ],
  CommissionStatus.inProgress: [
    CommissionStatus.ready,
    CommissionStatus.cancelled,
  ],
  CommissionStatus.ready: [
    CommissionStatus.delivered,
    CommissionStatus.cancelled,
  ],
  CommissionStatus.delivered: [],
  CommissionStatus.cancelled: [],
};
