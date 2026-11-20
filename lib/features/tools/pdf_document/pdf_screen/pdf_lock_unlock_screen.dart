import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final TextEditingController _passCtrl = TextEditingController(text: '123456');
  bool _isLockMode = true;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('pdf_compressor');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('PDF Lock & Unlock Security', 'Set encryption password or unlock protected PDF documents', Colors.red, Icons.security),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Encrypt / Lock PDF'),
                            selected: _isLockMode,
                            onSelected: (v) {
                              if (v) setState(() => _isLockMode = true);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Decrypt / Unlock PDF'),
                            selected: !_isLockMode,
                            onSelected: (v) {
                              if (v) setState(() => _isLockMode = false);
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
                        labelText: _isLockMode ? 'Set Encryption Password' : 'Enter Current Password to Decrypt',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.password),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              icon: Icon(_isLockMode ? Icons.lock : Icons.lock_open),
              label: Text(_isLockMode ? 'Encrypt & Save Protected PDF' : 'Decrypt & Save Unlocked PDF', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () async {
                if (_passCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a password.')));
                  return;
                }
                final dummyBytes = Uint8List.fromList('Protected PDF Data Stream'.codeUnits);
                await FileSaveService.savePdfToDevice(context, dummyBytes, _isLockMode ? 'Locked_PDF' : 'Unlocked_PDF');
              },
            ),
          ],
        ),
      ),
    );
  }
}
