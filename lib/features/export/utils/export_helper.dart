import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:artisanarc/features/business/data/sale_model.dart';
import 'package:artisanarc/features/inventory/data/inventory_model.dart';

class ExportHelper {
  static String generateCsvFromSales(List<SaleRecord> sales) {
    final List<List<dynamic>> rows = [
      ['Item Name', 'Quantity', 'Price Per Unit', 'Date', 'Buyer'],
      ...sales.map((sale) => [
            sale.itemId,
            sale.quantity,
            sale.pricePerUnit,
            sale.date.toIso8601String(),
            sale.buyer ?? '',
          ]),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  static String generateCsvFromInventory(List<InventoryItem> items) {
    final List<List<dynamic>> rows = [
      ['Name', 'Category', 'Quantity', 'Price', 'Location'],
      ...items.map((item) => [
            item.name,
            item.category,
            item.quantity,
            item.price.toString,
            item.storageLocation ?? '',
          ]),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  static pw.Document generateSalesPdf(List<SaleRecord> sales) {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Sales Report', style: pw.TextStyle(fontSize: 24)),
          pw.TableHelper.fromTextArray(
            headers: ['Item', 'Qty', 'Unit Price', 'Total', 'Buyer'],
            data: sales.map((s) {
              return [
                s.itemId,
                s.quantity,
                '£${s.pricePerUnit}',
                '£${s.total.toStringAsFixed(2)}',
                s.buyer ?? '',
              ];
            }).toList(),
          ),
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
            headers: ['Name', 'Category', 'Qty', 'Price', 'Location'],
            data: items.map((i) {
              return [
                i.name,
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