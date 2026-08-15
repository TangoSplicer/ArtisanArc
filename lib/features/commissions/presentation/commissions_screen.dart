import 'package:artisanarc/core/di/di.dart';
import 'package:artisanarc/core/utils/date_helpers.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:artisanarc/features/commissions/data/commission_model.dart';
import 'package:artisanarc/features/commissions/domain/commission_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommissionsScreen extends StatefulWidget {
  const CommissionsScreen({super.key});

  @override
  State<CommissionsScreen> createState() => _CommissionsScreenState();
}

class _CommissionsScreenState extends State<CommissionsScreen> {
  final _commissionService = getIt<CommissionService>();

  List<Commission> _commissions = const [];
  CommissionStatus? _statusFilter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCommissions();
  }

  Future<void> _loadCommissions() async {
    setState(() => _isLoading = true);
    try {
      final commissions = await _commissionService.getCommissions();
      if (mounted) setState(() => _commissions = commissions);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load commissions: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Commission> get _visibleCommissions => _statusFilter == null
      ? _commissions
      : _commissions.where((item) => item.status == _statusFilter).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PersonalAppBar(
        title: const Text('Commissions'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.pushNamed('addCommission').then((_) => _loadCommissions()),
        icon: const Icon(Icons.add),
        label: const Text('New order'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCommissions,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: theme.colorScheme.primaryContainer,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lock_outline),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Customer notes and order details stay only on this device. Share a summary only when you choose to.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Filter by status', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _statusFilter == null,
                        onSelected: (_) => setState(() => _statusFilter = null),
                      ),
                      ...CommissionStatus.values.map(
                        (status) => ChoiceChip(
                          label: Text(status.label),
                          selected: _statusFilter == status,
                          onSelected: (selected) => setState(
                            () => _statusFilter = selected ? status : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_visibleCommissions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.assignment_outlined, size: 52),
                            const SizedBox(height: 12),
                            Text(
                              _statusFilter == null
                                  ? 'No local commissions yet'
                                  : 'No ${_statusFilter!.label.toLowerCase()} commissions',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Add an enquiry or customer order to keep its due date, deposit and project together.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._visibleCommissions.map(
                      (commission) => Card(
                        child: InkWell(
                          onTap: () => context.pushNamed(
                            'commissionDetail',
                            pathParameters: {'id': commission.id},
                          ).then((_) => _loadCommissions()),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      _statusColor(commission.status, theme)
                                          .withOpacity(0.16),
                                  child: Icon(
                                    _statusIcon(commission.status),
                                    color:
                                        _statusColor(commission.status, theme),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              commission.customerName,
                                              style:
                                                  theme.textTheme.titleMedium,
                                            ),
                                          ),
                                          _statusChip(commission.status, theme),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        commission.linkedProjectName ??
                                            'No linked project',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        commission.dueDate == null
                                            ? 'Due date not set'
                                            : 'Due ${DateHelpers.formatForDisplay(commission.dueDate!)}',
                                        style: TextStyle(
                                          color: _isOverdue(commission)
                                              ? theme.colorScheme.error
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '£${commission.balanceDue.toStringAsFixed(2)}',
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    const Text('balance due'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _statusChip(CommissionStatus status, ThemeData theme) => Chip(
        visualDensity: VisualDensity.compact,
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
