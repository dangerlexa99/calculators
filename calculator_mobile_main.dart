// Мобильный калькулятор на Flutter (Android + iOS).
// Использование: flutter create calc && замените calc/lib/main.dart этим файлом && flutter run
import 'package:flutter/material.dart';

void main() => runApp(const CalcApp());

class CalcApp extends StatelessWidget {
  const CalcApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Калькулятор',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: const CalcPage(),
      );
}

class CalcPage extends StatefulWidget {
  const CalcPage({super.key});
  @override
  State<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends State<CalcPage> {
  static const keys = [
    ['C', '±', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['⌫', '0', '.', '='],
  ];
  String cur = '0';
  double? acc;
  String? op;
  bool fresh = true;

  String fmt(double n) {
    if (n.isNaN || n.isInfinite) return 'Ошибка';
    final s = n.toStringAsPrecision(12);
    return s.contains('.') && !s.contains('e')
        ? s.replaceFirst(RegExp(r'\.?0+$'), '')
        : s;
  }

  double calc(double a, String o, double b) {
    switch (o) {
      case '+': return a + b;
      case '−': return a - b;
      case '×': return a * b;
      case '÷': return b == 0 ? double.nan : a / b;
    }
    return b;
  }

  void press(String k) {
    if (cur == 'Ошибка' && k != 'C') return;
    setState(() {
      if (RegExp(r'^\d$').hasMatch(k)) {
        cur = fresh || cur == '0' ? k : cur + k;
        fresh = false;
      } else if (k == '.') {
        if (fresh) { cur = '0.'; fresh = false; }
        else if (!cur.contains('.')) cur += '.';
      } else if (k == 'C') {
        cur = '0'; acc = null; op = null; fresh = true;
      } else if (k == '⌫') {
        cur = cur.length > 1 && !fresh ? cur.substring(0, cur.length - 1) : '0';
        if (cur == '-') cur = '0';
      } else if (k == '±') {
        if (cur != '0') cur = cur.startsWith('-') ? cur.substring(1) : '-$cur';
      } else if (k == '%') {
        cur = fmt(double.parse(cur) / 100); fresh = true;
      } else if (k == '=') {
        if (op != null && acc != null) {
          cur = fmt(calc(acc!, op!, double.parse(cur)));
          acc = null; op = null; fresh = true;
        }
      } else {
        if (op != null && acc != null && !fresh) {
          cur = fmt(calc(acc!, op!, double.parse(cur)));
        }
        if (cur == 'Ошибка') return;
        acc = double.parse(cur); op = k; fresh = true;
      }
    });
  }

  Color bg(String k) => k == '='
      ? const Color(0xFFD9822B)
      : '÷×−+'.contains(k) ? const Color(0xFF4A7FB0) : const Color(0xFF252E39);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12171D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(8),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(op != null && acc != null ? '${fmt(acc!)} $op' : '',
                      style: const TextStyle(fontSize: 18, color: Colors.grey)),
                  FittedBox(
                    child: Text(cur, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300)),
                  ),
                ]),
              ),
            ),
            for (final row in keys)
              Expanded(
                flex: 0,
                child: SizedBox(
                  height: 78,
                  child: Row(children: [
                    for (final k in row)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: bg(k),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => press(k),
                            child: Text(k, style: const TextStyle(fontSize: 26, color: Colors.white)),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
