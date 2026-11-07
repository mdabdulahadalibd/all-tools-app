import 'package:flutter/material.dart';
import '../../../common/widgets/responsive_container.dart';
import '../image_utils/image_models.dart';

class ImageResizerScreen extends StatefulWidget {
  const ImageResizerScreen({super.key});

  @override
  State<ImageResizerScreen> createState() => _ImageResizerScreenState();
}

class _ImageResizerScreenState extends State<ImageResizerScreen> {
  final TextEditingController _wCtrl = TextEditingController(text: '1080');
  final TextEditingController _hCtrl = TextEditingController(text: '1080');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Resizer')),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            imgHero('Image Pixel Resizer', 'Resize width and height pixel dimensions with aspect ratio lock', Colors.purple, Icons.aspect_ratio),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _wCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Width (px)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _hCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Height (px)', border: OutlineInputBorder()),
                      ),
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
