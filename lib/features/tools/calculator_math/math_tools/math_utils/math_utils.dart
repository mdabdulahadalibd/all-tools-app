import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../age_and_date/age_calculator_screen.dart';
import '../age_and_date/date_difference_screen.dart';
import '../scientific_calculator/scientific_calculator_screen.dart';

class Tool {
  final String enName, bnName;
  final IconData icon;
  final Color color;
  final Widget Function(Tool) page;
  const Tool(this.enName, this.bnName, this.icon, this.color, this.page);
  String title(bool bn) => bn ? bnName : enName;
}

AppBar bar(Tool t, {List<Widget>? actions}) => AppBar(
  title: Text(t.enName),
  actions: actions,
);

LinearGradient grad(Color c) => LinearGradient(
  colors: [c, Color.lerp(c, Colors.black, 0.35)!],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

Widget hero(Tool t, String subtitle, String value) => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(22),
  decoration: BoxDecoration(gradient: grad(t.color), borderRadius: BorderRadius.circular(24)),
  child: Column(
    children: [
      Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.white70)),
      const SizedBox(height: 6),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    ],
  ),
);

Widget rows(List<R> items) => Card(
  child: Column(
    children: items
        .map((i) => ListTile(
      title: Text(i.label),
      trailing: Text(i.value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ))
        .toList(),
  ),
);

class Pg extends StatelessWidget {
  final Tool t;
  final List<Widget> children;
  const Pg(this.t, this.children, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: bar(t),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList(),
      ),
    );
  }
}

class R {
  final String label, value;
  R(this.label, this.value);
}

class F {
  final String label, init;
  const F(this.label, this.init);
}

class FormCalc extends StatefulWidget {
  final Tool t;
  final List<F> fields;
  final List<R> Function(List<String>) calc;
  const FormCalc(this.t, this.fields, this.calc, {super.key});
  @override
  State<FormCalc> createState() => _FormCalcState();
}

class _FormCalcState extends State<FormCalc> {
  late List<TextEditingController> c = widget.fields.map((f) => TextEditingController(text: f.init)).toList();

  @override
  Widget build(BuildContext context) {
    final vals = c.map((e) => e.text).toList();
    final res = widget.calc(vals);
    return Pg(widget.t, [
      ...widget.fields.asMap().entries.map((e) => TextField(
        controller: c[e.key],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: e.value.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onChanged: (_) => setState(() {}),
      )),
      if (res.isNotEmpty) hero(widget.t, res.first.label, res.first.value),
      if (res.length > 1) rows(res.sublist(1)),
    ]);
  }
}

double n(String s) => double.tryParse(s) ?? 0;

String fmt(double d, [int decimals = 2]) {
  if (d.isNaN || d.isInfinite) return 'Error';
  final s = d.toStringAsFixed(decimals);
  return s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
}

String money(double d) => '৳ ${NumberFormat('#,##0.00').format(d)}';

int daysBetween(DateTime a, DateTime b) => b.difference(a).inDays;

bool isPrimeNum(int n) {
  if (n < 2) return false;
  for (var i = 2; i <= sqrt(n); i++) {
    if (n % i == 0) return false;
  }
  return true;
}

const radix = {'Binary': 2, 'Octal': 8, 'Decimal': 10, 'Hexadecimal': 16};

