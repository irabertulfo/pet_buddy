import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_buddy/model/inventory_model.dart';
import 'package:pet_buddy/utils/firestore_database.dart';
import 'package:pet_buddy/utils/toast.dart';

class AddItemDialog extends StatefulWidget {
  final List<CategoryModel> categories;
  final void Function() onReloadInventory;

  const AddItemDialog(
      {super.key, required this.categories, required this.onReloadInventory});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  FirestoreDatabase firestoreDatabase = FirestoreDatabase();

  TextEditingController nameTextController = TextEditingController();
  TextEditingController stockTextController = TextEditingController();
  CategoryModel? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Increased border radius
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              // Added container for better padding control
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Add New Item',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0), // Increased padding
              child: TextField(
                controller: nameTextController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.list),
                  labelText: 'Item',
                  hintText: 'e.g., Syringe',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12), // Match border radius
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0), // Increased padding
              child: TextField(
                keyboardType: TextInputType.number,
                controller: stockTextController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.attach_money), // Changed icon
                  labelText: 'Stock',
                  hintText: '0-99999',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12), // Match border radius
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0), // Increased padding
              child: CupertinoPicker(
                itemExtent: 70,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    selectedCategory = widget.categories[index + 1];
                  });
                },
                children:
                    widget.categories.skip(1).map((CategoryModel category) {
                  return Center(
                    child: Text(
                      category.name,
                      style: TextStyle(fontSize: 20.0),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0), // Increased padding
              child: ElevatedButton(
                onPressed: () {
                  if (selectedCategory == null) {
                    Toast.show(context, 'No Category Is Selected!');
                  } else if (nameTextController.text == '') {
                    Toast.show(context, 'Name is invalid.');
                  } else if (int.parse(stockTextController.text) < 1) {
                    Toast.show(context, 'Stock is invalid');
                  } else {
                    InventoryModel newItem = InventoryModel(
                        id: '',
                        category: selectedCategory!,
                        name: nameTextController.text,
                        stock: int.parse(stockTextController.text));

                    firestoreDatabase.addItemToInventory(newItem);

                    Toast.show(context,
                        'Successfully added ${nameTextController.text}');
                    widget.onReloadInventory();
                    Navigator.pop(context);
                  }
                },
                child: Text('ADD'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
