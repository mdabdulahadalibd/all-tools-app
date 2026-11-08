import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class Shape3dVolumeScreen extends ConsumerStatefulWidget {
  const Shape3dVolumeScreen({super.key});

  @override
  ConsumerState<Shape3dVolumeScreen> createState() => _Shape3dVolumeScreenState();
}

class _Shape3dVolumeScreenState extends ConsumerState<Shape3dVolumeScreen> {
  String _selectedShape = 'Cylinder';
  final TextEditingController _rCtrl = TextEditingController(text: '5');
  final TextEditingController _hCtrl = TextEditingController(text: '10');

  double _volume = 785.40;
  double _surfaceArea = 471.24;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double r = double.tryParse(_rCtrl.text) ?? 0;
    double h = double.tryParse(_hCtrl.text) ?? 0;

    if (_selectedShape == 'Cylinder') {
      setState(() {
        _volume = pi * r * r * h;
        _surfaceArea = 2 * pi * r * (r + h);
      });
    } else if (_selectedShape == 'Sphere') {
      setState(() {
        _volume = (4 / 3) * pi * pow(r, 3);
        _surfaceArea = 4 * pi * r * r;
      });
    } else if (_selectedShape == 'Cube') {
      double a = r;
      setState(() {
        _volume = pow(a, 3).toDouble();
        _surfaceArea = 6 * a * a;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('volume_3d_shape_calc');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.brown.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [Text(langNotifier.translate('volume_3d'), style: const TextStyle(color: Colors.white70)), Text(_volume.toStringAsFixed(2), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.amberAccent))]),
                    Column(children: [Text(langNotifier.translate('surface_area_3d'), style: const TextStyle(color: Colors.white70)), Text(_surfaceArea.toStringAsFixed(2), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent))]),
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
                      decoration: const InputDecoration(labelText: 'Select 3D Shape', border: OutlineInputBorder()),
                      items: ['Cylinder', 'Sphere', 'Cube'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedShape = val);
                          _calculate();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _rCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: _selectedShape == 'Cube' ? 'Side Length (a)' : 'Radius (r)', border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    if (_selectedShape == 'Cylinder') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _hCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Height (h)', border: OutlineInputBorder()),
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
