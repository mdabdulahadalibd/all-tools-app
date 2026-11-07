import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_expressions/math_expressions.dart';

// --- 1. Basic Calculator State & Notifier ---
class BasicCalcState {
  final String expression;
  final String result;

  const BasicCalcState({
    this.expression = '',
    this.result = '0',
  });

  BasicCalcState copyWith({String? expression, String? result}) {
    return BasicCalcState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
    );
  }
}

class BasicCalcNotifier extends StateNotifier<BasicCalcState> {
  BasicCalcNotifier() : super(const BasicCalcState());

  void pressKey(String key) {
    if (key == 'AC') {
      state = const BasicCalcState();
    } else if (key == '⌫') {
      if (state.expression.isNotEmpty) {
        final newExpr = state.expression.substring(0, state.expression.length - 1);
        state = state.copyWith(expression: newExpr);
      }
    } else if (key == '=') {
      _evaluate();
    } else if (key == '±') {
      if (state.expression.startsWith('-')) {
        state = state.copyWith(expression: state.expression.substring(1));
      } else if (state.expression.isNotEmpty) {
        state = state.copyWith(expression: '-${state.expression}');
      }
    } else {
      state = state.copyWith(expression: state.expression + key);
    }
  }

  void _evaluate() {
    try {
      String parsed = state.expression.replaceAll('×', '*').replaceAll('÷', '/');
      if (parsed.isEmpty) return;
      GrammarParser p = GrammarParser();
      Expression exp = p.parse(parsed);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      String res = eval.toStringAsFixed(eval.truncateToDouble() == eval ? 0 : 4);
      state = state.copyWith(result: res);
    } catch (_) {
      state = state.copyWith(result: 'Error');
    }
  }
}

final basicCalcProvider = StateNotifierProvider<BasicCalcNotifier, BasicCalcState>((ref) {
  return BasicCalcNotifier();
});

// --- 2. Scientific Calculator State & Notifier ---
class SciCalcState {
  final String expression;
  final String history;
  final bool isDeg;
  final bool isScientificMode;

  const SciCalcState({
    this.expression = '',
    this.history = '',
    this.isDeg = true,
    this.isScientificMode = true,
  });

  SciCalcState copyWith({
    String? expression,
    String? history,
    bool? isDeg,
    bool? isScientificMode,
  }) {
    return SciCalcState(
      expression: expression ?? this.expression,
      history: history ?? this.history,
      isDeg: isDeg ?? this.isDeg,
      isScientificMode: isScientificMode ?? this.isScientificMode,
    );
  }
}

class SciCalcNotifier extends StateNotifier<SciCalcState> {
  SciCalcNotifier() : super(const SciCalcState());

  static const Set<String> _functions = {'sin', 'cos', 'tan', 'log', 'ln', 'sqrt'};
  static const String _operators = '÷×−+^';

  void toggleDeg() {
    state = state.copyWith(isDeg: !state.isDeg);
  }

  void toggleMode() {
    state = state.copyWith(isScientificMode: !state.isScientificMode);
  }

  void pressKey(String key) {
    if (key == 'C') {
      state = state.copyWith(expression: '', history: '');
    } else if (key == '⌫') {
      if (state.expression.isNotEmpty) {
        state = state.copyWith(expression: state.expression.substring(0, state.expression.length - 1));
      }
    } else if (key == '=') {
      final res = evaluate(state.expression, state.isDeg);
      if (res != null) {
        state = state.copyWith(history: '${state.expression} =', expression: res);
      } else if (state.expression.isNotEmpty) {
        state = state.copyWith(history: 'Invalid Syntax');
      }
    } else if (key == 'DEG' || key == 'RAD') {
      toggleDeg();
    } else {
      String addStr = _functions.contains(key) ? '$key(' : key;
      if (key == '( )') {
        final openCount = '('.allMatches(state.expression).length;
        final closeCount = ')'.allMatches(state.expression).length;
        final lastChar = state.expression.isEmpty ? '' : state.expression[state.expression.length - 1];
        addStr = (state.expression.isEmpty || _operators.contains(lastChar) || lastChar == '(')
            ? '('
            : (openCount > closeCount ? ')' : '(');
      }
      state = state.copyWith(expression: state.expression + addStr, history: '');
    }
  }

  static String? evaluate(String expr, bool isDeg) {
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

      if (isDeg) {
        for (final f in ['sin', 'cos', 'tan']) {
          s = _wrapFunc(s, f, '$f((', ')*0.017453292519943295)');
        }
      }
      s = _wrapFunc(s, 'log', '(0.4342944819032518*ln(', '))');

      final resultVal = ShuntingYardParser().parse(s).evaluate(EvaluationType.REAL, ContextModel());
      final double doubleVal = (resultVal as num).toDouble();
      if (!doubleVal.isFinite) return null;
      return doubleVal.toStringAsFixed(doubleVal.truncateToDouble() == doubleVal ? 0 : 4);
    } catch (_) {
      return null;
    }
  }

  static String _wrapFunc(String s, String f, String pre, String post) {
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
}

final sciCalcProvider = StateNotifierProvider<SciCalcNotifier, SciCalcState>((ref) {
  return SciCalcNotifier();
});

// --- 3. Age Calculator State Provider ---
final birthDateProvider = StateProvider<DateTime>((ref) => DateTime(2000, 1, 1));
