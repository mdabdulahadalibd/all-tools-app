import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../common/widgets/responsive_container.dart';

class TimezoneConverterScreen extends ConsumerStatefulWidget {
  const TimezoneConverterScreen({super.key});

  @override
  ConsumerState<TimezoneConverterScreen> createState() => _TimezoneConverterScreenState();
}

class _TimezoneConverterScreenState extends ConsumerState<TimezoneConverterScreen> {
  String _fromZone = 'BST (Bangladesh UTC+6)';
  String _toZone = 'EST (New York UTC-5)';

  final Map<String, int> _zoneOffsetsHours = {
    'BST (Bangladesh UTC+6)': 6,
    'EST (New York UTC-5)': -5,
    'PST (California UTC-8)': -8,
    'GMT / UTC (London UTC+0)': 0,
    'IST (India UTC+5:30)': 5,
    'SGT (Singapore UTC+8)': 8,
    'JST (Tokyo UTC+9)': 9,
  };

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('timezone_converter_calc');

    int fromOffset = _zoneOffsetsHours[_fromZone] ?? 6;
    int toOffset = _zoneOffsetsHours[_toZone] ?? -5;
    int diffHours = toOffset - fromOffset;

    DateTime nowBst = DateTime.now().toUtc().add(Duration(hours: fromOffset));
    DateTime targetTime = nowBst.add(Duration(hours: diffHours));

    return Scaffold(
      appBar: AppBar(title: Text(tool.getTitle(lang)), centerTitle: true),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.blueGrey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('${langNotifier.translate('target_time')} ($_toZone)', style: const TextStyle(color: Colors.white70, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(
                      '${targetTime.hour.toString().padLeft(2, '0')}:${targetTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Text(
                      '${langNotifier.translate('time_offset_diff')}: ${diffHours >= 0 ? "+$diffHours" : diffHours} Hours',
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
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _fromZone,
                      decoration: InputDecoration(labelText: langNotifier.translate('from_time_zone'), border: const OutlineInputBorder()),
                      items: _zoneOffsetsHours.keys.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _fromZone = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _toZone,
                      decoration: InputDecoration(labelText: langNotifier.translate('to_time_zone'), border: const OutlineInputBorder()),
                      items: _zoneOffsetsHours.keys.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _toZone = v);
                      },
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
