import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../data/pattern_model.dart';
import '../data/pattern_repository.dart';

class RowCounterWidget extends StatefulWidget {
  const RowCounterWidget({super.key, this.projectId, this.initialCounterId});

  final String? projectId;
  final String? initialCounterId;

  @override
  State<RowCounterWidget> createState() => _RowCounterWidgetState();
}

class _RowCounterWidgetState extends State<RowCounterWidget> {
  final PatternRepository _repository = GetIt.I<PatternRepository>();
  List<RowCounter> _counters = [];
  RowCounter? _activeCounter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounters();
  }

  Future<void> _loadCounters() async {
    final counters = await _repository.getRowCounters();
    if (!mounted) return;
    setState(() {
      _counters = counters;
      if (widget.initialCounterId != null) {
        _activeCounter = counters.firstWhere(
          (c) => c.id == widget.initialCounterId,
          orElse: () => counters.isNotEmpty
              ? counters.first
              : RowCounter(
                  id: const Uuid().v4(),
                  title: 'Main Project Counter',
                  count: 0,
                  linkedProjectId: widget.projectId,
                  updatedAt: DateTime.now(),
                ),
        );
      } else if (_counters.isNotEmpty) {
        _activeCounter = _counters.first;
      } else {
        _activeCounter = RowCounter(
          id: const Uuid().v4(),
          title: 'Project Row Counter',
          count: 0,
          linkedProjectId: widget.projectId,
          updatedAt: DateTime.now(),
        );
        _repository.saveRowCounter(_activeCounter!);
        _counters = [_activeCounter!];
      }
      _isLoading = false;
    });
  }

  Future<void> _updateCount(int delta) async {
    if (_activeCounter == null) return;
    HapticFeedback.mediumImpact();
    final newCount = (_activeCounter!.count + delta).clamp(0, 99999);
    final updated = _activeCounter!.copyWith(
      count: newCount,
      updatedAt: DateTime.now(),
    );
    await _repository.saveRowCounter(updated);
    setState(() {
      _activeCounter = updated;
      final idx = _counters.indexWhere((c) => c.id == updated.id);
      if (idx >= 0) _counters[idx] = updated;
    });
  }

  Future<void> _resetCounter() async {
    if (_activeCounter == null) return;
    HapticFeedback.heavyImpact();
    final updated = _activeCounter!.copyWith(
      count: 0,
      updatedAt: DateTime.now(),
    );
    await _repository.saveRowCounter(updated);
    setState(() {
      _activeCounter = updated;
      final idx = _counters.indexWhere((c) => c.id == updated.id);
      if (idx >= 0) _counters[idx] = updated;
    });
  }

  Future<void> _createNewCounter() async {
    final titleController =
        TextEditingController(text: 'Round / Section Counter');
    final targetController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Row Counter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                  labelText: 'Counter Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Target Rows (optional)',
                  border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Create')),
        ],
      ),
    );
    if (confirmed != true) return;
    final newCounter = RowCounter(
      id: const Uuid().v4(),
      title: titleController.text.trim().isEmpty
          ? 'Counter'
          : titleController.text.trim(),
      count: 0,
      targetCount: int.tryParse(targetController.text.trim()),
      linkedProjectId: widget.projectId,
      updatedAt: DateTime.now(),
    );
    await _repository.saveRowCounter(newCounter);
    await _loadCounters();
    setState(() => _activeCounter = newCounter);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButton<RowCounter>(
                    value: _activeCounter,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: _counters
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _activeCounter = val);
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'New Counter',
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _createNewCounter,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              _activeCounter?.count.toString() ?? '0',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            if (_activeCounter?.targetCount != null &&
                _activeCounter!.targetCount! > 0)
              Text(
                'Target: ${_activeCounter!.targetCount} rows',
                style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _updateCount(-1),
                  icon: const Icon(Icons.remove),
                  label: const Text('Minus 1'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () => _updateCount(1),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Row'),
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _resetCounter,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reset Counter'),
              style: TextButton.styleFrom(foregroundColor: colors.error),
            ),
          ],
        ),
      ),
    );
  }
}
