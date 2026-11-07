import 'package:flutter/material.dart';
import '../../../common/widgets/responsive_container.dart';
import '../image_utils/image_models.dart';

class ImageCompressorScreen extends StatefulWidget {
  const ImageCompressorScreen({super.key});

  @override
  State<ImageCompressorScreen> createState() => _ImageCompressorScreenState();
}

class _ImageCompressorScreenState extends State<ImageCompressorScreen> {
  double _quality = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Compressor')),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            imgHero('Image Compressor', 'Compress image KB size without noticeable quality loss', Colors.purple, Icons.compress),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Target Compression Quality: ${_quality.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _quality,
                      min: 10,
                      max: 100,
                      divisions: 18,
                      onChanged: (v) => setState(() => _quality = v),
                    ),
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
