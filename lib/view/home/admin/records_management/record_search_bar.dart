import 'package:flutter/material.dart';
import 'package:pet_buddy/model/user_model.dart';

class RecordsSearchBar extends StatefulWidget {
  final Function(String, String?) onFilter;

  const RecordsSearchBar({super.key, required this.onFilter});

  @override
  RecordsSearchBarState createState() => RecordsSearchBarState();
}

class RecordsSearchBarState extends State<RecordsSearchBar> {
  UserModel? loggedInUser = UserSingleton().user;
  String _searchText = '';
  String? _selectedFilter;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loggedInUser = UserSingleton().user;
    _selectedFilter =
        (loggedInUser!.userType == 'admin') ? 'Owner' : 'Pet Name';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    _searchText = searchController.text;
                  });
                  _applyFilter();
                },
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
                            _applyFilter();
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          DropdownButton<String>(
            value: _selectedFilter,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            underline: const SizedBox(),
            onChanged: (newValue) {
              setState(() {
                _selectedFilter = newValue;
              });
              _applyFilter();
            },
            items: <String>[
              if (loggedInUser!.userType != 'user') 'Owner',
              'Pet Name',
              'Date',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _applyFilter() {
    widget.onFilter(_searchText, _selectedFilter);
  }
}
