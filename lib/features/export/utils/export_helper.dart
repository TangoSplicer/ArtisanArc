import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:craft_supply_organiser/features/business/data/sale_model.dart';
import 'package:craft_supply_organiser/features/inventory/data/inventory_model.dart';

class ExportHelper {
  static String generateCsvFromSales(List<SaleRecord> sales) {
    final List<List<dynamic>> rows = [
      ['Item Name', 'Quantity', 'Price Per Unit', 'Date', 'Buyer'],
      ...sales.map((sale) => [
            sale.itemName,
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
            item.price?.toStringAsFixed(2) ?? '',
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
          pw.Table.fromTextArray(
            headers: ['Item', 'Qty', 'Unit Price', 'Total', 'Buyer'],
            data: sales.map((s) {
              return [
                s.itemName,
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
          pw.Table.fromTextArray(
            headers: ['Name', 'Category', 'Qty', 'Price', 'Location'],
            data: items.map((i) {
              return [
                i.name,
                i.category,
                i.quantity,
                i.price?.toStringAsFixed(2) ?? '',
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