final tools = <Tool>[
  Tool('Scientific Calculator', 'সাইন্টিফিক ক্যালকুলেটর', Icons.calculate, Colors.indigo, (t) => ScientificCalculatorScreen(t)),
  Tool('Age Calculator', 'বয়স ক্যালকুলেটর', Icons.cake, Colors.pink, (t) => const AgeCalculatorScreen()),
  Tool('Date Difference', 'তারিখের পার্থক্য', Icons.date_range, Colors.teal, (t) => const DateDifferenceScreen()),
  Tool('Percentage & Discount', 'শতকরা ও ছাড়', Icons.percent, Colors.orange, (t) => FormCalc(t, const [
    F('Amount / Price (Y)', '1000'),
    F('Percent (X %)', '20'),
  ], (v) {
    final y = n(v[0]), x = n(v[1]), p = y * x / 100;
    return [
      R('${fmt(x)}% of ${fmt(y)}', fmt(p)),
      R('Price after discount', money(y - p)),
      R('You save', money(p)),
      R('Price after adding ${fmt(x)}%', money(y + p)),
    ];
  })),
  Tool('Profit & Loss', 'লাভ ও ক্ষতি', Icons.trending_up, Colors.green, (t) => FormCalc(t, const [
    F('Cost Price (CP)', '800'),
    F('Selling Price (SP)', '1000'),
  ], (v) {
    final cp = n(v[0]), sp = n(v[1]), diff = sp - cp;
    final pct = cp == 0 ? 0.0 : (diff / cp) * 100;
    return [
      R(diff >= 0 ? 'Profit' : 'Loss', money(diff.abs())),
      R('Profit / Loss Rate', '${fmt(pct)}%'),
    ];
  })),
  Tool('EMI / Loan', 'ইএমআই ও লোন', Icons.account_balance, Colors.blue, (t) => FormCalc(t, const [
    F('Principal Loan Amount', '100000'),
    F('Annual Interest Rate (%)', '9'),
    F('Tenure (Months)', '12'),
  ], (v) {
    final p = n(v[0]), r = n(v[1]) / 1200, nMonths = n(v[2]);
    if (p <= 0 || r <= 0 || nMonths <= 0) return [R('Monthly EMI', '৳ 0')];
    final emi = p * r * pow(1 + r, nMonths) / (pow(1 + r, nMonths) - 1);
    final total = emi * nMonths;
    return [
      R('Monthly EMI', money(emi)),
      R('Total Interest', money(total - p)),
      R('Total Payment', money(total)),
    ];
  })),
  Tool('BMI & BMR Health', 'বিএমআই ও বিএমআর', Icons.monitor_weight, Colors.red, (t) => FormCalc(t, const [
    F('Weight (kg)', '70'),
    F('Height (cm)', '175'),
    F('Age (years)', '25'),
  ], (v) {
    final w = n(v[0]), h = n(v[1]) / 100, age = n(v[2]);
    if (w <= 0 || h <= 0) return [R('BMI', '0')];
    final bmi = w / (h * h);
    var cat = 'Normal';
    if (bmi < 18.5) cat = 'Underweight';
    if (bmi >= 25) cat = 'Overweight';
    if (bmi >= 30) cat = 'Obese';
    final bmrMale = 88.362 + (13.397 * w) + (4.799 * h * 100) - (5.677 * age);
    return [
      R('BMI Value', '${fmt(bmi, 1)} ($cat)'),
      R('BMR (Calories/day)', fmt(bmrMale, 0)),
    ];
  })),
  Tool('GPA / CGPA Result', 'জিপিএ ও সিজিপিএ', Icons.grade, Colors.amber, (t) => FormCalc(t, const [
    F('Subject 1 GP', '5.0'),
    F('Subject 2 GP', '4.0'),
    F('Subject 3 GP', '5.0'),
  ], (v) {
    final nums = v.map(n).where((e) => e > 0).toList();
    if (nums.isEmpty) return [R('GPA', '0.00')];
    final avg = nums.reduce((a, b) => a + b) / nums.length;
    return [R('Calculated GPA', fmt(avg))];
  })),
  Tool('Fraction Calculator', 'ভগ্নাংশ ক্যালকুলেটর', Icons.pie_chart, Colors.purple, (t) => FormCalc(t, const [
    F('Fraction 1 (A/B e.g. 1/2)', '1/2'),
    F('Fraction 2 (C/D e.g. 1/4)', '1/4'),
  ], (v) {
    try {
      final p1 = v[0].split('/'), p2 = v[1].split('/');
      final n1 = n(p1[0]), d1 = n(p1.length > 1 ? p1[1] : '1');
      final n2 = n(p2[0]), d2 = n(p2.length > 1 ? p2[1] : '1');
      final sumN = (n1 * d2) + (n2 * d1), sumD = d1 * d2;
      return [
        R('Addition', '${fmt(sumN)} / ${fmt(sumD)} = ${fmt(sumN / sumD)}'),
        R('Product', '${fmt(n1 * n2)} / ${fmt(d1 * d2)} = ${fmt((n1 * n2) / (d1 * d2))}'),
      ];
    } catch (_) {
      return [R('Error', 'Invalid fraction format')];
    }
  })),
  Tool('Ratio & Proportion', 'অনুপাত ও সমানুপাত', Icons.aspect_ratio, Colors.cyan, (t) => FormCalc(t, const [
    F('A value', '2'),
    F('B value', '4'),
    F('C value', '6'),
  ], (v) {
    final a = n(v[0]), b = n(v[1]), c = n(v[2]);
    final x = a == 0 ? 0.0 : (b * c) / a;
    return [
      R('Ratio A:B', '${fmt(a)} : ${fmt(b)}'),
      R('A:B = C:X  -> X =', fmt(x)),
    ];
  })),
  Tool('Average & Sum', 'গড় ও সমষ্টি', Icons.analytics, Colors.teal, (t) => FormCalc(t, const [
    F('Numbers (comma separated)', '10, 20, 30, 40, 50'),
  ], (v) {
    final list = v[0].split(',').map((s) => double.tryParse(s.trim())).whereType<double>().toList();
    if (list.isEmpty) return [R('Average', '0')];
    final sum = list.reduce((a, b) => a + b);
    return [
      R('Average (Mean)', fmt(sum / list.length)),
      R('Total Sum', fmt(sum)),
      R('Count of numbers', '${list.length}'),
    ];
  })),
  Tool('Unit Converter (Math)', 'ইউনিট কনভার্টার', Icons.straighten, Colors.indigo, (t) => FormCalc(t, const [
    F('Meters', '1000'),
  ], (v) {
    final m = n(v[0]);
    return [
      R('Kilometers', fmt(m / 1000)),
      R('Centimeters', fmt(m * 100)),
      R('Feet', fmt(m * 3.28084)),
      R('Inches', fmt(m * 39.3701)),
    ];
  })),
  Tool('Number System', 'সংখ্যা পদ্ধতি', Icons.onetwothree, Colors.deepOrange, (t) => FormCalc(t, const [
    F('Decimal Number', '255'),
  ], (v) {
    final val = int.tryParse(v[0]) ?? 0;
    return [
      R('Binary (2)', val.toRadixString(2)),
      R('Octal (8)', val.toRadixString(8)),
      R('Hexadecimal (16)', val.toRadixString(16).toUpperCase()),
    ];
  })),
  Tool('Linear Equation', 'একঘাত সমীকরণ', Icons.linear_scale, Colors.brown, (t) => FormCalc(t, const [
    F('Equation ax + b = 0 -> a', '2'),
    F('b', '-8'),
  ], (v) {
    final a = n(v[0]), b = n(v[1]);
    final x = a == 0 ? 0.0 : -b / a;
    return [R('x =', fmt(x))];
  })),
  Tool('Random Generator', 'র্যান্ডম নম্বর', Icons.casino, Colors.pink, (t) => FormCalc(t, const [
    F('Min Value', '1'),
    F('Max Value', '100'),
  ], (v) {
    final min = n(v[0]).toInt(), max = n(v[1]).toInt();
    final r = min >= max ? min : min + Random().nextInt(max - min + 1);
    return [R('Random Result', '$r')];
  })),
  Tool('Prime Number Checker', 'মৌলিক সংখ্যা', Icons.check_circle, Colors.green, (t) => FormCalc(t, const [
    F('Number to test', '29'),
  ], (v) {
    final numVal = n(v[0]).toInt();
    final prime = isPrimeNum(numVal);
    return [
      R('Result', prime ? '$numVal is PRIME' : '$numVal is NOT prime'),
    ];
  })),
  Tool('Factorial Calculator', 'ফ্যাক্টোরিয়াল', Icons.exposure_plus_1, Colors.purple, (t) => FormCalc(t, const [
    F('Integer (n!)', '6'),
  ], (v) {
    final numVal = n(v[0]).toInt().clamp(0, 20);
    var f = 1;
    for (var i = 2; i <= numVal; i++) {
      f *= i;
    }
    return [R('$numVal! =', '$f')];
  })),
];
