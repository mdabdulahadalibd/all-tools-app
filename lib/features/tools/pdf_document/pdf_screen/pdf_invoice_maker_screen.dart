import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';

import '../pdf_services/pdf_generator_service.dart';
import '../pdf_utils/pdf_models.dart';

class PdfInvoiceMakerScreen extends ConsumerStatefulWidget {
  const PdfInvoiceMakerScreen({super.key});

  @override
  ConsumerState<PdfInvoiceMakerScreen> createState() => _PdfInvoiceMakerScreenState();
}

class _PdfInvoiceMakerScreenState extends ConsumerState<PdfInvoiceMakerScreen> {
  final TextEditingController _invoiceNoCtrl = TextEditingController(text: 'INV-2025-001');
  final TextEditingController _clientNameCtrl = TextEditingController(text: 'Rahman Tech Ltd.');
  final TextEditingController _item1NameCtrl = TextEditingController(text: 'Web & App Design Service');
  final TextEditingController _item1PriceCtrl = TextEditingController(text: '15000');
  final TextEditingController _item1QtyCtrl = TextEditingController(text: '1');

  bool _isGenerating = false;
  Uint8List? _generatedInvoicePdf;

  Future<void> _generateInvoice() async {
    setState(() => _isGenerating = true);

    try {
      final double price = double.tryParse(_item1PriceCtrl.text) ?? 0;
      final int qty = int.tryParse(_item1QtyCtrl.text) ?? 1;

      final Uint8List pdfBytes = await PdfGeneratorService.generateInvoicePdf(
        invoiceNo: _invoiceNoCtrl.text,
        clientName: _clientNameCtrl.text,
        date: DateFormat('dd MMM yyyy').format(DateTime.now()),
        items: [
          {'name': _item1NameCtrl.text, 'price': price, 'qty': qty},
        ],
      );

      if (mounted) {
        setState(() {
          _generatedInvoicePdf = pdfBytes;
          _isGenerating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business Invoice PDF Generated! Ready for Download.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating Invoice PDF: $e')),
        );
      }
    }
  }

  Future<void> _downloadInvoicePdf() async {
    if (_generatedInvoicePdf == null) return;
    await FileSaveService.savePdfToDevice(context, _generatedInvoicePdf!, 'Business_Invoice');
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('pdf_splitter');

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice PDF Maker'), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('Invoice PDF Maker', 'Create and download professional business invoices', Colors.red, Icons.receipt),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _invoiceNoCtrl,
                      decoration: const InputDecoration(labelText: 'Invoice Number', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _clientNameCtrl,
                      decoration: const InputDecoration(labelText: 'Client / Customer Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text('Item Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _item1NameCtrl,
                      decoration: const InputDecoration(labelText: 'Service / Product Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _item1PriceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Price per Unit (৳)', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _item1QtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_isGenerating)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.receipt),
                label: const Text('Generate Invoice PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: _generateInvoice,
              ),

            if (_generatedInvoicePdf != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.green.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.greenAccent, size: 48),
                      const SizedBox(height: 8),
                      const Text(
                        'Invoice PDF Ready!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.download, size: 24),
                        label: const Text(
                          'Download Invoice PDF (ডাউনলোড করুন)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _downloadInvoicePdf,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
