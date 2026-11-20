import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sync_pdf;

class PdfConversionService {
  /// Extract all plain text from PDF document bytes
  static Future<String> extractText(Uint8List inputPdfBytes) async {
    final sync_pdf.PdfDocument doc = sync_pdf.PdfDocument(inputBytes: inputPdfBytes);
    final sync_pdf.PdfTextExtractor extractor = sync_pdf.PdfTextExtractor(doc);
    final String text = extractor.extractText();
    doc.dispose();
    return text;
  }

  /// Convert plain text string into a formatted PDF document
  static Future<Uint8List> convertTextToPdf(String text, {String title = 'Text Document'}) async {
    final sync_pdf.PdfDocument pdfDoc = sync_pdf.PdfDocument();
    final sync_pdf.PdfPage page = pdfDoc.pages.add();

    final sync_pdf.PdfFont font = sync_pdf.PdfStandardFont(sync_pdf.PdfFontFamily.helvetica, 12);
    final sync_pdf.PdfFont titleFont = sync_pdf.PdfStandardFont(sync_pdf.PdfFontFamily.helvetica, 18, style: sync_pdf.PdfFontStyle.bold);

    page.graphics.drawString(
      title,
      titleFont,
      bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 30),
      brush: sync_pdf.PdfBrushes.darkBlue,
    );

    page.graphics.drawString(
      text,
      font,
      bounds: Rect.fromLTWH(0, 40, page.getClientSize().width, page.getClientSize().height - 40),
    );

    final List<int> savedList = await pdfDoc.save();
    pdfDoc.dispose();

    return Uint8List.fromList(savedList);
  }

  /// Analyze word count, character count, and page count of PDF bytes
  static Future<Map<String, dynamic>> analyzePdfStats(Uint8List inputPdfBytes) async {
    final sync_pdf.PdfDocument doc = sync_pdf.PdfDocument(inputBytes: inputPdfBytes);
    final int pageCount = doc.pages.count;
    final sync_pdf.PdfTextExtractor extractor = sync_pdf.PdfTextExtractor(doc);
    final String text = extractor.extractText();
    doc.dispose();

    final int charCount = text.length;
    final int wordCount = text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;

    return {
      'pages': pageCount,
      'words': wordCount,
      'characters': charCount,
      'text': text,
    };
  }
}
