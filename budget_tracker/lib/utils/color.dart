import 'package:flutter/material.dart';

Color getCategoryColor(String category) {
  switch (category) {
    case 'red':
      return Colors.red[400]!;
    case 'gray':
      return Colors.grey[400]!;
    case 'blue':
      return Colors.blue[400]!;
    case 'pink':
      return Colors.pink[400]!;
    case 'orange':
      return Colors.orange[400]!;
    case 'green':
      return Colors.green[400]!;
    case 'purple':
      return Colors.purple[400]!;
    case 'default':
      return Colors.blueGrey[400]!;
    default:
      return Colors.white10!;
  }
}
