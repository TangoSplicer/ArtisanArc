import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../domain/compliance_service.dart';
import '../data/compliance_model.dart';
import '../../../core/constants/compliance_tags.dart';
import 'package:uuid/uuid.dart';

class ComplianceScreen extends StatefulWidget {
  const ComplianceScreen({super.key});

  @override
  State<ComplianceScreen> createState() => _ComplianceScreenState();
}

class _ComplianceScreenState extends State<ComplianceScreen> {
  final ComplianceService _service = GetIt.I<ComplianceService>();
  List<ComplianceEntry> _entries = [];

  final _certController = TextEditingController();
  final _craftController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _service.fetchCertifications();
    setState(() => _entries = entries);
  }

  void _submit() {
    final entry = ComplianceEntry(
      id: const Uuid().v4(),
      certification: _certController.text,
      applicableCraft: _craftController.text,
      dateCertified: DateTime.now(),
      notes: _notesController.text,
    );
    _service.recordCertification(entry).then((_) {
      _certController.clear();
      _craftController.clear();
      _notesController.clear();
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compliance Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _certController, decoration: const InputDecoration(labelText: 'Certification')),
            TextField(controller: _craftController, decoration: const InputDecoration(labelText: 'Craft Type')),
            TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes')),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _submit, child: const Text('Add Certification')),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (_, i) {
                  final e = _entries[i];
                  return ListTile(
                    title: Text(e.certification),
                    subtitle: Text('${e.applicableCraft} – ${e.dateCertified.toLocal()}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}