import 'package:artisanarc/core/di/di.dart';
import 'package:artisanarc/core/utils/date_helpers.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:artisanarc/core/widgets/searchable_selection_field.dart';
import 'package:artisanarc/features/commissions/data/commission_model.dart';
import 'package:artisanarc/features/commissions/domain/commission_service.dart';
import 'package:artisanarc/features/project/data/project_model.dart';
import 'package:artisanarc/features/project/data/project_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommissionEditorScreen extends StatefulWidget {
  const CommissionEditorScreen({super.key, this.commissionId});

  final String? commissionId;

  bool get isEditing => commissionId != null;

  @override
  State<CommissionEditorScreen> createState() => _CommissionEditorScreenState();
}

class _CommissionEditorScreenState extends State<CommissionEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commissionService = getIt<CommissionService>();
  final _projectRepository = getIt<ProjectRepository>();
  final _customerController = TextEditingController();
  final _contactController = TextEditingController();
  final _totalController = TextEditingController();
  final _depositController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  Commission? _commission;
  List<Project> _projects = const [];
  Project? _selectedProject;
  DateTime? _dueDate;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final projects = await _projectRepository.getAllProjects();
      projects
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      final commission = widget.commissionId == null
          ? null
          : await _commissionService.getCommissionById(widget.commissionId!);
      if (!mounted) return;
      if (commission != null) {
        _customerController.text = commission.customerName;
        _contactController.text = commission.contactNote ?? '';
        _totalController.text = commission.totalAmount.toStringAsFixed(2);
        _depositController.text = commission.depositAmount.toStringAsFixed(2);
        _notesController.text = commission.notes ?? '';
        _dueDate = commission.dueDate;
        _selectedProject = projects
            .where((project) => project.id == commission.linkedProjectId)
            .firstOrNull;
      }
      setState(() {
        _projects = projects;
        _commission = commission;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load commission form: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDueDate() async {
    final initial = _dueDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final total = double.tryParse(_totalController.text.trim());
    final deposit = double.tryParse(_depositController.text.trim());
    if (total == null || deposit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter valid amounts for total and deposit.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _commissionService.saveCommission(
        id: _commission?.id,
        customerName: _customerController.text,
        contactNote: _contactController.text,
        totalAmount: total,
        depositAmount: deposit,
        dueDate: _dueDate,
        linkedProjectId: _selectedProject?.id,
        linkedProjectName: _selectedProject?.name,
        status: _commission?.status ?? CommissionStatus.enquiry,
        notes: _notesController.text,
        createdAt: _commission?.createdAt,
      );
      if (mounted) context.pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save commission: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _contactController.dispose();
    _totalController.dispose();
    _depositController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (widget.isEditing && _commission == null) {
      return Scaffold(
        appBar: PersonalAppBar(title: const Text('Commission not found')),
        body: const Center(
            child: Text('This local commission could not be found.')),
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: PersonalAppBar(
        title: Text(widget.isEditing ? 'Edit commission' : 'New commission'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Form(
        key: _formKey,
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
                        'Customer information is stored only on this device. Keep contact notes brief and share an order summary only when needed.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Customer', style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            TextFormField(
              controller: _customerController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Customer name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a customer name.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: 'Contact note (optional)',
                hintText: 'For example: preferred collection message',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Text('Order & payment', style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            TextFormField(
              controller: _totalController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Order total',
                prefixText: '£ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null || amount < 0) {
                  return 'Enter a total of zero or more.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _depositController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Deposit paid',
                prefixText: '£ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final deposit = double.tryParse(value?.trim() ?? '');
                final total = double.tryParse(_totalController.text.trim());
                if (deposit == null || deposit < 0) {
                  return 'Enter a deposit of zero or more.';
                }
                if (total != null && deposit > total) {
                  return 'Deposit cannot exceed the order total.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text('Plan', style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            SearchableSelectionField<Project>(
              options: _projects,
              value: _selectedProject,
              labelText: 'Linked project (optional)',
              hintText: 'Search a project',
              emptyMessage:
                  'Create a project first, or leave this order unlinked.',
              itemLabel: (project) => project.name,
              itemSubtitle: (project) => project.craftType,
              searchTerms: (project) => [
                project.name,
                project.craftType ?? '',
                project.description ?? '',
              ],
              allowClear: true,
              onChanged: (project) =>
                  setState(() => _selectedProject = project),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDueDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                _dueDate == null
                    ? 'Set due date'
                    : 'Due ${DateHelpers.formatForDisplay(_dueDate!)}',
              ),
            ),
            if (_dueDate != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _dueDate = null),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear due date'),
                ),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Private order note (optional)',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
            ),
            if (_commission != null) ...[
              const SizedBox(height: 16),
              Text(
                'Status: ${_commission!.status.label}. Change the status from the order detail screen.',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isSaving ? 'Saving…' : 'Save local order'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
