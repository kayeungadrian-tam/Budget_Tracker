import 'dart:convert';
import 'dart:io';

import 'package:budget_tracker/model/item.dart';
import 'package:budget_tracker/page/fail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BudgetRepository {
  static const String _baseUrl = 'https://api.notion.com/v1/';
  static const String _addUrl = 'https://api.notion.com/v1/pages';

  final http.Client _client;

  BudgetRepository({http.Client? client}) : _client = client ?? http.Client();

  void dispose() {
    _client.close();
  }

  Future<List<Item>> getItems() async {
    try {
      final url = '${_baseUrl}databases/${dotenv.env['NOTION_DB_KEY']}/query';
      final response = await _client.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader:
              'Bearer ${dotenv.env['NOTION_API_KEY']}',
          'Notion-Version': '2022-06-28',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['results'] as List).map((e) => Item.fromMap(e)).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      } else {
        throw const Failure(message: 'Something went wrong!');
      }
    } catch (_) {
      throw const Failure(message: 'Something went wrong!');
    }
  }

  void addItem(title, amount, category) async {
    try {
      var data = {
        'parent': {
          'type': 'database_id',
          'database_id': '5ca649b660644905867ce841389144e8'
        },
        'properties': {
          'title': {
            'type': 'title',
            'title': [
              {
                'type': 'text',
                'text': {'content': title}
              }
            ]
          },
          'amount': {'type': 'number', 'number': amount},
          'category': {
            'select': {'name': category}
          }
        }
      };

      //  var body = (data);

      final response = await _client.post(Uri.parse(_addUrl),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${dotenv.env['NOTION_API_KEY']}',
            'Notion-Version': '2022-06-28',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode(data));
      print(response.body);
    } catch (error) {
      // throw const Failure(message: 'Failed to add item.');
      print(error);
    }
  }
}
