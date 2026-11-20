import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sync_pdf;

class PdfPageService {
  /// Delete specific page indices (0-based) from input PDF bytes
  static Future<Uint8List> deletePages(Uint8List inputPdfBytes, Set<int> pageIndicesToDelete) async {
    final sync_pdf.PdfDocument inputDoc = sync_pdf.PdfDocument(inputBytes: inputPdfBytes);
    final sync_pdf.PdfDocument outputDoc = sync_pdf.PdfDocument();

    for (int i = 0; i < inputDoc.pages.count; i++) {
      if (!pageIndicesToDelete.contains(i)) {
        final sync_pdf.PdfTemplate template = inputDoc.pages[i].createTemplate();
        final sync_pdf.PdfPage newPage = outputDoc.pages.add();
        newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
      }
    }

    final List<int> savedList = await outputDoc.save();
    inputDoc.dispose();
    outputDoc.dispose();

    return Uint8List.fromList(savedList);
  }

  /// Extract specific page indices (0-based) from input PDF bytes into a new PDF
  static Future<Uint8List> extractPages(Uint8List inputPdfBytes, List<int> pageIndicesToExtract) async {
    final sync_pdf.PdfDocument inputDoc = sync_pdf.PdfDocument(inputBytes: inputPdfBytes);
    final sync_pdf.PdfDocument outputDoc = sync_pdf.PdfDocument();

    for (int index in pageIndicesToExtract) {
      if (index >= 0 && index < inputDoc.pages.count) {
        final sync_pdf.PdfTemplate template = inputDoc.pages[index].createTemplate();
        final sync_pdf.PdfPage newPage = outputDoc.pages.add();
        newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
      }
    }

    final List<int> savedList = await outputDoc.save();
    inputDoc.dispose();
    outputDoc.dispose();

    return Uint8List.fromList(savedList);
  }

  /// Add page numbers to each page of the input PDF document
  static Future<Uint8List> addPageNumbers(Uint8List inputPdfBytes, {String position = 'Bottom Center'}) async {
    final sync_pdf.PdfDocument doc = sync_pdf.PdfDocument(inputBytes: inputPdfBytes);
    final sync_pdf.PdfFont font = sync_pdf.PdfStandardFont(sync_pdf.PdfFontFamily.helvetica, 10);

    for (int i = 0; i < doc.pages.count; i++) {
      final sync_pdf.PdfPage page = doc.pages[i];
      final String numberText = 'Page ${i + 1} of ${doc.pages.count}';
      final Size pageSize = page.getClientSize();

      double x = (pageSize.width - 80) / 2;
      double y = pageSize.height - 20;

      if (position == 'Top Right') {
        x = pageSize.width - 90;
        y = 15;
      } else if (position == 'Bottom Right') {
        x = pageSize.width - 90;
        y = pageSize.height - 20;
      }

      page.graphics.drawString(
        numberText,
        font,
        bounds: Rect.fromLTWH(x, y, 100, 20),
        brush: sync_pdf.PdfBrushes.black,
      );
    }

    final List<int> savedList = await doc.save();
    doc.dispose();

    return Uint8List.fromList(savedList);
  }
}
