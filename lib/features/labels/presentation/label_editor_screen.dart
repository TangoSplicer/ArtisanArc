import 'package:flutter/material.dart';
import '../data/label_model.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class LabelEditorScreen extends StatefulWidget {
  const LabelEditorScreen({super.key});

  @override
  State<LabelEditorScreen> createState() => _LabelEditorScreenState();
}

class _LabelEditorScreenState extends State<LabelEditorScreen> {
  LabelTemplate _selectedTemplate = predefinedTemplates.first;
  final _textController = TextEditingController(text: 'Label Text');

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final text = _textController.text;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.GridView(
              crossAxisCount: _selectedTemplate.columns,
              childAspectRatio:
                  _selectedTemplate.width / _selectedTemplate.height,
              children: List.generate(
                _selectedTemplate.columns * _selectedTemplate.rows,
                (_) => pw.Container(
                  margin: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                  ),
                  child: pw.Center(
                    child: pw.Text(text),
                  ),
                ),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Label Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<LabelTemplate>(
              value: _selectedTemplate,
              onChanged: (value) {
                if (value != null) setState(() => _selectedTemplate = value);
              },
              items: predefinedTemplates.map((template) {
                return DropdownMenuItem(
                  value: template,
                  child: Text(template.name),
                );
              }).toList(),
            ),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Label Text'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generatePdf,
              child: const Text('Generate Printable PDF'),
            ),
          ],
        ),
      ),
    );
  }
}