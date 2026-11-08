import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class AgeCalculatorScreen extends ConsumerStatefulWidget {
  const AgeCalculatorScreen({super.key});

  @override
  ConsumerState<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends ConsumerState<AgeCalculatorScreen> {
  DateTime _birthDate = DateTime(2000, 1, 1);
  DateTime _targetDate = DateTime.now();

  Future<void> _pickDate(bool isBirth) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isBirth ? _birthDate : _targetDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isBirth) {
          _birthDate = picked;
        } else {
          _targetDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('age_calc');

    DateTime s = _birthDate;
    DateTime e = _targetDate;

    if (e.isBefore(s)) {
      final temp = s;
      s = e;
      e = temp;
    }

    int years = e.year - s.year;
    int months = e.month - s.month;
    int days = e.day - s.day;

    if (days < 0) {
      months--;
      days += DateTime(e.year, e.month, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    int totalDays = e.difference(s).inDays;
    int totalMonths = (years * 12) + months;
    int totalWeeks = totalDays ~/ 7;
    int totalHours = totalDays * 24;

    // Next Birthday calculation
    DateTime today = DateTime(_targetDate.year, _targetDate.month, _targetDate.day);
    DateTime nextBday = DateTime(today.year, _birthDate.month, _birthDate.day);
    if (nextBday.isBefore(today)) {
      nextBday = DateTime(today.year + 1, _birthDate.month, _birthDate.day);
    }
    int daysToNextBday = nextBday.difference(today).inDays;

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Exact Age Card
            Card(
              color: Colors.indigo.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(langNotifier.translate('your_exact_age'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '$years ${langNotifier.translate('years_unit')}, $months ${langNotifier.translate('months_unit')}, $days ${langNotifier.translate('days_unit')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Text(
                      '${langNotifier.translate('next_birthday')}: $daysToNextBday ${langNotifier.translate('days_unit')}',
                      style: const TextStyle(fontSize: 16, color: Colors.lightGreenAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date Selection Pickers
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.cake, color: Colors.indigo),
                      title: Text(langNotifier.translate('date_of_birth')),
                      subtitle: Text(DateFormat('dd MMMM yyyy').format(_birthDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: ElevatedButton(
                        onPressed: () => _pickDate(true),
                        child: Text(langNotifier.translate('pick_date')),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.event, color: Colors.teal),
                      title: Text(langNotifier.translate('target_date')),
                      subtitle: Text(DateFormat('dd MMMM yyyy').format(_targetDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: ElevatedButton(
                        onPressed: () => _pickDate(false),
                        child: Text(langNotifier.translate('pick_date')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Extra Stats Summary Grid
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatRow(langNotifier.translate('total_months'), '$totalMonths ${langNotifier.translate('months_unit')}'),
                    const Divider(height: 16),
                    _buildStatRow(langNotifier.translate('total_weeks'), '$totalWeeks ${langNotifier.translate('days_unit')}'),
                    const Divider(height: 16),
                    _buildStatRow(langNotifier.translate('total_days'), '$totalDays ${langNotifier.translate('days_unit')}'),
                    const Divider(height: 16),
                    _buildStatRow(langNotifier.translate('total_hours'), '$totalHours'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo)),
      ],
    );
  }
}
