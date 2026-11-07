import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class BasicCalculatorScreen extends StatefulWidget {
  const BasicCalculatorScreen({super.key});

  @override
  State<BasicCalculatorScreen> createState() => _BasicCalculatorScreenState();
}

class _BasicCalculatorScreenState extends State<BasicCalculatorScreen> {
  String _expression = '';
  String _result = '0';

  void _onBtnPress(String val) {
    setState(() {
      if (val == 'AC') {
        _expression = '';
        _result = '0';
      } else if (val == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (val == '=') {
        _evaluate();
      } else if (val == '±') {
        if (_expression.startsWith('-')) {
          _expression = _expression.substring(1);
        } else if (_expression.isNotEmpty) {
          _expression = '-$_expression';
        }
      } else {
        _expression += val;
      }
    });
  }

  void _evaluate() {
    try {
      String parsed = _expression.replaceAll('×', '*').replaceAll('÷', '/');
      if (parsed.isEmpty) return;
      GrammarParser p = GrammarParser();
      Expression exp = p.parse(parsed);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        _result = eval.toStringAsFixed(eval.truncateToDouble() == eval ? 0 : 4);
      });
    } catch (e) {
      setState(() => _result = 'Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Calculator')),
      body: SafeArea(
        child: Column(
          children: [
            // Display Area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _expression.isEmpty ? '0' : _expression,
                        style: const TextStyle(fontSize: 32, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _result,
                        style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // Keypad
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    _buildRow(['AC', '±', '%', '÷'], isTop: true),
                    _buildRow(['7', '8', '9', '×']),
                    _buildRow(['4', '5', '6', '-']),
                    _buildRow(['1', '2', '3', '+']),
                    _buildRow(['0', '.', '⌫', '=']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> keys, {bool isTop = false}) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: keys.map((key) {
          bool isOp = ['÷', '×', '-', '+', '='].contains(key);
          bool isAction = ['AC', '±', '%', '⌫'].contains(key);

          Color bg = isOp
              ? Colors.orange
              : (isAction ? Colors.blueGrey.shade100 : Theme.of(context).colorScheme.surfaceContainerHigh);

          Color textCol = isOp ? Colors.white : (isAction ? Colors.black87 : Theme.of(context).colorScheme.onSurface);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: bg,
                  foregroundColor: textCol,
                  elevation: isOp ? 4 : 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () => _onBtnPress(key),
                child: Text(
                  key,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textCol),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
