import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../../../common/widgets/responsive_container.dart';
import '../math_utils/math_utils.dart';

class ScientificCalculatorScreen extends StatefulWidget {
  final Tool? tool;
  const ScientificCalculatorScreen(this.tool, {super.key});

  @override
  State<ScientificCalculatorScreen> createState() => _ScientificCalculatorScreenState();
}

class _ScientificCalculatorScreenState extends State<ScientificCalculatorScreen> {
  String _expression = '';
  String _history = '';
  bool _isScientificMode = true;
  bool _isDeg = true;
  bool _isEvaluated = false;

  static const Set<String> _functions = {'sin', 'cos', 'tan', 'log', 'ln', 'sqrt'};
  static const String _operators = '÷×−+^';

  String _wrapFunc(String s, String f, String pre, String post) {
    int i = 0;
    while ((i = s.indexOf('$f(', i)) != -1) {
      final st = i + f.length + 1;
      int j = st, depth = 1;
      while (j < s.length && depth > 0) {
        if (s[j] == '(') {
          depth++;
        } else if (s[j] == ')') {
          depth--;
        }
        j++;
      }
      s = s.substring(0, i) + pre + s.substring(st, j - 1) + post + s.substring(j);
      i += pre.length;
    }
    return s;
  }

  String? _evaluateExpression(String expr) {
    if (expr.isEmpty) return null;
    try {
      String s = expr;
      final openCount = '('.allMatches(s).length - ')'.allMatches(s).length;
      if (openCount > 0) s += ')' * openCount;

      s = s.replaceAllMapped(RegExp(r'([\d\)πe])(?=[(πesctl])|([\)πe])(?=\d)'), (m) => '${m[0]}*');
      s = s
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('−', '-')
          .replaceAll('%', '/100')
          .replaceAll('π', '3.141592653589793')
          .replaceAll('e', '2.718281828459045');

      if (_isDeg) {
        for (final f in ['sin', 'cos', 'tan']) {
          s = _wrapFunc(s, f, '$f((', ')*0.017453292519943295)');
        }
      }
      s = _wrapFunc(s, 'log', '(0.4342944819032518*ln(', '))');

      final resultVal = ShuntingYardParser().parse(s).evaluate(EvaluationType.REAL, ContextModel());
      final double doubleVal = (resultVal as num).toDouble();
      return doubleVal.isFinite ? fmt(doubleVal, 8) : null;
    } catch (_) {
      return null;
    }
  }

  void _onPressKey(String key) {
    setState(() {
      if (key == 'C') {
        _expression = '';
        _history = '';
        _isEvaluated = false;
      } else if (key == '⌫') {
        if (_isEvaluated) {
          _expression = '';
          _isEvaluated = false;
        } else if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (key == '=') {
        final result = _evaluateExpression(_expression);
        if (result != null) {
          _history = '$_expression =';
          _expression = result;
          _isEvaluated = true;
        } else if (_expression.isNotEmpty) {
          _history = 'Invalid Syntax';
        }
      } else if (key == 'DEG' || key == 'RAD') {
        _isDeg = !_isDeg;
      } else {
        final isOp = _operators.contains(key) || key == '%';
        if (_isEvaluated && !isOp) _expression = '';
        _isEvaluated = false;

        String addStr = _functions.contains(key) ? '$key(' : key;
        if (key == '( )') {
          final openCount = '('.allMatches(_expression).length;
          final closeCount = ')'.allMatches(_expression).length;
          final lastChar = _expression.isEmpty ? '' : _expression[_expression.length - 1];
          addStr = (_expression.isEmpty || _operators.contains(lastChar) || lastChar == '(')
              ? '('
              : (openCount > closeCount ? ')' : '(');
        }
        _expression += addStr;
        _history = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final liveEval = _isEvaluated ? null : _evaluateExpression(_expression);

    final keyLayout = <List<String>>[
      if (_isScientificMode) ...[
        [_isDeg ? 'DEG' : 'RAD', 'sin', 'cos', 'tan'],
        ['log', 'ln', 'sqrt', '^'],
        ['π', 'e', '(', ')'],
      ],
      ['C', '⌫', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '−'],
      ['1', '2', '3', '+'],
      ['( )', '0', '.', '='],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scientific Calculator'),
        actions: [
          IconButton(
            tooltip: _isScientificMode ? 'Standard Mode' : 'Scientific Mode',
            icon: Icon(_isScientificMode ? Icons.calculate : Icons.functions, color: Colors.blue),
            onPressed: () => setState(() => _isScientificMode = !_isScientificMode),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: 600,
        child: Column(
          children: [
            // Top Display Card
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade900, Colors.blue.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _isDeg ? 'DEG' : 'RAD',
                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _history,
                            style: const TextStyle(fontSize: 16, color: Colors.white60),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _expression.isEmpty ? '0' : _expression,
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    if (liveEval != null && liveEval != _expression)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '= $liveEval',
                          style: const TextStyle(fontSize: 22, color: Colors.lightGreenAccent, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Keypad Buttons
            Expanded(
              flex: _isScientificMode ? 8 : 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: keyLayout.map((row) {
                    return Expanded(
                      child: Row(
                        children: row.map((key) => _buildKeyButton(key)).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyButton(String key) {
    Color bg = Theme.of(context).colorScheme.surfaceContainerHigh;
    Color fg = Theme.of(context).colorScheme.onSurface;

    if (key == '=') {
      bg = Colors.blue;
      fg = Colors.white;
    } else if (key == 'C') {
      bg = Colors.red.shade100;
      fg = Colors.red.shade900;
    } else if (key == '⌫') {
      bg = Colors.orange.shade100;
      fg = Colors.orange.shade900;
    } else if (_operators.contains(key) || key == '%') {
      bg = Colors.blue.shade100;
      fg = Colors.blue.shade900;
    } else if (_functions.contains(key) || ['π', 'e', 'DEG', 'RAD', '(', ')'].contains(key)) {
      bg = Colors.purple.shade100;
      fg = Colors.purple.shade900;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            elevation: key == '=' ? 4 : 1,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => _onPressKey(key),
          child: Text(
            key == 'sqrt' ? '√' : key,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
