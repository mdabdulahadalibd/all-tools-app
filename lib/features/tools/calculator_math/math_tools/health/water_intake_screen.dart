import 'package:flutter/material.dart';
import '../../../../common/widgets/responsive_container.dart';

class WaterIntakeScreen extends StatefulWidget {
  const WaterIntakeScreen({super.key});

  @override
  State<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen> {
  final TextEditingController _weightKgCtrl = TextEditingController(text: '68');
  double _waterLiters = 2.4;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double w = double.tryParse(_weightKgCtrl.text) ?? 68;
    // ~35ml per kg of body weight
    double liters = (w * 35) / 1000;

    setState(() => _waterLiters = liters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Water Intake Calculator')),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.lightBlue.shade800,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.water_drop, size: 48, color: Colors.white),
                    const SizedBox(height: 8),
                    const Text('Recommended Daily Water', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '${_waterLiters.toStringAsFixed(1)} Liters / Day',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '(${(_waterLiters * 4).toStringAsFixed(0)} Glasses of 250ml)',
                      style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _weightKgCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Body Weight (kg)', border: OutlineInputBorder()),
                  onChanged: (_) => _calculate(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
