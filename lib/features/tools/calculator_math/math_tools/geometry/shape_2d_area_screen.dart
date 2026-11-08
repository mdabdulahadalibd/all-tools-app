import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class Shape2dAreaScreen extends ConsumerStatefulWidget {
  const Shape2dAreaScreen({super.key});

  @override
  ConsumerState<Shape2dAreaScreen> createState() => _Shape2dAreaScreenState();
}

class _Shape2dAreaScreenState extends ConsumerState<Shape2dAreaScreen> {
  String _selectedShape = 'Circle';
  final TextEditingController _param1Ctrl = TextEditingController(text: '7');
  final TextEditingController _param2Ctrl = TextEditingController(text: '10');

  double _area = 153.94;
  double _perimeter = 43.98;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double p1 = double.tryParse(_param1Ctrl.text) ?? 0;
    double p2 = double.tryParse(_param2Ctrl.text) ?? 0;

    if (_selectedShape == 'Circle') {
      double r = p1;
      setState(() {
        _area = pi * r * r;
        _perimeter = 2 * pi * r;
      });
    } else if (_selectedShape == 'Rectangle') {
      double l = p1, w = p2;
      setState(() {
        _area = l * w;
        _perimeter = 2 * (l + w);
      });
    } else if (_selectedShape == 'Triangle') {
      double base = p1, height = p2;
      setState(() {
        _area = 0.5 * base * height;
        _perimeter = 3 * base;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('area_2d_shape_calc');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.deepOrange.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [Text(langNotifier.translate('area_2d'), style: const TextStyle(color: Colors.white70)), Text(_area.toStringAsFixed(2), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amberAccent))]),
                    Column(children: [Text(langNotifier.translate('perimeter_2d'), style: const TextStyle(color: Colors.white70)), Text(_perimeter.toStringAsFixed(2), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent))]),
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
                    DropdownButtonFormField<String>(
                      initialValue: _selectedShape,
                      decoration: const InputDecoration(labelText: 'Select 2D Shape', border: OutlineInputBorder()),
                      items: ['Circle', 'Rectangle', 'Triangle'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedShape = val);
                          _calculate();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _param1Ctrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: _selectedShape == 'Circle' ? 'Radius (r)' : 'Length / Base', border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    if (_selectedShape != 'Circle') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _param2Ctrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: _selectedShape == 'Rectangle' ? 'Width (w)' : 'Height (h)', border: const OutlineInputBorder()),
                        onChanged: (_) => _calculate(),
                      ),
                    ],
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
