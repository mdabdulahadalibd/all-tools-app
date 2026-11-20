import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGeneratorService {
  /// Generate a professional business Invoice PDF document
  static Future<Uint8List> generateInvoicePdf({
    required String invoiceNo,
    required String clientName,
    required String date,
    required List<Map<String, dynamic>> items,
  }) async {
    final pdf = pw.Document();

    double totalAmount = 0;
    for (var item in items) {
      totalAmount += (item['price'] as double) * (item['qty'] as int);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('INVOICE', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  pw.Text('Invoice #: $invoiceNo\nDate: $date', textAlign: pw.TextAlign.right),
                ],
              ),
              pw.Divider(height: 24),
              pw.Text('Billed To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Text(clientName, style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Item Description', 'Qty', 'Unit Price (BDT)', 'Total'],
                data: items.map((item) {
                  double itemTotal = (item['price'] as double) * (item['qty'] as int);
                  return [
                    item['name'],
                    '${item['qty']}',
                    '৳ ${(item['price'] as double).toStringAsFixed(2)}',
                    '৳ ${itemTotal.toStringAsFixed(2)}',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
              ),
              pw.Divider(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Grand Total: ', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('৳ ${totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                ],
              ),
              pw.Spacer(),
              pw.Center(child: pw.Text('Thank you for your business! • OneTools Studio Invoice System', style: const pw.TextStyle(color: PdfColors.grey))),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  /// Generate a professional Resume / CV PDF document
  static Future<Uint8List> generateResumePdf({
    required String fullName,
    required String title,
    required String email,
    required String phone,
    required String summary,
    required List<String> skills,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(fullName, style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
              pw.Text(title, style: const pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
              pw.SizedBox(height: 6),
              pw.Text('Email: $email  |  Phone: $phone', style: const pw.TextStyle(color: PdfColors.blue800)),
              pw.Divider(height: 20),
              pw.Text('PROFESSIONAL SUMMARY', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
              pw.SizedBox(height: 6),
              pw.Text(summary, style: const pw.TextStyle(fontSize: 12, height: 1.4)),
              pw.SizedBox(height: 16),
              pw.Text('CORE SKILLS & COMPETENCIES', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
              pw.SizedBox(height: 8),
              pw.Wrap(
                spacing: 10,
                runSpacing: 6,
                children: skills.map((skill) {
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(4)),
                    child: pw.Text(skill, style: const pw.TextStyle(fontSize: 11)),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  /// Generate an Academic / Training Certificate PDF
  static Future<Uint8List> generateCertificatePdf({
    required String recipientName,
    required String courseTitle,
    required String issueDate,
    required String instructorName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.amber800, width: 4),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('CERTIFICATE OF ACHIEVEMENT', style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.SizedBox(height: 16),
                pw.Text('PROUDLY PRESENTED TO', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                pw.SizedBox(height: 12),
                pw.Text(recipientName, style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.amber900)),
                pw.SizedBox(height: 16),
                pw.Text('for successfully completing the specialized training course', style: const pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Text(courseTitle, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                pw.SizedBox(height: 30),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(children: [pw.Text(issueDate, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text('Issue Date')]),
                    pw.Column(children: [pw.Text(instructorName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text('Authorized Instructor')]),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return await pdf.save();
  }
}
