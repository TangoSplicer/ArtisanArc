import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:uuid/uuid.dart';
import 'package:artisanarc/core/constants/compliance_tags.dart';
import 'package:artisanarc/features/compliance/data/compliance_model.dart';
import 'package:artisanarc/features/compliance/domain/compliance_service.dart';

class ComplianceScreen extends StatefulWidget {
  const ComplianceScreen({super.key});

  @override
  State<ComplianceScreen> createState() => _ComplianceScreenState();
}

class _ComplianceScreenState extends State<ComplianceScreen> {
  final ComplianceService _service = GetIt.I<ComplianceService>();
  final _formKey = GlobalKey<FormState>();
  List<ComplianceEntry> _entries = [];

  ComplianceTag? _selectedTag;
  final _craftController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _dateCertified = DateTime.now();

  String? _editingEntryId; // To store ID of item being edited

  @override
  void initState() {
    super.initState();
    _loadCertifications();
  }

  Future<void> _loadCertifications() async {
    final entries = await _service.fetchCertifications();
    if (mounted) {
      setState(() => _entries = entries);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _selectedTag = null;
      _craftController.clear();
      _notesController.clear();
      _dateCertified = DateTime.now();
      _editingEntryId = null;
    });
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTag == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a certification.')),
        );
        return;
      }

      final entry = ComplianceEntry(
        id: _editingEntryId ?? const Uuid().v4(),
        certification: _selectedTag!.name,
        applicableCraft: _craftController.text,
        dateCertified: _dateCertified,
        notes: _notesController.text,
      );

      try {
        if (_editingEntryId != null) {
          await _service.updateCertification(entry);
          if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Certification updated!')));
        } else {
          await _service.recordCertification(entry);
           if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Certification added!')));
        }
        _resetForm();
        _loadCertifications();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving certification: $e')),
          );
        }
      }
    }
  }

  void _handleEdit(ComplianceEntry entry) {
    setState(() {
      _editingEntryId = entry.id;
      _selectedTag = predefinedComplianceTags.firstWhere((tag) => tag.name == entry.certification, orElse: () => predefinedComplianceTags.first);
      _craftController.text = entry.applicableCraft;
      _dateCertified = entry.dateCertified;
      _notesController.text = entry.notes ?? '';
    });
  }

  void _handleDelete(String entryId) async {
     final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this certification entry?'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(dialogContext).pop(false)),
          TextButton(child: const Text('Delete'), style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error), onPressed: () => Navigator.of(dialogContext).pop(true)),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteCertification(entryId);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Certification deleted.')));
        _loadCertifications();
         if (_editingEntryId == entryId) { // If the deleted item was being edited, reset form
          _resetForm();
        }
      } catch (e) {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
         }
      }
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateCertified,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)), // Allow future dates for upcoming certs
    );
    if (picked != null && picked != _dateCertified) {
      setState(() {
        _dateCertified = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingEntryId != null ? 'Edit Compliance Entry' : 'Compliance Tracker'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputForm(theme),
            const SizedBox(height: 16),
            const Divider(),
            Text('Recorded Certifications', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(child: _buildCertificationsList(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<ComplianceTag>(
            value: _selectedTag,
            decoration: const InputDecoration(labelText: 'Certification*', border: OutlineInputBorder()),
            items: predefinedComplianceTags.map((ComplianceTag tag) {
              return DropdownMenuItem<ComplianceTag>(
                value: tag,
                child: Text(tag.name, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (ComplianceTag? newValue) {
              setState(() {
                _selectedTag = newValue;
                if (newValue != null) {
                  _craftController.text = newValue.applicableCraft.join(', ');
                } else {
                  _craftController.clear();
                }
              });
            },
            validator: (value) => value == null ? 'Please select a certification' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _craftController,
            decoration: const InputDecoration(labelText: 'Applicable Craft(s)*', border: OutlineInputBorder()),
            validator: (value) => (value == null || value.isEmpty) ? 'Please enter applicable craft(s)' : null,
          ),
          const SizedBox(height: 12),
           ListTile(
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0), side: BorderSide(color: theme.colorScheme.outline)),
            title: Text('Date Certified: ${DateFormat.yMMMd().format(_dateCertified)}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes (Optional)', border: OutlineInputBorder()),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_editingEntryId != null)
                TextButton(
                  onPressed: _resetForm,
                  child: const Text('Cancel Edit'),
                ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: Icon(_editingEntryId != null ? Icons.save_as : Icons.add_circle_outline),
                label: Text(_editingEntryId != null ? 'Update Certification' : 'Add Certification'),
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsList(ThemeData theme) {
    if (_entries.isEmpty) {
      return const Center(child: Text('No certifications recorded yet.'));
    }
    return ListView.builder(
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(entry.certification, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'edit') _handleEdit(entry);
                        if (value == 'delete') _handleDelete(entry.id);
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
                        const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete), title: Text('Delete'))),
                      ],
                    ),
                  ],
                ),
                Text('Craft(s): ${entry.applicableCraft}', style: theme.textTheme.bodyMedium),
                Text('Date: ${DateFormat.yMMMd().format(entry.dateCertified)}', style: theme.textTheme.bodyMedium),
                if (entry.notes != null && entry.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text('Notes: ${entry.notes}', style: theme.textTheme.bodySmall),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}