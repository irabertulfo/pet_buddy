import 'package:flutter/material.dart';
import 'package:pet_buddy/model/inventory_model.dart';
import 'package:pet_buddy/utils/firestore_database.dart';
import 'package:pet_buddy/view/home/admin/inventory/add_item.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  FirestoreDatabase firestoreDatabase = FirestoreDatabase();
  List<InventoryModel> inventoryItems = [];
  List<CategoryModel> categories = [];
  CategoryModel? selectedCategory;

  String _searchText = '';
  TextEditingController searchController = TextEditingController();

  Future<void> _loadInventoryItems() async {
    final items = await firestoreDatabase.getAllInventory();

    setState(() {
      inventoryItems = items;
    });
  }

  Future<void> _loadCategories() async {
    final items = await firestoreDatabase.getAllCategories();

    setState(() {
      categories = items;
      if (selectedCategory == null && categories.isNotEmpty) {
        selectedCategory = categories[0];
      }
    });
  }

  List<InventoryModel> getFilteredInventoryItems() {
    return inventoryItems.where((item) {
      return selectedCategory == null ||
          selectedCategory!.id.isEmpty ||
          item.category.id == selectedCategory!.id;
    }).where((item) {
      final itemName = item.name.toLowerCase();
      final search = _searchText.toLowerCase();
      return itemName.contains(search);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadInventoryItems();
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _searchText = '';
                                  searchController.text = '';
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              if (categories.isNotEmpty)
                DropdownButton<CategoryModel>(
                  value: selectedCategory,
                  onChanged: (CategoryModel? newCategory) {
                    if (newCategory != null) {
                      setState(() {
                        selectedCategory = newCategory;
                      });
                    }
                  },
                  items: categories.map((CategoryModel category) {
                    return DropdownMenuItem<CategoryModel>(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                ),
            ],
          ),
          Expanded(
            child: Stack(children: [
              RefreshIndicator(
                onRefresh: () async {
                  _loadInventoryItems();
                },
                child: ListView.builder(
                  itemCount: getFilteredInventoryItems().length,
                  itemBuilder: (context, index) {
                    final item = getFilteredInventoryItems()[index];
                    return InventoryItem(
                        item: item, reloadInventoryItems: _loadInventoryItems);
                  },
                ),
              ),
              Positioned(
                bottom: 16.0,
                left: 0,
                right: 0,
                child: Center(
                  child: FloatingActionButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddItemDialog(
                            categories: categories,
                            onReloadInventory: _loadInventoryItems,
                          );
                        },
                      );
                    },
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class InventoryItem extends StatelessWidget {
  const InventoryItem({
    Key? key,
    required this.item,
    required this.reloadInventoryItems,
  });

  final InventoryModel item;
  final VoidCallback reloadInventoryItems;

  @override
  Widget build(BuildContext context) {
    FirestoreDatabase firestoreDatabase = FirestoreDatabase();

    Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete Item"),
            content: Text("Are you sure you want to delete this item?"),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Delete"),
                onPressed: () {
                  firestoreDatabase.deleteItemInInventory(item.id);
                  reloadInventoryItems();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: const Icon(
        Icons.list,
        size: 40,
        color: Colors.blue,
      ),
      title: Text(
        item.name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Row(
        children: [
          const Icon(
            Icons.inventory,
            size: 18,
            color: Colors.grey,
          ),
          const SizedBox(width: 5),
          Text(
            'Stock: ${item.stock}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.green,
            ),
            onPressed: () async {
              await firestoreDatabase.updateItemStock(item.id, 'add');
              reloadInventoryItems();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.remove,
              color: Colors.red,
            ),
            onPressed: () async {
              await firestoreDatabase.updateItemStock(item.id, 'subtract');
              reloadInventoryItems();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
