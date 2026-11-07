import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class TipSplitBillScreen extends ConsumerStatefulWidget {
  const TipSplitBillScreen({super.key});

  @override
  ConsumerState<TipSplitBillScreen> createState() => _TipSplitBillScreenState();
}

class _TipSplitBillScreenState extends ConsumerState<TipSplitBillScreen> {
  final TextEditingController _billAmountCtrl = TextEditingController(text: '2400');
  double _tipPercent = 10;
  int _numberOfPeople = 4;

  double _totalBillWithTip = 0.0;
  double _amountPerPerson = 0.0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double bill = double.tryParse(_billAmountCtrl.text) ?? 0;
    double tipAmount = (bill * _tipPercent) / 100;
    double total = bill + tipAmount;

    setState(() {
      _totalBillWithTip = total;
      _amountPerPerson = _numberOfPeople > 0 ? total / _numberOfPeople : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('tip_split_bill_calc');

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.teal.shade800,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Amount Per Person', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '৳ ${_amountPerPerson.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Text(
                      'Total Bill with ${_tipPercent.toInt()}% Tip: ৳ ${_totalBillWithTip.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _billAmountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Total Bill Amount (৳)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 16),
                    Text('Tip Percentage: ${_tipPercent.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _tipPercent,
                      min: 0,
                      max: 30,
                      divisions: 30,
                      onChanged: (val) {
                        setState(() => _tipPercent = val);
                        _calculate();
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Split Among People:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (_numberOfPeople > 1) {
                                  setState(() => _numberOfPeople--);
                                  _calculate();
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('$_numberOfPeople', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                            IconButton.filledTonal(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() => _numberOfPeople++);
                                _calculate();
                              },
                            ),
                          ],
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
