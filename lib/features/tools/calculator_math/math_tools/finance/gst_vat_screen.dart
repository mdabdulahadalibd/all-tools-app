import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class GstVatScreen extends ConsumerStatefulWidget {
  const GstVatScreen({super.key});

  @override
  ConsumerState<GstVatScreen> createState() => _GstVatScreenState();
}

class _GstVatScreenState extends ConsumerState<GstVatScreen> {
  final TextEditingController _amountCtrl = TextEditingController(text: '1000');
  final TextEditingController _taxRateCtrl = TextEditingController(text: '15');
  bool _isAddTax = true;

  double _taxAmount = 0.0;
  double _finalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double amount = double.tryParse(_amountCtrl.text) ?? 0;
    double rate = double.tryParse(_taxRateCtrl.text) ?? 0;

    if (_isAddTax) {
      double tax = (amount * rate) / 100;
      setState(() {
        _taxAmount = tax;
        _finalAmount = amount + tax;
      });
    } else {
      double originalAmount = amount / (1 + (rate / 100));
      double tax = amount - originalAmount;
      setState(() {
        _taxAmount = tax;
        _finalAmount = originalAmount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('gst_vat_tax_calc');

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
                    Text(_isAddTax ? langNotifier.translate('final_price_inc_tax') : langNotifier.translate('base_price_excl_tax'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '৳ ${_finalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Text(
                      '${langNotifier.translate('calculated_tax_amount')}: ৳ ${_taxAmount.toStringAsFixed(2)}',
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
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text(langNotifier.translate('add_tax')),
                            selected: _isAddTax,
                            onSelected: (val) {
                              if (val) {
                                setState(() => _isAddTax = true);
                                _calculate();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(langNotifier.translate('remove_tax')),
                            selected: !_isAddTax,
                            onSelected: (val) {
                              if (val) {
                                setState(() => _isAddTax = false);
                                _calculate();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('amount_bdt'), border: const OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _taxRateCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: langNotifier.translate('gst_vat_rate'), border: const OutlineInputBorder()),
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
