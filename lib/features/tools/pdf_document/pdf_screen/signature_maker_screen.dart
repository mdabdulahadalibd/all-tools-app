import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class SignatureMakerScreen extends ConsumerStatefulWidget {
  const SignatureMakerScreen({super.key});

  @override
  ConsumerState<SignatureMakerScreen> createState() => _SignatureMakerScreenState();
}

class _SignatureMakerScreenState extends ConsumerState<SignatureMakerScreen> {
  final List<Offset?> _points = [];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;

  bool _isExporting = false;

  Future<Uint8List?> _captureSignatureAsPngBytes() async {
    if (_points.isEmpty) return null;
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 500, 250));

      final paint = Paint()
        ..color = _selectedColor
        ..strokeCap = StrokeCap.round
        ..strokeWidth = _strokeWidth;

      for (int i = 0; i < _points.length - 1; i++) {
        if (_points[i] != null && _points[i + 1] != null) {
          canvas.drawLine(_points[i]!, _points[i + 1]!, paint);
        }
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(500, 250);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _exportSignatureAsPng() async {
    if (_points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please draw your signature on the canvas first.')),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final pngBytes = await _captureSignatureAsPngBytes();
      if (pngBytes != null) {
        setState(() => _isExporting = false);
        if (mounted) {
          await FileSaveService.saveImageBytesToDevice(context, pngBytes, 'Signature', extension: 'png');
        }
      } else {
        setState(() => _isExporting = false);
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving signature image: $e')),
        );
      }
    }
  }

  Future<void> _exportSignatureAsPdf() async {
    if (_points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please draw your signature on the canvas first.')),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final pngBytes = await _captureSignatureAsPngBytes();
      if (pngBytes != null) {
        final pdfDoc = pw.Document();
        final pdfImage = pw.MemoryImage(pngBytes);

        pdfDoc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context ctx) {
              return pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text('Digital Signature Document', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 24),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
                      child: pw.Image(pdfImage, width: 300, height: 150),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text('Verified Digital Signature Stamp', style: const pw.TextStyle(color: PdfColors.grey)),
                  ],
                ),
              );
            },
          ),
        );

        final Uint8List pdfBytes = await pdfDoc.save();

        setState(() => _isExporting = false);

        if (mounted) {
          await FileSaveService.savePdfToDevice(context, pdfBytes, 'Signature_Doc');
        }
      } else {
        setState(() => _isExporting = false);
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating signature PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('signature_maker');

    return Scaffold(
      appBar: AppBar(
        title: Text(tool.getTitle(lang)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: langNotifier.translate('clear_canvas'),
            onPressed: () {
              setState(() {
                _points.clear();
              });
            },
          ),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero(tool.getTitle(lang), tool.getDescription(lang), Colors.red, Icons.gesture),
            const SizedBox(height: 16),

            // Canvas Box Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(langNotifier.translate('digital_signature_canvas'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: Text(langNotifier.translate('clear_canvas'), style: const TextStyle(color: Colors.red)),
                          onPressed: () {
                            setState(() {
                              _points.clear();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
                        ],
                      ),
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            RenderBox renderBox = context.findRenderObject() as RenderBox;
                            _points.add(renderBox.globalToLocal(details.globalPosition));
                          });
                        },
                        onPanEnd: (details) => _points.add(null),
                        child: CustomPaint(
                          painter: _SignaturePainter(_points, _selectedColor, _strokeWidth),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(langNotifier.translate('draw_signature_hint'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Controls Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(langNotifier.translate('pen_color'), style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildColorPicker(Colors.black),
                        _buildColorPicker(Colors.blue.shade900),
                        _buildColorPicker(Colors.red.shade900),
                        _buildColorPicker(Colors.green.shade900),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(langNotifier.translate('stroke_width'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Slider(
                            value: _strokeWidth,
                            min: 1.0,
                            max: 8.0,
                            divisions: 7,
                            onChanged: (val) => setState(() => _strokeWidth = val),
                          ),
                        ),
                        Text('${_strokeWidth.toInt()}px'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Export Buttons
            if (_isExporting)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: const Icon(Icons.image),
                    label: Text(langNotifier.translate('export_signature_png'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: _exportSignatureAsPng,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(langNotifier.translate('export_signature_pdf'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: _exportSignatureAsPdf,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(Color color) {
    bool isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: color, width: 3) : null,
        ),
        child: CircleAvatar(
          backgroundColor: color,
          radius: 18,
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  final double strokeWidth;

  _SignaturePainter(this.points, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) => true;
}
