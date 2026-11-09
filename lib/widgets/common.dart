import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme.dart';

/// Reusable white rounded card.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Gradient? gradient;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.gradient,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: gradient == null ? Colors.white : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      );
}

/// Fade + slide-up entrance animation.
class FadeIn extends StatelessWidget {
  final Widget child;
  final int delayMs;
  const FadeIn({super.key, required this.child, this.delayMs = 0});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 500 + delayMs),
        curve: Curves.easeOutCubic,
        builder: (context, v, c) => Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: c),
        ),
        child: child,
      );
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink)),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

class TxTile extends StatelessWidget {
  final TransactionItem tx;
  const TxTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: tx.category.color.withOpacity(0.15),
          child: Icon(tx.category.icon, color: tx.category.color),
        ),
        title: Text(tx.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${tx.category.label} • ${fmtDate(tx.date)}'),
        trailing: Text(
          '${tx.isIncome ? '+' : '-'}${money(tx.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: tx.isIncome ? AppColors.green : AppColors.navy,
          ),
        ),
      );
}

/// Animated donut chart drawn with CustomPaint.
class DonutChart extends StatelessWidget {
  final Map<Category, double> data;
  final double size;
  final String centerLabel;
  final String centerValue;
  const DonutChart({
    super.key,
    required this.data,
    required this.centerLabel,
    required this.centerValue,
    this.size = 190,
  });

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _DonutPainter(data, v),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(centerLabel,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  Text(centerValue,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink)),
                ],
              ),
            ],
          ),
        ),
      );
}

class _DonutPainter extends CustomPainter {
  final Map<Category, double> data;
  final double progress;
  _DonutPainter(this.data, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.15;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final total = data.values.fold(0.0, (a, b) => a + b);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.sky;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    if (total <= 0) return;
    var start = -math.pi / 2;
    for (final e in data.entries) {
      final sweep = e.value / total * math.pi * 2 * progress;
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = e.key.color;
      canvas.drawArc(rect, start, math.max(0, sweep - 0.02), false, p);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.progress != progress || old.data != data;
}

/// 7-day animated bar chart.
class WeeklyBars extends StatelessWidget {
  final List<double> values;
  const WeeklyBars({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    final maxV = values.fold(1.0, (a, b) => math.max(a, b));
    final today = DateTime.now();
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return SizedBox(
      height: 170,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final d = today.subtract(Duration(days: 6 - i));
          final isToday = i == values.length - 1;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(values[i] > 0 ? money(values[i]) : '',
                    style: const TextStyle(fontSize: 9, color: Colors.black54)),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: values[i] / maxV),
                  duration: Duration(milliseconds: 600 + i * 120),
                  curve: Curves.easeOutBack,
                  builder: (context, f, _) => Container(
                    height: math.max(4.0, 110 * f.clamp(0.0, 1.2)),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: isToday
                            ? const [AppColors.mustard, Color(0xFFF2CF5B)]
                            : const [AppColors.blue, AppColors.teal],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(days[d.weekday - 1],
                    style: TextStyle(
                        fontWeight:
                            isToday ? FontWeight.w800 : FontWeight.w500)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class Legend extends StatelessWidget {
  final Map<Category, double> data;
  const Legend({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.isEmpty) {
      return const Text('No expenses this month yet.');
    }
    return Column(
      children: entries
          .map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: e.key.color, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(e.key.label)),
                    Text(money(e.value),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 42,
                      child: Text(
                        '${(e.value / total * 100).round()}%',
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
