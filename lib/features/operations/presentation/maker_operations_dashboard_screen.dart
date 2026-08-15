import 'package:artisanarc/core/di/di.dart';
import 'package:artisanarc/core/utils/date_helpers.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:artisanarc/features/operations/domain/maker_operations_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MakerOperationsDashboardScreen extends StatefulWidget {
  const MakerOperationsDashboardScreen({super.key});

  @override
  State<MakerOperationsDashboardScreen> createState() =>
      _MakerOperationsDashboardScreenState();
}

class _MakerOperationsDashboardScreenState
    extends State<MakerOperationsDashboardScreen> {
  final _operationsService = getIt<MakerOperationsService>();

  MakerOperationsSnapshot? _snapshot;
  SeasonalWorkflow _seasonalWorkflow = SeasonalWorkflow.allYear;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSnapshot();
  }

  Future<void> _loadSnapshot() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _operationsService.getSnapshot();
      if (mounted) setState(() => _snapshot = snapshot);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load maker operations: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snapshot = _snapshot;
    return Scaffold(
      appBar: PersonalAppBar(
        title: const Text('Maker Operations'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Refresh operations',
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadSnapshot,
          ),
        ],
      ),
      body: _isLoading && snapshot == null
          ? const Center(child: CircularProgressIndicator())
          : snapshot == null
              ? Center(
                  child: TextButton.icon(
                    onPressed: _loadSnapshot,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSnapshot,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSummary(snapshot, theme),
                      const SizedBox(height: 16),
                      _buildQuickActions(theme),
                      const SizedBox(height: 24),
                      Text('Act now', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      _buildUrgentQueue(snapshot, theme),
                      const SizedBox(height: 24),
                      Text('Upcoming local work',
                          style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      _buildUpcomingQueue(snapshot, theme),
                      const SizedBox(height: 24),
                      Text('Seasonal workflow',
                          style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      _buildSeasonalWorkflow(theme),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummary(MakerOperationsSnapshot snapshot, ThemeData theme) {
    final urgentColor = snapshot.urgentActionCount == 0
        ? Colors.green.shade700
        : theme.colorScheme.error;
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today’s maker view', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'A read-only local summary of stock, project, order, sales and stall data.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _metric(
                  Icons.priority_high_outlined,
                  '${snapshot.urgentActionCount} urgent',
                  urgentColor,
                ),
                _metric(
                  Icons.receipt_long_outlined,
                  '£${snapshot.salesThisWeek.toStringAsFixed(2)} this week',
                  theme.colorScheme.primary,
                ),
                _metric(
                  Icons.assignment_ind_outlined,
                  '${snapshot.openCommissionCount} open orders',
                  theme.colorScheme.secondary,
                ),
              ],
            ),
            if (snapshot.activeStall != null) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: () => context
                    .pushNamed('eventSales')
                    .then((_) => _loadSnapshot()),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.storefront_outlined,
                          color: theme.colorScheme.onSecondaryContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Active stall: ${snapshot.activeStall!.name}${snapshot.activeStall!.venue == null ? '' : ' · ${snapshot.activeStall!.venue}'}',
                          style: TextStyle(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color: theme.colorScheme.onSecondaryContainer),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _quickAction(
            icon: Icons.assignment_ind_outlined,
            label: 'New order',
            onPressed: () =>
                context.pushNamed('addCommission').then((_) => _loadSnapshot()),
          ),
          _quickAction(
            icon: Icons.storefront_outlined,
            label: 'Stall sale',
            onPressed: () =>
                context.pushNamed('eventSales').then((_) => _loadSnapshot()),
          ),
          _quickAction(
            icon: Icons.fact_check_outlined,
            label: 'Stocktake',
            onPressed: () =>
                context.pushNamed('stocktake').then((_) => _loadSnapshot()),
          ),
          _quickAction(
            icon: Icons.label_outline,
            label: 'Print labels',
            onPressed: () => context.pushNamed('labelEditor'),
          ),
        ],
      );

  Widget _buildUrgentQueue(MakerOperationsSnapshot snapshot, ThemeData theme) {
    final children = <Widget>[
      ...snapshot.overdueCommissions.map(
        (commission) => _actionTile(
          icon: Icons.assignment_late_outlined,
          color: theme.colorScheme.error,
          title: '${commission.customerName} · ${commission.status.label}',
          subtitle:
              'Order due ${DateHelpers.formatForDisplay(commission.dueDate!)} · £${commission.balanceDue.toStringAsFixed(2)} balance',
          onTap: () => context.pushNamed('commissionDetail', pathParameters: {
            'id': commission.id
          }).then((_) => _loadSnapshot()),
        ),
      ),
      ...snapshot.overdueProjects.map(
        (project) => _actionTile(
          icon: Icons.event_busy_outlined,
          color: theme.colorScheme.error,
          title: project.name,
          subtitle:
              'Project end date was ${DateHelpers.formatForDisplay(project.endDate!)}',
          onTap: () => context.pushNamed('projectDetail',
              pathParameters: {'id': project.id}).then((_) => _loadSnapshot()),
        ),
      ),
      ...snapshot.lowMaterials.map(
        (item) => _actionTile(
          icon: Icons.warning_amber_outlined,
          color: Colors.orange.shade800,
          title: item.name,
          subtitle:
              '${item.formattedStockQuantity} available · reorder at ${_formatThreshold(item)}',
          onTap: () => context.pushNamed('inventoryDetail',
              pathParameters: {'itemId': item.id}).then((_) => _loadSnapshot()),
        ),
      ),
    ];
    if (children.isEmpty) {
      return _emptyCard(
        theme,
        icon: Icons.check_circle_outline,
        message:
            'No overdue orders, overdue projects or low material alerts right now.',
      );
    }
    return Card(
      child: Column(children: children),
    );
  }

  Widget _buildUpcomingQueue(
      MakerOperationsSnapshot snapshot, ThemeData theme) {
    final children = <Widget>[
      ...snapshot.commissionsDueSoon.map(
        (commission) => _actionTile(
          icon: Icons.assignment_outlined,
          color: theme.colorScheme.secondary,
          title: '${commission.customerName} · ${commission.status.label}',
          subtitle:
              'Due ${DateHelpers.formatForDisplay(commission.dueDate!)} · £${commission.balanceDue.toStringAsFixed(2)} balance',
          onTap: () => context.pushNamed('commissionDetail', pathParameters: {
            'id': commission.id
          }).then((_) => _loadSnapshot()),
        ),
      ),
      ...snapshot.projectsDueSoon.map(
        (project) => _actionTile(
          icon: Icons.event_note_outlined,
          color: theme.colorScheme.primary,
          title: project.name,
          subtitle:
              'Project end date ${DateHelpers.formatForDisplay(project.endDate!)}',
          onTap: () => context.pushNamed('projectDetail',
              pathParameters: {'id': project.id}).then((_) => _loadSnapshot()),
        ),
      ),
    ];
    if (children.isEmpty) {
      return _emptyCard(
        theme,
        icon: Icons.calendar_month_outlined,
        message:
            'No local project or commission deadlines are due in the next 14 days.',
      );
    }
    return Card(child: Column(children: children));
  }

  Widget _buildSeasonalWorkflow(ThemeData theme) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SeasonalWorkflow.values
                    .map(
                      (workflow) => ChoiceChip(
                        label: Text(workflow.label),
                        selected: _seasonalWorkflow == workflow,
                        onSelected: (_) =>
                            setState(() => _seasonalWorkflow = workflow),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 14),
              Text(_seasonalWorkflow.idealWindow),
              const SizedBox(height: 12),
              ..._seasonalWorkflow.steps.asMap().entries.map(
                    (entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 15,
                        child: Text('${entry.key + 1}'),
                      ),
                      title: Text(entry.value.title),
                      subtitle: Text(entry.value.detail),
                    ),
                  ),
            ],
          ),
        ),
      );

  Widget _metric(IconData icon, String label, Color color) => Chip(
        avatar: Icon(icon, size: 18, color: color),
        label: Text(label),
        side: BorderSide(color: color.withOpacity(0.28)),
      );

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) =>
      OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );

  Widget _actionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      );

  Widget _emptyCard(ThemeData theme,
          {required IconData icon, required String message}) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, color: Colors.green.shade700),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );

  String _formatThreshold(dynamic item) {
    final threshold = item.activeReorderPoint;
    if (threshold == null) return 'default low-stock level';
    final value = threshold == threshold.roundToDouble()
        ? threshold.toStringAsFixed(0)
        : threshold.toString();
    return item.usesMeasuredQuantity ? '$value ${item.measurementUnit}' : value;
  }
}
