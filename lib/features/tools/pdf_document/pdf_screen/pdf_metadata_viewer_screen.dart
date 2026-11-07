import 'package:flutter/material.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class PdfMetadataViewerScreen extends StatelessWidget {
  const PdfMetadataViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Metadata & Page Info')),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('PDF Metadata & Info', 'Inspect title, author, total page count, PDF version & creation date', Colors.red, Icons.info),
            const SizedBox(height: 16),
            const Card(
              child: Column(
                children: [
                  ListTile(title: Text('Document Title'), subtitle: Text('Annual Report 2025.pdf', style: TextStyle(fontWeight: FontWeight.bold))),
                  Divider(height: 1),
                  ListTile(title: Text('Total Page Count'), subtitle: Text('14 Pages', style: TextStyle(fontWeight: FontWeight.bold))),
                  Divider(height: 1),
                  ListTile(title: Text('PDF Version'), subtitle: Text('PDF v1.7 (Acrobat 8.x)', style: TextStyle(fontWeight: FontWeight.bold))),
                  Divider(height: 1),
                  ListTile(title: Text('Creation Date'), subtitle: Text('2025-03-26 10:30:00 UTC', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
