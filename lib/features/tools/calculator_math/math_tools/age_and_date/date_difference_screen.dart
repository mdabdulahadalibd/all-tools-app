import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class DateDifferenceScreen extends ConsumerStatefulWidget {
  const DateDifferenceScreen({super.key});

  @override
  ConsumerState<DateDifferenceScreen> createState() => _DateDifferenceScreenState();
}

class _DateDifferenceScreenState extends ConsumerState<DateDifferenceScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('date_diff_calc');

    DateTime s = _startDate;
    DateTime e = _endDate;

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
    int totalWeeks = totalDays ~/ 7;

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
                child: Column(
                  children: [
                    Text(langNotifier.translate('date_duration'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '$years ${langNotifier.translate('years_unit')}, $months ${langNotifier.translate('months_unit')}, $days ${langNotifier.translate('days_unit')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Text(
                      'Total $totalDays ${langNotifier.translate('days_unit')} ($totalWeeks Weeks)',
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: Colors.teal),
                      title: Text(langNotifier.translate('date_from')),
                      subtitle: Text(DateFormat('dd MMMM yyyy').format(_startDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: ElevatedButton(
                        onPressed: () => _pickDate(true),
                        child: Text(langNotifier.translate('pick_date')),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.event_available, color: Colors.blue),
                      title: Text(langNotifier.translate('date_to')),
                      subtitle: Text(DateFormat('dd MMMM yyyy').format(_endDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: ElevatedButton(
                        onPressed: () => _pickDate(false),
                        child: Text(langNotifier.translate('pick_date')),
                      ),
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
