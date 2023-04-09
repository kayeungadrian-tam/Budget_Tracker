import 'package:budget_tracker/model/item.dart';
import 'package:budget_tracker/utils/color.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpendingChart extends StatelessWidget {
  final List<Item> items;

  const SpendingChart({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final spending = <String, double>{};
    final spending = <String, Map<String, double>>{};

    double totalAmount = items.fold(0, (sum, item) => sum + item.amount);

    items.forEach(
      (item) => spending.update(
        item.category,
        (value) => value
          ..update(
            item.color,
            (value) => value + item.amount,
            ifAbsent: () => item.amount,
          ),
        ifAbsent: () => {
          item.color: item.amount,
        },
      ),
    );

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: 360.0,
        child: Column(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: spending
                      .map(
                        (category, colors) => MapEntry(
                          category,
                          colors.entries.map((entry) {
                            final color = entry.key;
                            final amount = entry.value;
                            final title =
                                '${(100 * amount / totalAmount).toStringAsFixed(1)}%';
                            return PieChartSectionData(
                              color: getCategoryColor(color),
                              radius: 100.0,
                              title: title,
                              value: amount,
                            );
                          }).toList(),
                        ),
                      )
                      .values
                      .expand((colorSections) => colorSections)
                      .toList(),
                  sectionsSpace: 0,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: spending.entries.expand((entry) {
                String category = entry.key;
                Map<String, double> colorMap = entry.value;
                return colorMap.keys.map((color) {
                  return _Indicator(
                    color: getCategoryColor(color),
                    text: category,
                  );
                });
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;

  const _Indicator({
    Key? key,
    required this.color,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 16.0,
          width: 16.0,
          color: color,
        ),
        const SizedBox(width: 4.0),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
