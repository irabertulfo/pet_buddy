import 'package:flutter/material.dart';
import 'package:pet_buddy/utils/firestore_database.dart';
import 'package:pet_buddy/view/home/admin/records_management/record_card.dart';
import 'package:pet_buddy/view/home/admin/records_management/record_search_bar.dart';

class RecordsManagementScreen extends StatefulWidget {
  const RecordsManagementScreen({super.key});

  @override
  State<RecordsManagementScreen> createState() =>
      _RecordsManagementScreenState();
}

class _RecordsManagementScreenState extends State<RecordsManagementScreen> {
  FirestoreDatabase firestoreDatabase = FirestoreDatabase();

  String _filterText = '';
  String? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            "Records History",
            style: Theme.of(context).textTheme.displaySmall,
          ),
          RecordsSearchBar(onFilter: _onFilter),
          FutureBuilder<List<Map<String, dynamic>>?>(
            future: firestoreDatabase.getRecords(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text('No records found.'));
              } else {
                final filteredRecords = _applyFilters(snapshot.data);

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];

                    return RecordCard(
                      date: record['date'].toDate(),
                      diagnosis: record['diagnosis'],
                      notes: record['notes'],
                      petBreed: record['petBreed'],
                      petName: record['petName'],
                      service: record['service'],
                      owner: '${record['firstName']} ${record['lastName']}',
                      price: record['price'],
                      paymentMethod: record['paymentMethod'],
                    );
                  },
                );
              }
            },
          )
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>>? records) {
    if (_selectedFilter == "Owner") {
      return records
              ?.where((record) => '${record['firstName']} ${record['lastName']}'
                  .toLowerCase()
                  .contains(_filterText.toLowerCase()))
              .toList() ??
          [];
    } else if (_selectedFilter == "Pet Name") {
      return records
              ?.where((record) => record['petName']
                  .toLowerCase()
                  .contains(_filterText.toLowerCase()))
              .toList() ??
          [];
    } else if (_selectedFilter == "Date") {
      // Assuming _filterText is a valid date string in the format you need
      return records
              ?.where((record) =>
                  record['date'].toDate().toString().contains(_filterText))
              .toList() ??
          [];
    } else {
      // If no filter is selected, return all records
      return records ?? [];
    }
  }

  void _onFilter(String searchText, String? selectedFilter) {
    setState(() {
      _filterText = searchText;
      _selectedFilter = selectedFilter;
    });
  }
}
