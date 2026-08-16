import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart' show PdfColors;
import 'package:pdf/widgets.dart' as pw;
import 'package:artisanarc/features/business/data/sale_model.dart';
import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/project/data/project_model.dart';

class ExportHelper {
  static String generateCsvFromSales(
    List<SaleRecord> sales, {
    Map<String, String> itemNames = const {},
  }) {
    final List<List<dynamic>> rows = [
      [
        'Item Name',
        'Quantity',
        'Price Per Unit',
        'Discount',
        'Net Total',
        'Payment Method',
        'Status',
        'Date',
        'Buyer',
        'Event / Session',
        'Table / Venue',
        'Session ID',
        'Adjustment Reason',
      ],
      ...sales.map((sale) => [
            itemNames[sale.itemId] ?? sale.itemId,
            sale.quantity,
            sale.pricePerUnit,
            sale.discountAmount,
            sale.total,
            sale.paymentMethod,
            sale.isVoid
                ? 'Voided'
                : sale.isReturn
                    ? 'Return'
                    : 'Sale',
            sale.date.toIso8601String(),
            sale.buyer ?? '',
            sale.eventName ?? '',
            sale.eventLocation ?? '',
            sale.sessionId ?? '',
            sale.adjustmentReason ?? '',
          ]),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  static String generateCsvFromInventory(List<InventoryItem> items) {
    final List<List<dynamic>> rows = [
      [
        'Name',
        'Type',
        'Category',
        'Quantity',
        'Price',
        'Location',
        'Unit',
        'Reorder Point',
        'Yarn Brand',
        'Yarn Range',
        'Yarn Colour',
        'Dye Lot',
        'Yarn Weight',
        'Yarn Fibre',
        'Skein Weight (g)',
        'Skein Length (m)',
        'Recommended Hook',
        'Gauge Note',
      ],
      ...items.map((item) => [
            item.name,
            item.isFinishedItem ? 'Created Item' : 'Material Stock',
            item.category,
            item.availableStockQuantity,
            item.price ?? '',
            item.storageLocation ?? '',
            item.measurementUnit ?? '',
            item.activeReorderPoint ?? '',
            item.yarnBrand ?? '',
            item.yarnRange ?? '',
            item.yarnColour ?? '',
            item.dyeLot ?? '',
            item.yarnWeight ?? '',
            item.yarnFibre ?? '',
            item.yarnWeightGrams ?? '',
            item.yarnLengthMetres ?? '',
            item.recommendedHookSize ?? '',
            item.gaugeNote ?? '',
          ]),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  static pw.Document generateSalesPdf(
    List<SaleRecord> sales, {
    Map<String, String> itemNames = const {},
  }) {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Sales Report', style: pw.TextStyle(fontSize: 24)),
          pw.TableHelper.fromTextArray(
            headers: [
              'Item',
              'Qty',
              'Unit',
              'Discount',
              'Total',
              'Payment',
              'Status',
              'Event / Session'
            ],
            data: sales.map((s) {
              return [
                itemNames[s.itemId] ?? s.itemId,
                s.quantity,
                '£${s.pricePerUnit}',
                '£${s.discountAmount.toStringAsFixed(2)}',
                '£${s.total.toStringAsFixed(2)}',
                s.paymentMethod,
                s.isVoid
                    ? 'Voided'
                    : s.isReturn
                        ? 'Return'
                        : 'Sale',
                s.eventName ?? '',
              ];
            }).toList(),
          ),
        ],
      ),
    );
    return doc;
  }

  static pw.Document generateProjectsPdf(List<Project> projects) {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Project Report', style: pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 12),
          if (projects.isEmpty)
            pw.Text('No projects have been saved yet.')
          else
            ...projects.map((project) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(project.name,
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      if ((project.craftType ?? '').isNotEmpty)
                        pw.Text('Craft: ${project.craftType}'),
                      if ((project.description ?? '').isNotEmpty)
                        pw.Text(project.description!),
                      pw.SizedBox(height: 6),
                      pw.Text(
                          'Milestones: ${project.milestones.where((m) => m.isCompleted).length}/${project.milestones.length} completed'),
                      if (project.supplyNeeds.isNotEmpty)
                        pw.Text(
                            'Supplies: ${project.supplyNeeds.map((s) => '${s.quantityNeeded} ${s.unit} ${s.itemName}').join(', ')}'),
                    ],
                  ),
                )),
        ],
      ),
    );
    return doc;
  }

  static pw.Document generateInventoryPdf(List<InventoryItem> items) {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Inventory Report', style: pw.TextStyle(fontSize: 24)),
          pw.TableHelper.fromTextArray(
            headers: ['Name', 'Type', 'Category', 'Qty', 'Price', 'Location'],
            data: items.map((i) {
              return [
                i.name,
                i.isFinishedItem ? 'Created Item' : 'Material Stock',
                i.category,
                i.quantity,
                i.price.toString,
                i.storageLocation ?? '',
              ];
            }).toList(),
          ),
        ],
      ),
    );
    return doc;
  }
}
