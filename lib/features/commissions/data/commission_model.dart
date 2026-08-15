import 'package:hive/hive.dart';

part 'commission_model.g.dart';

/// A private, on-device customer order. Contact details remain in the local
/// Hive data store and are only included in a summary when the maker chooses
/// to share it.
@HiveType(typeId: 13)
class Commission extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerName;

  @HiveField(2)
  final String? contactNote;

  @HiveField(3)
  final double totalAmount;

  @HiveField(4)
  final double depositAmount;

  @HiveField(5)
  final DateTime? dueDate;

  @HiveField(6)
  final String? linkedProjectId;

  @HiveField(7)
  final String? linkedProjectName;

  @HiveField(8)
  final CommissionStatus status;

  @HiveField(9)
  final String? notes;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  Commission({
    required this.id,
    required this.customerName,
    this.contactNote,
    required this.totalAmount,
    this.depositAmount = 0,
    this.dueDate,
    this.linkedProjectId,
    this.linkedProjectName,
    this.status = CommissionStatus.enquiry,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  double get balanceDue =>
      (totalAmount - depositAmount).clamp(0, double.infinity).toDouble();

  bool get isOpen => !status.isTerminal;

  Commission copyWith({
    String? id,
    String? customerName,
    String? contactNote,
    bool clearContactNote = false,
    double? totalAmount,
    double? depositAmount,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? linkedProjectId,
    String? linkedProjectName,
    bool clearLinkedProject = false,
    CommissionStatus? status,
    String? notes,
    bool clearNotes = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Commission(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      contactNote: clearContactNote ? null : contactNote ?? this.contactNote,
      totalAmount: totalAmount ?? this.totalAmount,
      depositAmount: depositAmount ?? this.depositAmount,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      linkedProjectId:
          clearLinkedProject ? null : linkedProjectId ?? this.linkedProjectId,
      linkedProjectName: clearLinkedProject
          ? null
          : linkedProjectName ?? this.linkedProjectName,
      status: status ?? this.status,
      notes: clearNotes ? null : notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: 14)
enum CommissionStatus {
  @HiveField(0)
  enquiry,
  @HiveField(1)
  confirmed,
  @HiveField(2)
  inProgress,
  @HiveField(3)
  ready,
  @HiveField(4)
  delivered,
  @HiveField(5)
  cancelled;

  String get label {
    switch (this) {
      case CommissionStatus.enquiry:
        return 'Enquiry';
      case CommissionStatus.confirmed:
        return 'Confirmed';
      case CommissionStatus.inProgress:
        return 'In progress';
      case CommissionStatus.ready:
        return 'Ready';
      case CommissionStatus.delivered:
        return 'Delivered';
      case CommissionStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isTerminal =>
      this == CommissionStatus.delivered || this == CommissionStatus.cancelled;
}
