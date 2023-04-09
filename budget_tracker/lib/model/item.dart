class Item {
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String color;

  const Item({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.color,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    final properties = map['properties'] as Map<String, dynamic>;
    final nameList = (properties['title']?['title'] ?? []) as List;
    final dateStr = properties['date']?['date']?['start'];
    final color = properties["category"]?["select"]?["color"] ?? "white";

    return Item(
        title: nameList.isNotEmpty ? nameList[0]['plain_text'] : '?',
        category: properties['category']?['select']?['name'] ?? 'Any',
        amount: (properties['amount']?['number'] ?? 0).toDouble(),
        date: dateStr != null ? DateTime.parse(dateStr) : DateTime.now(),
        color: color);
  }
}
