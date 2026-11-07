import 'package:flutter/material.dart';
import '../../../common/widgets/responsive_container.dart';
import '../image_utils/image_models.dart';

class FormatConverterScreen extends StatefulWidget {
  const FormatConverterScreen({super.key});

  @override
  State<FormatConverterScreen> createState() => _FormatConverterScreenState();
}

class _FormatConverterScreenState extends State<FormatConverterScreen> {
  String _selectedFormat = 'PNG';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Format Converter')),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            imgHero('Image Format Converter', 'Convert photos between JPG, PNG, WebP & GIF formats', Colors.purple, Icons.transform),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedFormat,
                  decoration: const InputDecoration(labelText: 'Target Output Format', border: OutlineInputBorder()),
                  items: ['JPG', 'PNG', 'WebP', 'GIF'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedFormat = v);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
