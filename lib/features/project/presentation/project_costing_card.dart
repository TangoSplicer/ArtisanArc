import 'package:artisanarc/core/di/di.dart';
import 'package:artisanarc/features/project/data/project_model.dart';
import 'package:artisanarc/features/project/domain/project_costing_service.dart';
import 'package:artisanarc/features/project/domain/usecases/update_project.dart';
import 'package:flutter/material.dart';

class ProjectCostingCard extends StatefulWidget {
  const ProjectCostingCard({
    super.key,
    required this.project,
    required this.onProjectUpdated,
  });

  final Project project;
  final ValueChanged<Project> onProjectUpdated;

  @override
  State<ProjectCostingCard> createState() => _ProjectCostingCardState();
}

class _ProjectCostingCardState extends State<ProjectCostingCard> {
  final _costingService = getIt<ProjectCostingService>();
  final _updateProject = getIt<UpdateProject>();

  ProjectCostingPreview? _preview;
  Object? _loadError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  @override
  void didUpdateWidget(covariant ProjectCostingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.id != widget.project.id ||
        oldWidget.project.lastUpdatedAt != widget.project.lastUpdatedAt) {
      _loadPreview();
    }
  }

  Future<void> _loadPreview() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final preview = await _costingService.preview(widget.project);
      if (mounted) setState(() => _preview = preview);
    } catch (error) {
      if (mounted) setState(() => _loadError = error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openInputsDialog() async {
    final labourMinutes = TextEditingController(
      text: widget.project.estimatedLabourMinutes?.toString() ?? '',
    );
    final labourRate = TextEditingController(
      text: widget.project.labourRatePerHour?.toStringAsFixed(2) ?? '',
    );
    final targetMargin = TextEditingController(
      text: widget.project.targetMarginPercent?.toStringAsFixed(0) ?? '',
    );
    String? validationError;
    var isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Cost & Price inputs'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'These values create a planning estimate only. Completed makes retain their recorded historical material cost.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: labourMinutes,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Estimated labour (minutes, optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: labourRate,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Your hourly rate (optional)',
                      prefixText: '£ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: targetMargin,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Target margin (optional)',
                      suffixText: '%',
                      helperText: 'Profit as a percentage of sale price.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (validationError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      validationError!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  isSaving ? null : () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final minutesText = labourMinutes.text.trim();
                      final rateText = labourRate.text.trim();
                      final marginText = targetMargin.text.trim();
                      final minutes = minutesText.isEmpty
                          ? null
                          : int.tryParse(minutesText);
                      final rate =
                          rateText.isEmpty ? null : double.tryParse(rateText);
                      final margin = marginText.isEmpty
                          ? null
                          : double.tryParse(marginText);
                      final error = _inputsError(minutes, rate, margin);
                      if (error != null) {
                        setDialogState(() => validationError = error);
                        return;
                      }

                      setDialogState(() {
                        isSaving = true;
                        validationError = null;
                      });
                      try {
                        final updated = widget.project.copyWith(
                          estimatedLabourMinutes: minutes,
                          clearEstimatedLabourMinutes: minutes == null,
                          labourRatePerHour: rate,
                          clearLabourRatePerHour: rate == null,
                          targetMarginPercent: margin,
                          clearTargetMarginPercent: margin == null,
                          lastUpdatedAt: DateTime.now(),
                        );
                        await _updateProject(updated);
                        if (!dialogContext.mounted) return;
                        Navigator.of(dialogContext).pop();
                        widget.onProjectUpdated(updated);
                        await _loadPreview();
                      } catch (error) {
                        setDialogState(() {
                          isSaving = false;
                          validationError =
                              'Could not save cost inputs: $error';
                        });
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
    labourMinutes.dispose();
    labourRate.dispose();
    targetMargin.dispose();
  }

  String? _inputsError(int? minutes, double? rate, double? margin) {
    if (minutes != null && minutes < 0) {
      return 'Labour minutes cannot be negative.';
    }
    if (rate != null && (!rate.isFinite || rate < 0)) {
      return 'Hourly rate must be zero or greater.';
    }
    if (margin != null && (!margin.isFinite || margin < 0 || margin >= 100)) {
      return 'Target margin must be from 0% up to (but not including) 100%.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading && _preview == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_loadError != null || _preview == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cost & Price', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('The local estimate could not be loaded.'),
              TextButton.icon(
                onPressed: _loadPreview,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final preview = _preview!;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child:
                      Text('Cost & Price', style: theme.textTheme.titleLarge),
                ),
                IconButton(
                  tooltip: 'Edit cost inputs',
                  onPressed: _openInputsDialog,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Planning estimate — current material prices and your optional labour inputs. It does not alter completed-make history.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _moneyRow('Estimated materials', preview.estimatedMaterialCost),
            _moneyRow('Estimated labour', preview.estimatedLabourCost),
            const Divider(height: 24),
            _moneyRow('Estimated direct cost', preview.estimatedDirectCost,
                emphasized: true),
            const SizedBox(height: 8),
            if (preview.suggestedSalePrice != null)
              _moneyRow(
                'Suggested sale price (${preview.project.targetMarginPercent!.toStringAsFixed(0)}% margin)',
                preview.suggestedSalePrice!,
                emphasized: true,
              )
            else
              Text(
                'Set a target margin to calculate a suggested sale price.',
                style: theme.textTheme.bodyMedium,
              ),
            if (preview.missingCostCount > 0) ...[
              const SizedBox(height: 10),
              Text(
                '${preview.missingCostCount} linked supply ${preview.missingCostCount == 1 ? 'has' : 'have'} no compatible unit cost, so the estimate may be understated.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const Divider(height: 28),
            Text('Recorded making time', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            if (!preview.hasRecordedTime)
              const Text(
                'Start the project timer to see the actual time cost and a truthful per-item price floor.',
              )
            else ...[
              _textRow(
                'Actual time',
                _formatMinutes(preview.recordedActualLabourMinutes),
              ),
              _moneyRow('Actual time cost', preview.actualLabourCost),
              _moneyRow(
                'Current price floor per item',
                preview.actualPriceFloorPerItem,
                emphasized: true,
              ),
              if (preview.actualSuggestedSalePricePerItem != null)
                _moneyRow(
                  'Actual-time target price per item',
                  preview.actualSuggestedSalePricePerItem!,
                  emphasized: true,
                )
              else
                const Text(
                  'Set an hourly rate and target margin to calculate an actual-time target price.',
                ),
            ],
            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Material estimate sources'),
              subtitle: const Text(
                  'Planner estimate takes priority over purchase history.'),
              children: preview.supplyLines
                  .map(
                    (line) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${_formatQuantity(line.supplyNeed.quantityNeeded)} ${line.supplyNeed.unit} · ${line.supplyNeed.itemName}',
                      ),
                      subtitle: Text(line.sourceLabel),
                      trailing: Text(
                        line.totalCost == null ? '—' : _money(line.totalCost!),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: line.totalCost == null
                              ? theme.colorScheme.error
                              : null,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const Divider(height: 28),
            Text('Recorded production cost',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            if (preview.recordedRunCount == 0)
              const Text(
                'No completed make has been recorded yet. Historical costs appear here after a make is completed.',
              )
            else ...[
              Text(
                'Historical material cost captured at the time of ${preview.recordedRunCount} completed ${preview.recordedRunCount == 1 ? 'make' : 'makes'}.',
              ),
              const SizedBox(height: 8),
              _moneyRow(
                  'Recorded materials', preview.recordedProductionMaterialCost),
              _moneyRow(
                'Recorded cost per finished item',
                preview.recordedMaterialCostPerItem ?? 0,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _textRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      );

  Widget _moneyRow(String label, double value, {bool emphasized = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            _money(value),
            style: TextStyle(
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _money(double value) => '£${value.toStringAsFixed(2)}';

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours == 0) return '$remainder min';
    if (remainder == 0) return '$hours h';
    return '$hours h $remainder min';
  }

  String _formatQuantity(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}
