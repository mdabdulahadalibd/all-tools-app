import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tool_categories.dart';
import '../../../../../core/localization/localization_provider.dart';

class TallyCounterScreen extends ConsumerStatefulWidget {
  const TallyCounterScreen({super.key});

  @override
  ConsumerState<TallyCounterScreen> createState() => _TallyCounterScreenState();
}

class _TallyCounterScreenState extends ConsumerState<TallyCounterScreen> {
  int _counter = 0;

  void _increment() => setState(() => _counter++);
  void _decrement() {
    if (_counter > 0) setState(() => _counter--);
  }

  void _reset() => setState(() => _counter = 0);

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final tool = ToolCategories.getToolById('tally_counter_tool');

    return Scaffold(
      appBar: AppBar(
        title: Text(tool.getTitle(lang)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: langNotifier.translate('reset'),
            onPressed: _reset,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: InkWell(
                onTap: _increment,
                customBorder: const CircleBorder(),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_counter',
                        style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const SizedBox(height: 8),
                      Text(langNotifier.translate('tap_to_count'), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.large(
                  heroTag: 'dec',
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red,
                  onPressed: _decrement,
                  child: const Icon(Icons.remove, size: 36),
                ),
                const SizedBox(width: 32),
                FloatingActionButton.large(
                  heroTag: 'inc',
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  onPressed: _increment,
                  child: const Icon(Icons.add, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
