import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';

class RandomGeneratorScreen extends ConsumerStatefulWidget {
  const RandomGeneratorScreen({super.key});

  @override
  ConsumerState<RandomGeneratorScreen> createState() => _RandomGeneratorScreenState();
}

class _RandomGeneratorScreenState extends ConsumerState<RandomGeneratorScreen> {
  final TextEditingController _minCtrl = TextEditingController(text: '1');
  final TextEditingController _maxCtrl = TextEditingController(text: '100');

  int _randomNumber = 42;

  void _generate() {
    int min = int.tryParse(_minCtrl.text) ?? 1;
    int max = int.tryParse(_maxCtrl.text) ?? 100;

    if (min >= max) return;
    final rand = Random();
    setState(() => _randomNumber = min + rand.nextInt(max - min + 1));
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('random_generator');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.teal.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Generated Random Number', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('$_randomNumber', style: const TextStyle(fontSize: 54, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _minCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Min Value', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _maxCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max Value', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      icon: const Icon(Icons.casino),
                      label: const Text('Generate Random Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: _generate,
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
