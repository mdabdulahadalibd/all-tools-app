import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class GcdLcmScreen extends ConsumerStatefulWidget {
  const GcdLcmScreen({super.key});

  @override
  ConsumerState<GcdLcmScreen> createState() => _GcdLcmScreenState();
}

class _GcdLcmScreenState extends ConsumerState<GcdLcmScreen> {
  final TextEditingController _num1Ctrl = TextEditingController(text: '24');
  final TextEditingController _num2Ctrl = TextEditingController(text: '36');

  int _gcd = 12;
  int _lcm = 72;

  int _calcGcd(int a, int b) {
    while (b != 0) {
      var t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  void _calculate() {
    int a = int.tryParse(_num1Ctrl.text) ?? 0;
    int b = int.tryParse(_num2Ctrl.text) ?? 0;

    if (a <= 0 || b <= 0) return;

    int g = _calcGcd(a, b);
    int l = (a * b) ~/ g;

    setState(() {
      _gcd = g;
      _lcm = l;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('gcd_lcm_calc');

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('GCD (গ.সা.গু)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('$_gcd', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('LCM (ল.সা.গু)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('$_lcm', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
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
                      controller: _num1Ctrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'First Integer Number', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _num2Ctrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Second Integer Number', border: OutlineInputBorder()),
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
