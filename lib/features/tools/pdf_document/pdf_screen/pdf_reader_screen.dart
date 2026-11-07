import 'package:flutter/material.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class PdfReaderScreen extends StatelessWidget {
  const PdfReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Reader & Viewer')),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('PDF Reader & Viewer', 'Read, zoom and navigate through PDF document pages offline', Colors.red, Icons.book),
            const SizedBox(height: 16),
            Container(
              height: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf, size: 72, color: Colors.red),
                    SizedBox(height: 12),
                    Text('PDF Document Reader View Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Page 1 of 12', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
