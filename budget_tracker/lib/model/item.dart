class Item {
  final String title;
  final String category;
  final double amount;
  final DateTime date;

  const Item({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    final properties = map['properties'] as Map<String, dynamic>;
    final nameList = (properties['title']?['title'] ?? []) as List;
    final dateStr = properties['date']?['date']?['start'];
    return Item(
      title: nameList.isNotEmpty ? nameList[0]['plain_text'] : '?',
      category: properties['category']?['select']?['name'] ?? 'Any',
      amount: (properties['amount']?['number'] ?? 0).toDouble(),
      date: dateStr != null ? DateTime.parse(dateStr) : DateTime.now(),
    );
  }
}
