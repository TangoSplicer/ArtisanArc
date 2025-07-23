import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:printing/printing.dart';
import '../../utils/export_helper.dart';
import '../../../business/domain/business_service.dart';
import '../../../inventory/domain/inventory_service.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BusinessService business = GetIt.I<BusinessService>();
    final InventoryService inventory = GetIt.I<InventoryService>();
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Reports'),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [color.surface, color.background, color.primary.withOpacity(0.05)],
            radius: 1.2,
            center: Alignment.centerRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildExportCard(
              context,
              title: 'Export Sales as CSV',
              icon: Icons.download,
              color: color.primary,
              onTap: () async {
                final sales = await business.fetchSales();
                final csv = ExportHelper.generateCsvFromSales(sales);
                await Printing.sharePdf(bytes: Uint8List.fromList(csv.codeUnits), filename: 'sales.csv');
              },
            ),
            _buildExportCard(
              context,
              title: 'Export Inventory as CSV',
              icon: Icons.table_chart,
              color: color.secondary,
              onTap: () async {
                final items = await inventory.fetchItems();
                final csv = ExportHelper.generateCsvFromInventory(items);
                await Printing.sharePdf(bytes: Uint8List.fromList(csv.codeUnits), filename: 'inventory.csv');
              },
            ),
            _buildExportCard(
              context,
              title: 'Export Sales as PDF',
              icon: Icons.picture_as_pdf,
              color: color.tertiary,
              onTap: () async {
                final sales = await business.fetchSales();
                final pdf = ExportHelper.generateSalesPdf(sales);
                await Printing.layoutPdf(onLayout: (format) => pdf.save());
              },
            ),
            _buildExportCard(
              context,
              title: 'Export Inventory as PDF',
              icon: Icons.description,
              color: Colors.deepPurpleAccent,
              onTap: () async {
                final items = await inventory.fetchItems();
                final pdf = ExportHelper.generateInventoryPdf(items);
                await Printing.layoutPdf(onLayout: (format) => pdf.save());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportCard(BuildContext context,
      {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      shadowColor: color.withOpacity(0.3),
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        onTap: onTap,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}