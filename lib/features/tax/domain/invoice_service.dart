import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../../business/data/sale_model.dart';
import '../../commissions/data/commission_model.dart';
import '../data/brand_kit_model.dart';
import 'package:hive/hive.dart';

class InvoiceService {
  static const String _brandBoxName = 'brandKitBox';

  static Future<Box<BrandKit>> _openBrandBox() async {
    if (!Hive.isBoxOpen(_brandBoxName)) {
      return await Hive.openBox<BrandKit>(_brandBoxName);
    }
    return Hive.box<BrandKit>(_brandBoxName);
  }

  static Future<BrandKit> getBrandKit() async {
    final box = await _openBrandBox();
    if (box.isEmpty) {
      final defaultKit = BrandKit(
        id: 'primary_brand',
        businessName: 'My Handmade Studio',
        makerName: 'Solo Maker',
        address: '123 Craft Lane, Studio City',
        email: 'maker@craftstudio.test',
        phone: '+44 7000 000000',
      );
      await box.put('primary_brand', defaultKit);
      return defaultKit;
    }
    return box.values.first;
  }

  static Future<void> saveBrandKit(BrandKit kit) async {
    final box = await _openBrandBox();
    await box.put(kit.id, kit);
  }

  static Future<File> generateSaleInvoicePdf(SaleRecord sale) async {
    final brand = await getBrandKit();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(brand.businessName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text('Maker: ${brand.makerName}'),
                      pw.Text(brand.address),
                      pw.Text('Email: ${brand.email} | Phone: ${brand.phone}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.purple800)),
                      pw.SizedBox(height: 4),
                      pw.Text('Invoice No: INV-${sale.id.substring(0, 6).toUpperCase()}'),
                      pw.Text('Date: ${sale.date.toLocal().toString().split(' ').first}'),
                    ],
                  ),
                ],
              ),
              pw.Divider(height: 30),
              pw.Text('Billed To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(sale.buyer ?? 'Valued Customer'),
              if (sale.eventName != null) pw.Text('Event: ${sale.eventName}'),
              pw.SizedBox(height: 30),
              pw.Table.fromTextArray(
                headers: ['Description', 'Qty', 'Unit Price', 'Total'],
                data: [
                  [
                    'Handmade Craft Item (${sale.itemId})',
                    sale.quantity.toString(),
                    '£${sale.pricePerUnit.toStringAsFixed(2)}',
                    '£${(sale.pricePerUnit * sale.quantity - (sale.discountAmount ?? 0)).toStringAsFixed(2)}',
                  ],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.purple800),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
              ),
              pw.Spacer(),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Total Due: £${(sale.pricePerUnit * sale.quantity - (sale.discountAmount ?? 0)).toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text('Payment Method: ${sale.paymentMethod.toUpperCase()}', style: const pw.TextStyle(color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Center(
                child: pw.Text('Thank you for supporting independent handmade crafts!',
                    style: const pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey600)),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice_${sale.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<void> shareSaleInvoice(SaleRecord sale) async {
    final file = await generateSaleInvoicePdf(sale);
    await Printing.sharePdf(bytes: await file.readAsBytes(), filename: 'invoice_${sale.id}.pdf');
  }
}
