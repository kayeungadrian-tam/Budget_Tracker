// import 'dart:convert';
// import 'dart:io';
import 'package:budget_tracker/page/fail_page.dart';
import 'package:budget_tracker/page/spending_chart.dart';
import 'package:budget_tracker/utils/color.dart';
import 'package:flutter/material.dart';

import 'package:budget_tracker/model/item.dart';
import 'package:budget_tracker/page/budget_repo.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BudgetHomePage extends StatefulWidget {
  const BudgetHomePage({super.key, required this.title});

  final String title;

  @override
  State<BudgetHomePage> createState() => _BudgetHomePageState();
}

class _BudgetHomePageState extends State<BudgetHomePage> {
  Future<List<Item>>? _futureItems;
  final _textEditingController = TextEditingController();
  final String _inputData = '';
  String? _selectedItem;
  int? _inpurAmount;

  bool showRawValue = false;

  Set<String> categories = {};

  @override
  void initState() {
    super.initState();
    _futureItems = BudgetRepository().getItems();
    _futureItems?.then((items) {
      categories = items.map((item) => item.category).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tam"),
        actions: [
          IconButton(
            icon: Icon(Icons.percent),
            onPressed: () => {
              setState(() {
                showRawValue = !showRawValue;
              })
            },
          ),
        ],
      ),
      // endDrawer: Drawer(
      //   elevation: 16.0,
      //   child: Column(
      //     children: <Widget>[
      //       UserAccountsDrawerHeader(
      //         accountName: Text("xyz"),
      //         accountEmail: Text("xyz@gmail.com"),
      //         currentAccountPicture: CircleAvatar(
      //           backgroundColor: Colors.white,
      //           child: Text("xyz"),
      //         ),
      //         otherAccountsPictures: <Widget>[
      //           CircleAvatar(
      //             backgroundColor: Colors.white,
      //             child: Text("abc"),
      //           )
      //         ],
      //       ),
      //       ListTile(
      //         title: new Text("All Inboxes"),
      //         leading: new Icon(Icons.mail),
      //       ),
      //       Divider(
      //         height: 0.1,
      //       ),
      //       ListTile(
      //         title: new Text("Primary"),
      //         leading: new Icon(Icons.inbox),
      //       ),
      //       ListTile(
      //         title: new Text("Social"),
      //         leading: new Icon(Icons.people),
      //       ),
      //       ListTile(
      //         title: new Text("Promotions"),
      //         leading: new Icon(Icons.local_offer),
      //       )
      //     ],
      //   ),
      // ),
      body: RefreshIndicator(
        onRefresh: () async {
          _futureItems = BudgetRepository().getItems();
          setState(() {});
        },
        child: FutureBuilder<List<Item>>(
            future: _futureItems,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final items = snapshot.data!;
                return ListView.builder(
                  itemCount: items.length + 1,
                  itemBuilder: (BuildContext context, index) {
                    if (index == 0) {
                      return SpendingChart(
                        items: items,
                        showRawValue: showRawValue,
                      );
                    }

                    final item = items[index - 1];
                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: getCategoryColor(item.color).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          width: 2.0,
                          color: getCategoryColor(item.color),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(item.title),
                        subtitle: Text(
                          '${item.category} • ${DateFormat.yMd().format(item.date)}',
                        ),
                        trailing: Text(
                          '-\￥${item.amount.toStringAsFixed(2)}',
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                final failure = snapshot.error as Failure;
                return Center(child: Text(failure.message));
              }
              return const Center(child: CircularProgressIndicator());
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (
                context,
              ) =>
                      _InputPage(
                          textEditingController: _textEditingController,
                          selectedItem: _selectedItem,
                          items: categories.toList(),
                          inputData: _inputData,
                          inputAmount: _inpurAmount,
                          onSubmitted: (value, selectedItem, inputAmount) {
                            BudgetRepository()
                                .addItem(value, inputAmount, selectedItem);
                            // Navigator.pop(context);
                          })));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class _InputPage extends StatefulWidget {
  final TextEditingController textEditingController;
  final String? selectedItem;
  final String? inputData;
  final int? inputAmount;
  // final ValueChanged<String> onSubmitted;
  final List<String> items;
  final Function(String, String?, int?) onSubmitted;

  // final ValueChanged<String, String?> onSubmitted;

  const _InputPage({
    Key? key,
    required this.textEditingController,
    required this.selectedItem,
    required this.items,
    required this.inputData,
    required this.inputAmount,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  __InputPageState createState() => __InputPageState();
}

class __InputPageState extends State<_InputPage> {
  String? _selectedItem;
  String? inputData;
  int? inputAmount;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
  }

  validateInt(value) {
    if (!value.isEmpty) {
      try {
        int inputAmount = int.parse(value);
        if (inputAmount > 0) {
          return inputAmount;
        }
      } catch (FormatException) {
        print('Input value must be a valid integer.');
      }
    } else {
      print('Input value cannot be empty.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: widget.textEditingController,
              onChanged: (value) {
                // Update the input data
                setState(() {
                  inputData = value;
                  // widget.onSubmitted(value, "test");
                });
              },
              decoration: const InputDecoration(
                labelText: 'Enter Data',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter a number',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Do something with the number input
                setState(() {
                  inputAmount = validateInt(value);
                });
              },
            ),
            const SizedBox(
              height: 16.0,
            ),
            DropdownButtonFormField<String>(
              value: _selectedItem,
              onChanged: (value) {
                // Update the selected item
                setState(() {
                  _selectedItem = value;
                  // widget.onSubmitted(widget.textEditingController.text,
                  // _selectedItem, inputAmount);
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Item',
                border: OutlineInputBorder(),
              ),
              items: widget.items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: widget.textEditingController.text.isEmpty
                  ? null
                  : () {
                      // Submit the input data
                      widget.onSubmitted(widget.textEditingController.text,
                          _selectedItem, inputAmount);
                    },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
