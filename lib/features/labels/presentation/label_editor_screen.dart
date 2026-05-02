import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../data/label_model.dart';
import '../../inventory/domain/inventory_service.dart';
import '../../inventory/data/inventory_model.dart';
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
  final InventoryService _inventoryService = GetIt.I<InventoryService>();
  List<InventoryItem> _inventoryItems = [];
  InventoryItem? _selectedItem;
  bool _useInventoryItem = false;

  @override
  void initState() {
    super.initState();
    _loadInventoryItems();
  }

  Future<void> _loadInventoryItems() async {
    final items = await _inventoryService.fetchItems();
    setState(() => _inventoryItems = items);
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final text = _useInventoryItem && _selectedItem != null
        ? '${_selectedItem!.name}\n${_selectedItem!.category}\n£${_selectedItem!.price?.toStringAsFixed(2) ?? 'N/A'}'
        : _textController.text;

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
                    child: pw.Text(text, textAlign: pw.TextAlign.center),
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
            Text('Label Template', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButton<LabelTemplate>(
              value: _selectedTemplate,
              isExpanded: true,
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
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Use Inventory Item'),
              value: _useInventoryItem,
              onChanged: (value) => setState(() => _useInventoryItem = value),
            ),
            const SizedBox(height: 16),
            if (_useInventoryItem) ...[
              DropdownButton<InventoryItem>(
                value: _selectedItem,
                hint: const Text('Select Inventory Item'),
                isExpanded: true,
                items: _inventoryItems.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text('${item.name} (${item.category})'),
                  );
                }).toList(),
                onChanged: (item) => setState(() => _selectedItem = item),
              ),
            ] else ...[
              TextField(
                controller: _textController,
                decoration: const InputDecoration(labelText: 'Label Text'),
                maxLines: 3,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('Generate & Print Labels'),
              onPressed: _generatePdf,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}