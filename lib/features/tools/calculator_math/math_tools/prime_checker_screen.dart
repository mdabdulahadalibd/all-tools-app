import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';

class PrimeCheckerScreen extends ConsumerStatefulWidget {
  const PrimeCheckerScreen({super.key});

  @override
  ConsumerState<PrimeCheckerScreen> createState() => _PrimeCheckerScreenState();
}

class _PrimeCheckerScreenState extends ConsumerState<PrimeCheckerScreen> {
  final TextEditingController _numCtrl = TextEditingController(text: '29');

  bool _isPrime = true;
  String _message = '29 is a Prime Number!';

  void _checkPrime() {
    int n = int.tryParse(_numCtrl.text) ?? 0;

    if (n <= 1) {
      setState(() {
        _isPrime = false;
        _message = '$n is Not a Prime Number.';
      });
      return;
    }

    bool isP = true;
    for (int i = 2; i <= sqrt(n); i++) {
      if (n % i == 0) {
        isP = false;
        break;
      }
    }

    setState(() {
      _isPrime = isP;
      _message = isP ? '$n is a Prime Number! 🎉' : '$n is Not a Prime Number.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('prime_checker');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: _isPrime ? Colors.green.shade900 : Colors.red.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(_message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _numCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Enter Integer Number to Check', border: OutlineInputBorder()),
                  onChanged: (_) => _checkPrime(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
