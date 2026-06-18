import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'detail_chip.dart';

class PublicationTrendChart extends StatelessWidget {
  const PublicationTrendChart({super.key, required this.yearlyCounts});

  final List<MapEntry<int, int>> yearlyCounts;

  @override
  Widget build(BuildContext context) {
    final first = yearlyCounts.first;
    final last = yearlyCounts.last;
    final change = last.value - first.value;
    final trendLabel = change == 0
        ? 'No net change'
        : change > 0
        ? '+$change publications'
        : '$change publications';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                DetailChip(
                  icon: Icons.timeline_outlined,
                  label: '${first.key}-${last.key}',
                ),
                DetailChip(
                  icon: change >= 0
                      ? Icons.trending_up_outlined
                      : Icons.trending_down_outlined,
                  label: trendLabel,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              width: double.infinity,
              child: CustomPaint(
                painter: _PublicationTrendPainter(
                  yearlyCounts: yearlyCounts,
                  colorScheme: Theme.of(context).colorScheme,
                  textStyle: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublicationTrendPainter extends CustomPainter {
  const _PublicationTrendPainter({
    required this.yearlyCounts,
    required this.colorScheme,
    required this.textStyle,
  });

  final List<MapEntry<int, int>> yearlyCounts;
  final ColorScheme colorScheme;
  final TextStyle? textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    if (yearlyCounts.isEmpty) {
      return;
    }

    const leftPadding = 48.0;
    const rightPadding = 18.0;
    const topPadding = 18.0;
    const bottomPadding = 34.0;
    final chartRect = Rect.fromLTWH(
      leftPadding,
      topPadding,
      math.max(0, size.width - leftPadding - rightPadding),
      math.max(0, size.height - topPadding - bottomPadding),
    );
    final maxCount = yearlyCounts
        .map((entry) => entry.value)
        .fold<int>(0, math.max);
    final safeMaxCount = math.max(maxCount, 1);
    final gridPaint = Paint()
      ..color = colorScheme.outlineVariant
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = colorScheme.outline
      ..strokeWidth = 1.2;

    for (var i = 0; i <= 4; i++) {
      final y = chartRect.bottom - chartRect.height * (i / 4);
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
      _drawText(
        canvas,
        '${(safeMaxCount * i / 4).round()}',
        Offset(0, y - 8),
        maxWidth: leftPadding - 8,
        align: TextAlign.right,
      );
    }

    canvas.drawLine(chartRect.bottomLeft, chartRect.bottomRight, axisPaint);
    canvas.drawLine(chartRect.bottomLeft, chartRect.topLeft, axisPaint);

    final points = <Offset>[];
    for (var i = 0; i < yearlyCounts.length; i++) {
      final entry = yearlyCounts[i];
      final x = yearlyCounts.length == 1
          ? chartRect.center.dx
          : chartRect.left + chartRect.width * (i / (yearlyCounts.length - 1));
      final y =
          chartRect.bottom - chartRect.height * (entry.value / safeMaxCount);
      points.add(Offset(x, y));
    }

    if (points.length > 1) {
      final areaPath = Path()..moveTo(points.first.dx, chartRect.bottom);
      for (final point in points) {
        areaPath.lineTo(point.dx, point.dy);
      }
      areaPath
        ..lineTo(points.last.dx, chartRect.bottom)
        ..close();

      canvas.drawPath(
        areaPath,
        Paint()..color = colorScheme.primaryContainer.withValues(alpha: 0.48),
      );
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = colorScheme.primary
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final pointPaint = Paint()..color = colorScheme.primary;
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
      canvas.drawCircle(
        point,
        6,
        Paint()
          ..color = colorScheme.surface
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    _drawText(
      canvas,
      '${yearlyCounts.first.key}',
      Offset(chartRect.left - 18, chartRect.bottom + 10),
      maxWidth: 56,
      align: TextAlign.left,
    );
    _drawText(
      canvas,
      '${yearlyCounts.last.key}',
      Offset(chartRect.right - 38, chartRect.bottom + 10),
      maxWidth: 56,
      align: TextAlign.right,
    );

    final peak = yearlyCounts.reduce(
      (best, entry) => entry.value > best.value ? entry : best,
    );
    final peakIndex = yearlyCounts.indexOf(peak);
    final peakPoint = points[peakIndex];
    _drawText(
      canvas,
      '${peak.key}: ${peak.value}',
      Offset(
        math.min(peakPoint.dx - 36, chartRect.right - 74),
        math.max(0, peakPoint.dy - 26),
      ),
      maxWidth: 82,
      align: TextAlign.center,
      color: colorScheme.primary,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    required double maxWidth,
    TextAlign align = TextAlign.left,
    Color? color,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: (textStyle ?? const TextStyle()).copyWith(color: color),
      ),
      maxLines: 1,
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _PublicationTrendPainter oldDelegate) {
    return oldDelegate.yearlyCounts != yearlyCounts ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.textStyle != textStyle;
  }
}
