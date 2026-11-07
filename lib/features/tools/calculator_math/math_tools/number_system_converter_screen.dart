import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';

class NumberSystemConverterScreen extends ConsumerStatefulWidget {
  const NumberSystemConverterScreen({super.key});

  @override
  ConsumerState<NumberSystemConverterScreen> createState() => _NumberSystemConverterScreenState();
}

class _NumberSystemConverterScreenState extends ConsumerState<NumberSystemConverterScreen> {
  final TextEditingController _decimalCtrl = TextEditingController(text: '255');

  String _binary = '11111111';
  String _octal = '377';
  String _hex = 'FF';

  void _convert() {
    int val = int.tryParse(_decimalCtrl.text) ?? 0;
    setState(() {
      _binary = val.toRadixString(2);
      _octal = val.toRadixString(8);
      _hex = val.toRadixString(16).toUpperCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('number_system_converter');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _decimalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Decimal Integer Input (Base 10)', border: OutlineInputBorder()),
                  onChanged: (_) => _convert(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.indigo.shade900,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(title: const Text('Binary (Base 2)', style: TextStyle(color: Colors.white70)), subtitle: SelectableText(_binary, style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 20))),
                    const Divider(color: Colors.white24),
                    ListTile(title: const Text('Octal (Base 8)', style: TextStyle(color: Colors.white70)), subtitle: SelectableText(_octal, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 20))),
                    const Divider(color: Colors.white24),
                    ListTile(title: const Text('Hexadecimal (Base 16)', style: TextStyle(color: Colors.white70)), subtitle: SelectableText(_hex, style: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 20))),
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
