import 'package:flutter/material.dart';
import '../../../../common/widgets/responsive_container.dart';

class CalorieMacroScreen extends StatefulWidget {
  const CalorieMacroScreen({super.key});

  @override
  State<CalorieMacroScreen> createState() => _CalorieMacroScreenState();
}

class _CalorieMacroScreenState extends State<CalorieMacroScreen> {
  final TextEditingController _weightKgCtrl = TextEditingController(text: '70');
  final TextEditingController _heightCmCtrl = TextEditingController(text: '172');
  final TextEditingController _ageCtrl = TextEditingController(text: '25');

  double _tdeeCalories = 2200;
  double _proteinGrams = 140;
  double _carbsGrams = 220;
  double _fatsGrams = 73;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double w = double.tryParse(_weightKgCtrl.text) ?? 70;
    double h = double.tryParse(_heightCmCtrl.text) ?? 172;
    double a = double.tryParse(_ageCtrl.text) ?? 25;

    // Mifflin-St Jeor Formula
    double bmr = (10 * w) + (6.25 * h) - (5 * a) + 5;
    double tdee = bmr * 1.375; // Lightly active

    setState(() {
      _tdeeCalories = tdee;
      _proteinGrams = w * 2.0; // 2g per kg
      _fatsGrams = (tdee * 0.3) / 9;
      _carbsGrams = (tdee - (_proteinGrams * 4 + _fatsGrams * 9)) / 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calorie & Macro Calculator')),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.deepOrange.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Daily Maintenance Calories (TDEE)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '${_tdeeCalories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [const Text('Protein', style: TextStyle(color: Colors.white70)), Text('${_proteinGrams.toStringAsFixed(0)}g', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))]),
                        Column(children: [const Text('Carbs', style: TextStyle(color: Colors.white70)), Text('${_carbsGrams.toStringAsFixed(0)}g', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))]),
                        Column(children: [const Text('Fats', style: TextStyle(color: Colors.white70)), Text('${_fatsGrams.toStringAsFixed(0)}g', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))]),
                      ],
                    ),
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
                    TextField(
                      controller: _weightKgCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _heightCmCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Height (cm)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Age (Years)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
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
