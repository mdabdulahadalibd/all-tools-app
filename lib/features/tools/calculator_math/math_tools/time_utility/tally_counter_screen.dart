import 'package:flutter/material.dart';

class TallyCounterScreen extends StatefulWidget {
  const TallyCounterScreen({super.key});

  @override
  State<TallyCounterScreen> createState() => _TallyCounterScreenState();
}

class _TallyCounterScreenState extends State<TallyCounterScreen> {
  int _counter = 0;

  void _increment() => setState(() => _counter++);
  void _decrement() {
    if (_counter > 0) setState(() => _counter--);
  }

  void _reset() => setState(() => _counter = 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Tally Counter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Count',
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
                      const Text('Tap to Count', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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
