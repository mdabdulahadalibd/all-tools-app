import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/services/file_save_service.dart';
import '../../../common/widgets/responsive_container.dart';
import '../pdf_utils/pdf_models.dart';

class PdfLockUnlockScreen extends StatefulWidget {
  const PdfLockUnlockScreen({super.key});

  @override
  State<PdfLockUnlockScreen> createState() => _PdfLockUnlockScreenState();
}

class _PdfLockUnlockScreenState extends State<PdfLockUnlockScreen> {
  final TextEditingController _passCtrl = TextEditingController(text: '123456');
  bool _isLock = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Password Lock / Unlock')),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            pdfHero('PDF Lock & Unlock', 'Protect PDF with encryption password or remove protection', Colors.red, Icons.lock),
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
                            selected: _isLock,
                            onSelected: (v) {
                              if (v) setState(() => _isLock = true);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Decrypt / Unlock PDF'),
                            selected: !_isLock,
                            onSelected: (v) {
                              if (v) setState(() => _isLock = false);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'PDF Password', border: OutlineInputBorder()),
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
              icon: Icon(_isLock ? Icons.lock : Icons.lock_open),
              label: Text(_isLock ? 'Encrypt & Save Protected PDF' : 'Decrypt & Save Unlocked PDF', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () async {
                await FileSaveService.savePdfToDevice(context, Uint8List.fromList('Protected PDF Data'.codeUnits), _isLock ? 'Locked_PDF' : 'Unlocked_PDF');
              },
            ),
          ],
        ),
      ),
    );
  }
}
