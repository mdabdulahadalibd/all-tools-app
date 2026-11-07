import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';

class GpaCalculatorScreen extends ConsumerStatefulWidget {
  const GpaCalculatorScreen({super.key});

  @override
  ConsumerState<GpaCalculatorScreen> createState() => _GpaCalculatorScreenState();
}

class _GpaCalculatorScreenState extends ConsumerState<GpaCalculatorScreen> {
  final List<Map<String, dynamic>> _subjects = [
    {'subject': 'Bangla', 'gpa': 5.0},
    {'subject': 'English', 'gpa': 4.0},
    {'subject': 'Mathematics', 'gpa': 5.0},
    {'subject': 'Science', 'gpa': 5.0},
  ];

  double get _calculatedGpa {
    if (_subjects.isEmpty) return 0.0;
    double sum = _subjects.fold(0, (total, item) => total + (item['gpa'] as double));
    return sum / _subjects.length;
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('gpa_calc');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.blue.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Total Average GPA', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      _calculatedGpa.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ..._subjects.asMap().entries.map((entry) {
              int idx = entry.key;
              var sub = entry.value;
              return Card(
                child: ListTile(
                  title: Text(sub['subject'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('GPA Grade: ${sub['gpa']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _subjects.removeAt(idx)),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
