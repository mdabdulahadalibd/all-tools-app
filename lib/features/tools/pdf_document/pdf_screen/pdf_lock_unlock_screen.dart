import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sync_pdf;

import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class PdfLockUnlockScreen extends ConsumerStatefulWidget {
  const PdfLockUnlockScreen({super.key});

  @override
  ConsumerState<PdfLockUnlockScreen> createState() => _PdfLockUnlockScreenState();
}

class _PdfLockUnlockScreenState extends ConsumerState<PdfLockUnlockScreen> {
  PlatformFile? _selectedPdfFile;
  Uint8List? _pdfBytes;

  final TextEditingController _passCtrl = TextEditingController(text: '123456');
  bool _isLockMode = true;

  bool _isProcessing = false;
  Uint8List? _protectedPdfBytes;

  Future<void> _pickRealPdfFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        Uint8List? bytes = platformFile.bytes;

        if (bytes == null && platformFile.path != null && !kIsWeb) {
          bytes = await File(platformFile.path!).readAsBytes();
        }

        if (bytes != null && bytes.isNotEmpty) {
          setState(() {
            _selectedPdfFile = platformFile;
            _pdfBytes = bytes;
            _protectedPdfBytes = null; // Reset previous preview
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking PDF file: $e')),
        );
      }
    }
  }

  Future<void> _processSecurityPdf() async {
    if (_pdfBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file first.')),
      );
      return;
    }

    final String pass = _passCtrl.text.trim();
    if (pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a password.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      if (_isLockMode) {
        final sync_pdf.PdfDocument doc = sync_pdf.PdfDocument(inputBytes: _pdfBytes!);
        doc.security.userPassword = pass;
        doc.security.ownerPassword = pass;
        doc.security.algorithm = sync_pdf.PdfEncryptionAlgorithm.aesx256Bit;

        final List<int> savedList = await doc.save();
        doc.dispose();

        if (mounted) {
          setState(() {
            _protectedPdfBytes = Uint8List.fromList(savedList);
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF Encrypted & Locked Successfully! Ready for Download.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final sync_pdf.PdfDocument doc = sync_pdf.PdfDocument(inputBytes: _pdfBytes!, password: pass);
        final List<int> savedList = await doc.save();
        doc.dispose();

        if (mounted) {
          setState(() {
            _protectedPdfBytes = Uint8List.fromList(savedList);
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF Unlocked & Decrypted Successfully! Ready for Download.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing PDF security: Invalid Password or File Error ($e)')),
        );
      }
    }
  }

  Future<void> _downloadProcessedPdf() async {
    if (_protectedPdfBytes == null) return;
    final prefix = _isLockMode ? 'Protected_PDF' : 'Unlocked_PDF';
    await FileSaveService.savePdfToDevice(context, _protectedPdfBytes!, prefix);
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('pdf_compressor');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero(tool.getTitle(lang), tool.getDescription(lang), Colors.red, Icons.security),
            const SizedBox(height: 16),

            // File Selection Card
            Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                title: Text(
                  _selectedPdfFile?.name ?? langNotifier.translate('no_pdf_selected'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _selectedPdfFile != null ? 'Size: ${(_pdfBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB' : 'Tap button to select PDF from Storage',
                ),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open),
                  label: Text(langNotifier.translate('select_pdf_file')),
                  onPressed: _pickRealPdfFile,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lock / Unlock Options & Password Field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text(langNotifier.translate('encrypt_lock_pdf')),
                            selected: _isLockMode,
                            onSelected: (v) {
                              if (v) {
                                setState(() {
                                  _isLockMode = true;
                                  _protectedPdfBytes = null;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(langNotifier.translate('decrypt_unlock_pdf')),
                            selected: !_isLockMode,
                            onSelected: (v) {
                              if (v) {
                                setState(() {
                                  _isLockMode = false;
                                  _protectedPdfBytes = null;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: _isLockMode ? langNotifier.translate('set_encryption_pass') : langNotifier.translate('enter_current_pass'),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.password),
                      ),
                      onChanged: (_) => setState(() => _protectedPdfBytes = null),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Button
            if (_isProcessing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Processing PDF Security...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(_isLockMode ? Icons.lock : Icons.lock_open),
                label: Text(_isLockMode ? 'Encrypt & Protect PDF' : 'Decrypt & Unlock PDF', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: _processSecurityPdf,
              ),

            // Download Section
            if (_protectedPdfBytes != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.green.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.greenAccent, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        _isLockMode ? 'PDF Encrypted & Locked!' : 'PDF Unlocked Successfully!',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Size: ${(_protectedPdfBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
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
                          'Download Processed PDF to Device (ডাউনলোড করুন)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _downloadProcessedPdf,
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
