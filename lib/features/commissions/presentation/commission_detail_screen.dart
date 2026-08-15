import 'package:artisanarc/core/di/di.dart';
import 'package:artisanarc/core/utils/date_helpers.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:artisanarc/features/commissions/data/commission_model.dart';
import 'package:artisanarc/features/commissions/domain/commission_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class CommissionDetailScreen extends StatefulWidget {
  const CommissionDetailScreen({super.key, required this.commissionId});

  final String commissionId;

  @override
  State<CommissionDetailScreen> createState() => _CommissionDetailScreenState();
}

class _CommissionDetailScreenState extends State<CommissionDetailScreen> {
  final _commissionService = getIt<CommissionService>();

  Commission? _commission;
  bool _isLoading = true;
  bool _isChangingStatus = false;

  @override
  void initState() {
    super.initState();
    _loadCommission();
  }

  Future<void> _loadCommission() async {
    setState(() => _isLoading = true);
    try {
      final commission =
          await _commissionService.getCommissionById(widget.commissionId);
      if (mounted) setState(() => _commission = commission);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load commission: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changeStatus(CommissionStatus status) async {
    final commission = _commission;
    if (commission == null) return;
    setState(() => _isChangingStatus = true);
    try {
      final updated = await _commissionService.changeStatus(commission, status);
      if (mounted) {
        setState(() => _commission = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Commission marked ${status.label.toLowerCase()}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not change status: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isChangingStatus = false);
    }
  }

  Future<void> _shareSummary() async {
    final commission = _commission;
    if (commission == null) return;
    await Share.share(
      _commissionService.buildShareSummary(commission),
      subject: '${commission.customerName} commission summary',
    );
  }

  Future<void> _confirmDelete() async {
    final commission = _commission;
    if (commission == null) return;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete local commission?'),
        content: Text(
          'Delete the local order for ${commission.customerName}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    await _commissionService.deleteCommission(commission.id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final commission = _commission;
    if (commission == null) {
      return Scaffold(
        appBar: PersonalAppBar(title: const Text('Commission not found')),
        body: const Center(
          child: Text('This local commission could not be found.'),
        ),
      );
    }

    final theme = Theme.of(context);
    final nextStatuses = _commissionService.nextStatusesFor(commission);
    return Scaffold(
      appBar: PersonalAppBar(
        title: const Text('Commission'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Share summary',
            icon: const Icon(Icons.ios_share_outlined),
            onPressed: _shareSummary,
          ),
          IconButton(
            tooltip: 'Edit order',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.pushNamed(
              'editCommission',
              pathParameters: {'id': commission.id},
            ).then((_) => _loadCommission()),
          ),
          PopupMenuButton<String>(
            tooltip: 'More options',
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete') _confirmDelete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline),
                  title: Text('Delete local order'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCommission,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            commission.customerName,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                        _statusChip(commission.status, theme),
                      ],
                    ),
                    if (commission.contactNote != null) ...[
                      const SizedBox(height: 8),
                      Text('Contact: ${commission.contactNote}'),
                    ],
                    const SizedBox(height: 20),
                    _amountRow('Order total', commission.totalAmount),
                    _amountRow('Deposit paid', commission.depositAmount),
                    const Divider(height: 24),
                    _amountRow('Balance due', commission.balanceDue,
                        emphasized: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order details', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 14),
                    _detailRow(
                      context,
                      icon: Icons.calendar_today_outlined,
                      label: 'Due date',
                      value: commission.dueDate == null
                          ? 'Not set'
                          : DateHelpers.formatForDisplay(commission.dueDate!),
                      valueColor: _isOverdue(commission)
                          ? theme.colorScheme.error
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _detailRow(
                      context,
                      icon: Icons.design_services_outlined,
                      label: 'Linked project',
                      value: commission.linkedProjectName ?? 'Not linked',
                      onTap: commission.linkedProjectId == null
                          ? null
                          : () => context.push(
                                '/projects/detail/${commission.linkedProjectId}',
                              ),
                    ),
                    if (commission.notes != null) ...[
                      const SizedBox(height: 12),
                      _detailRow(
                        context,
                        icon: Icons.note_alt_outlined,
                        label: 'Private order note',
                        value: commission.notes!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: theme.colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lock_outline),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'This is a private local record. Sharing sends only the text summary you explicitly choose to share.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (nextStatuses.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Update status', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: nextStatuses
                    .map(
                      (status) => FilledButton.icon(
                        onPressed: _isChangingStatus
                            ? null
                            : () => _changeStatus(status),
                        icon: _isChangingStatus
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(_statusIcon(status)),
                        label: Text('Mark ${status.label}'),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _amountRow(String label, double amount, {bool emphasized = false}) =>
      Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            '£${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: emphasized ? 18 : null,
              fontWeight: emphasized ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      );

  Widget _detailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    VoidCallback? onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 2),
                    Text(value, style: TextStyle(color: valueColor)),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      );

  Widget _statusChip(CommissionStatus status, ThemeData theme) => Chip(
        label: Text(status.label),
        labelStyle: TextStyle(color: _statusColor(status, theme)),
        backgroundColor: _statusColor(status, theme).withOpacity(0.12),
        side: BorderSide(color: _statusColor(status, theme).withOpacity(0.3)),
      );

  bool _isOverdue(Commission commission) =>
      commission.isOpen &&
      commission.dueDate != null &&
      DateHelpers.isOverdue(commission.dueDate!);

  Color _statusColor(CommissionStatus status, ThemeData theme) {
    switch (status) {
      case CommissionStatus.enquiry:
        return theme.colorScheme.secondary;
      case CommissionStatus.confirmed:
        return Colors.indigo;
      case CommissionStatus.inProgress:
        return Colors.deepOrange;
      case CommissionStatus.ready:
        return Colors.green.shade700;
      case CommissionStatus.delivered:
        return theme.colorScheme.primary;
      case CommissionStatus.cancelled:
        return theme.colorScheme.error;
    }
  }

  IconData _statusIcon(CommissionStatus status) {
    switch (status) {
      case CommissionStatus.enquiry:
        return Icons.chat_bubble_outline;
      case CommissionStatus.confirmed:
        return Icons.event_available_outlined;
      case CommissionStatus.inProgress:
        return Icons.handyman_outlined;
      case CommissionStatus.ready:
        return Icons.inventory_2_outlined;
      case CommissionStatus.delivered:
        return Icons.task_alt_outlined;
      case CommissionStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}
