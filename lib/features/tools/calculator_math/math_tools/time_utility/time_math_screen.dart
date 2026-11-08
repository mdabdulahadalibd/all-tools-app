import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class TimeMathScreen extends ConsumerStatefulWidget {
  const TimeMathScreen({super.key});

  @override
  ConsumerState<TimeMathScreen> createState() => _TimeMathScreenState();
}

class _TimeMathScreenState extends ConsumerState<TimeMathScreen> {
  final TextEditingController _h1Ctrl = TextEditingController(text: '2');
  final TextEditingController _m1Ctrl = TextEditingController(text: '45');

  final TextEditingController _h2Ctrl = TextEditingController(text: '1');
  final TextEditingController _m2Ctrl = TextEditingController(text: '30');

  bool _isAdd = true;
  String _resultStr = '4 Hours 15 Minutes';

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    int h1 = int.tryParse(_h1Ctrl.text) ?? 0;
    int m1 = int.tryParse(_m1Ctrl.text) ?? 0;
    int h2 = int.tryParse(_h2Ctrl.text) ?? 0;
    int m2 = int.tryParse(_m2Ctrl.text) ?? 0;

    int totalMinutes1 = (h1 * 60) + m1;
    int totalMinutes2 = (h2 * 60) + m2;

    int totalMins = _isAdd ? (totalMinutes1 + totalMinutes2) : (totalMinutes1 - totalMinutes2);
    if (totalMins < 0) totalMins = 0;

    int hrs = totalMins ~/ 60;
    int mins = totalMins % 60;

    setState(() {
      _resultStr = '$hrs Hours $mins Minutes';
    });
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('time_math_calc');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.indigo.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(langNotifier.translate('total_time_duration'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      _resultStr,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.amberAccent),
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
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Add Time (+)'),
                            selected: _isAdd,
                            onSelected: (v) {
                              if (v) {
                                setState(() => _isAdd = true);
                                _calculate();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Subtract Time (-)'),
                            selected: !_isAdd,
                            onSelected: (v) {
                              if (v) {
                                setState(() => _isAdd = false);
                                _calculate();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _h1Ctrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Time 1 (Hours)', border: OutlineInputBorder()),
                            onChanged: (_) => _calculate(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _m1Ctrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Time 1 (Minutes)', border: OutlineInputBorder()),
                            onChanged: (_) => _calculate(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _h2Ctrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Time 2 (Hours)', border: OutlineInputBorder()),
                            onChanged: (_) => _calculate(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _m2Ctrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Time 2 (Minutes)', border: OutlineInputBorder()),
                            onChanged: (_) => _calculate(),
                          ),
                        ),
                      ],
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
