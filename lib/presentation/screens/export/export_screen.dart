import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:printing/printing.dart';
import '../../../features/export/utils/export_helper.dart';
import '../../../features/business/domain/business_service.dart';
import '../../../features/inventory/domain/inventory_service.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BusinessService businessService = GetIt.I<BusinessService>();
    final InventoryService inventoryService = GetIt.I<InventoryService>();
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Export'),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildExportOption(
            context,
            title: 'Export Inventory as CSV',
            subtitle: 'Export your inventory data to a CSV file',
            icon: Icons.inventory_2,
            color: color.primary,
            onTap: () async {
              final items = await inventoryService.fetchItems();
              final csv = ExportHelper.generateCsvFromInventory(items);
              await Printing.sharePdf(bytes: Uint8List.fromList(csv.codeUnits), filename: 'inventory.csv');
            },
          ),
          _buildExportOption(
            context,
            title: 'Export Sales Data as CSV',
            subtitle: 'Export your sales data to a CSV file',
            icon: Icons.business_center,
            color: color.secondary,
            onTap: () async {
              final sales = await businessService.fetchSales();
              final csv = ExportHelper.generateCsvFromSales(sales);
              await Printing.sharePdf(bytes: Uint8List.fromList(csv.codeUnits), filename: 'sales.csv');
            },
          ),
          _buildExportOption(
            context,
            title: 'Print Project Report as PDF',
            subtitle: 'Print a detailed report of your projects',
            icon: Icons.timeline,
            color: color.tertiary,
            onTap: () async {
              // TODO: Implement project report generation
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: color.withOpacity(0.4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color.withOpacity(0.08),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
