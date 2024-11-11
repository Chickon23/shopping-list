import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/new_item.dart';
import 'package:shopping_list/widgets/groceries_list_item.dart';
import 'package:http/http.dart' as http;

class GroceriesListScreen extends StatefulWidget {
  const GroceriesListScreen({super.key});

  @override
  State<GroceriesListScreen> createState() => _GroceriesListScreenState();
}

class _GroceriesListScreenState extends State<GroceriesListScreen> {
  List<GroceryItem> _groceryItems = [];
  late Future<List<GroceryItem>> _loadedItems;

  @override
  void initState() {
    _loadedItems = _loadItems();
    super.initState();
  }

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
        'flutter-prep-da43b-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch grocery items. Pleas try again later');
    }

    if (response.body == 'null') {
      return [];
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }
    setState(() {
      _groceryItems = loadedItems;
    });

    return loadedItems;
  }

  void _addNewItem() async {
    final newItem =
        await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(
      builder: (context) {
        return const NewItemScreen();
      },
    ));

    if (newItem == null) return;

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem groceryItem) async {
    final groceryItmesIndex = _groceryItems.indexOf(groceryItem);

    final url = Uri.https('flutter-prep-da43b-default-rtdb.firebaseio.com',
        'shopping-list/${groceryItem.id}.json');

    setState(() {
      _groceryItems.remove(groceryItem);
    });

    // if (context.mounted) {
    //   ScaffoldMessenger.of(context).clearSnackBars();
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     duration: const Duration(seconds: 3),
    //     content: const Text('Item deleted'),
    //     action: SnackBarAction(
    //         label: 'Undo',
    //         onPressed: () {
    //           _isUndoPressed = true;
    //           setState(() {
    //             _groceryItems.insert(groceryItmesIndex, groceryItem);
    //           });
    //         }),
    //   ));
    // }

    final response = await http.delete(url);

    if (response.statusCode >= 400 && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Something went wrong',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      setState(() {
        _groceryItems.insert(groceryItmesIndex, groceryItem);
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(onPressed: _addNewItem, icon: const Icon(Icons.add))
          ],
        ),
        body: FutureBuilder(
          future: _loadedItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                  child: Text(
                snapshot.error.toString(),
                style: const TextStyle(fontSize: 24),
              ));
            }

            if (snapshot.data!.isEmpty) {
              return const Center(
                  child: Text(
                'No items yet. Please add some',
                style: TextStyle(fontSize: 24),
              ));
            }

            return GroceriesListItem(
              groceryItems: snapshot.data!,
              onRemoveItem: _removeItem,
            );
          },
        ));
  }
}
