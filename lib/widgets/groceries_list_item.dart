import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';

class GroceriesListItem extends StatelessWidget {
  const GroceriesListItem(
      {super.key, required this.groceryItems, required this.onRemoveItem});

  final List<GroceryItem> groceryItems;
  final void Function(GroceryItem groceryItem) onRemoveItem;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
              onDismissed: (direction) => onRemoveItem(groceryItems[index]),
              background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: const Icon(Icons.delete)),
              key: ValueKey(groceryItems[index].id),
              child: ListTile(
                title: Text(groceryItems[index].name),
                leading: Container(
                    width: 24,
                    height: 24,
                    color: groceryItems[index].category.color),
                trailing: Text(groceryItems[index].quantity.toString()),
              ),
            ));
  }
}
