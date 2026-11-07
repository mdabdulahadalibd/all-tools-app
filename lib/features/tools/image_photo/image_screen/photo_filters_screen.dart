import 'package:flutter/material.dart';
import '../../../common/widgets/responsive_container.dart';
import '../image_utils/image_models.dart';

class PhotoFiltersScreen extends StatefulWidget {
  const PhotoFiltersScreen({super.key});

  @override
  State<PhotoFiltersScreen> createState() => _PhotoFiltersScreenState();
}

class _PhotoFiltersScreenState extends State<PhotoFiltersScreen> {
  String _selectedPreset = 'Vivid';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Filters')),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            imgHero('Photo Filters Preset', 'Apply color filter effects like Vivid, Grayscale, Sepia & Vintage', Colors.pink, Icons.auto_fix_high),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  children: ['Normal', 'Vivid', 'Grayscale', 'Sepia', 'Vintage'].map((f) {
                    return ChoiceChip(
                      label: Text(f),
                      selected: _selectedPreset == f,
                      onSelected: (v) {
                        if (v) setState(() => _selectedPreset = f);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
