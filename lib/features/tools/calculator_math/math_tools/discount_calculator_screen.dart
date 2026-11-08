import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tool_categories.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../common/widgets/responsive_container.dart';

class DiscountCalculatorScreen extends ConsumerStatefulWidget {
  const DiscountCalculatorScreen({super.key});

  @override
  ConsumerState<DiscountCalculatorScreen> createState() => _DiscountCalculatorScreenState();
}

class _DiscountCalculatorScreenState extends ConsumerState<DiscountCalculatorScreen> {
  final TextEditingController _originalPriceCtrl = TextEditingController(text: '3000');
  final TextEditingController _discountPercentCtrl = TextEditingController(text: '20');

  double _savedAmount = 600.0;
  double _finalPrice = 2400.0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double price = double.tryParse(_originalPriceCtrl.text) ?? 0;
    double discount = double.tryParse(_discountPercentCtrl.text) ?? 0;

    double saved = (price * discount) / 100;
    setState(() {
      _savedAmount = saved;
      _finalPrice = price - saved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('discount_calc');

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
                child: Column(
                  children: [
                    Text(langNotifier.translate('final_sale_price'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '৳ ${_finalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Text(
                      '${langNotifier.translate('you_save')}: ৳ ${_savedAmount.toStringAsFixed(2)} (${_discountPercentCtrl.text}% Off)',
                      style: const TextStyle(fontSize: 16, color: Colors.amberAccent, fontWeight: FontWeight.bold),
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
                      controller: _originalPriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('original_price'), border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _discountPercentCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('discount_rate'), border: const OutlineInputBorder()),
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
