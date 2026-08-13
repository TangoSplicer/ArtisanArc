import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/widgets/personal_app_bar.dart';
import '../../../core/widgets/searchable_selection_field.dart';
import '../data/label_model.dart';
import '../../inventory/domain/inventory_service.dart';
import '../../inventory/data/inventory_model.dart';

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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadInventoryItems() async {
    final items = await _inventoryService.fetchItems();
    if (!mounted) return;
    setState(() {
      _inventoryItems = [...items]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final text = _useInventoryItem && _selectedItem != null
        ? '${_selectedItem!.name}\n${_selectedItem!.category}\n£${_selectedItem!.price?.toStringAsFixed(2) ?? 'N/A'}'
        : _textController.text;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.GridView(
            crossAxisCount: _selectedTemplate.columns,
            childAspectRatio: _selectedTemplate.width / _selectedTemplate.height,
            children: List.generate(
              _selectedTemplate.columns * _selectedTemplate.rows,
              (_) => pw.Container(
                margin: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
                child: pw.Center(child: pw.Text(text, textAlign: pw.TextAlign.center)),
              ),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PersonalAppBar(title: Text('Label Generator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SearchableSelectionField<LabelTemplate>(
            options: predefinedTemplates,
            value: _selectedTemplate,
            labelText: 'Label template',
            hintText: 'Search format, brand, or dimensions',
            itemLabel: (template) => template.name,
            itemSubtitle: (template) => '${template.columns * template.rows} labels per A4 sheet',
            searchTerms: (template) => [template.id, template.name, '${template.width}', '${template.height}'],
            onChanged: (template) {
              if (template != null) setState(() => _selectedTemplate = template);
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Use inventory item details'),
            subtitle: const Text('Search your saved stock and print its name, category, and price.'),
            value: _useInventoryItem,
            onChanged: (value) => setState(() => _useInventoryItem = value),
          ),
          const SizedBox(height: 16),
          if (_useInventoryItem)
            SearchableSelectionField<InventoryItem>(
              options: _inventoryItems,
              value: _selectedItem,
              labelText: 'Inventory item',
              hintText: 'Search by item, category, or location',
              emptyMessage: 'No matching inventory items',
              itemLabel: (item) => item.name,
              itemSubtitle: (item) => '${item.category}${item.storageLocation == null || item.storageLocation!.isEmpty ? '' : ' · ${item.storageLocation}'}',
              searchTerms: (item) => [item.name, item.category, item.storageLocation ?? ''],
              onChanged: (item) => setState(() => _selectedItem = item),
            )
          else
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Label text', border: OutlineInputBorder()),
              maxLines: 3,
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.print),
            label: const Text('Generate & Print Labels'),
            onPressed: _useInventoryItem && _selectedItem == null
                ? null
                : _generatePdf,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ],
      ),
    );
  }
}
