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
          RecordsSearchBar(onFilter: _onFilter),
          Text(
            "Records History",
            style: Theme.of(context).textTheme.displaySmall,
          ),
          FutureBuilder<List<Map<String, dynamic>>?>(
            future: firestoreDatabase.getRecords(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text('No records found.'));
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final record = snapshot.data![index];

                    return RecordCard(
                      date: record['date'].toDate(),
                      diagnosis: record['diagnosis'],
                      notes: record['notes'],
                      petBreed: record['petBreed'],
                      petName: record['petName'],
                      service: record['service'],
                      owner: '${record['firstName']} ${record['lastName']}',
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

  void _onFilter(String searchText, String? selectedFilter) {
    setState(() {
      _filterText = searchText;
      _selectedFilter = selectedFilter;
    });

    // You can now apply your filter logic to the records using the _filterText and _selectedFilter values.
    // For example, you can call the FirestoreDatabase method with the filter parameters to get filtered records.
    // firestoreDatabase.getFilteredRecords(_filterText, _selectedFilter);
  }
}
