import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:open_file/open_file.dart';
import 'package:pet_buddy/utils/firestore_database.dart';
import 'package:pet_buddy/view/home/admin/records_management/record_card.dart';
import 'package:pet_buddy/view/home/admin/records_management/record_search_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class RecordsManagementScreen extends StatefulWidget {
  const RecordsManagementScreen({Key? key}) : super(key: key);

  @override
  State<RecordsManagementScreen> createState() => _RecordsManagementScreenState();
}

class _RecordsManagementScreenState extends State<RecordsManagementScreen> {
  FirestoreDatabase firestoreDatabase = FirestoreDatabase();
  String _filterText = '';
  String? _selectedFilter;
  List<Map<String, dynamic>>? _allRecords; // Added field for unfiltered records

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
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
                    // Store unfiltered records
                    _allRecords = snapshot.data;

                    // Apply filters to display in the main UI
                    final filteredRecords = _applyFilters(snapshot.data);

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = filteredRecords[index];

                        return RecordCard(
                          date: (record['date'] as Timestamp).toDate(),
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
              ),
            ],
          ),
        ),
        // Transaction Icon
        Positioned(
          bottom: 10.0,
          right: 10.0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Theme.of(context).primaryColor,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _showTransactions,
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.attach_money,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
      return records
          ?.where((record) =>
              _formattedDate(record['date']).contains(_filterText))
          .toList() ??
          [];
    } else {
      return records ?? [];
    }
  }

  void _onFilter(String searchText, String? selectedFilter) {
    setState(() {
      _filterText = searchText;
      _selectedFilter = selectedFilter;
    });
  }

  void _showTransactions() {
  print("_allRecords before fetching: $_allRecords"); // Add this line

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder<List<Map<String, dynamic>>>(
        // Use _allRecords instead of calling firestoreDatabase.getRecords() again
        future: Future.value(_allRecords),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('No records found.'));
          } else {
            // Set _allRecords after fetching
            _allRecords = snapshot.data;

            return AlertDialog(
              title: const Text('Transaction Information'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var record in snapshot.data!)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text(
                            'Transaction Date: ${_formattedDate(record['date'])}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Transaction Price: PHP ${record['price'].toString()}',
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      _generateAndShowTransactionReport(snapshot.data!);
                    },
                    child: const Text(
                      'Save Transaction Report',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
    },
  );
}

  void _generateAndShowTransactionReport(List<Map<String, dynamic>> records) async {
    final pdf = pdfLib.Document();
    double totalAmount = 0;

    // Title, Table, and Total in one page
    pdf.addPage(
      pdfLib.Page(
        build: (context) {
          // Title
          pdfLib.Widget titleWidget = pdfLib.Column(
            crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
            children: [
              pdfLib.Text('Transaction Report',
                  style: pdfLib.TextStyle(
                      fontWeight: pdfLib.FontWeight.bold, fontSize: 20)),
              pdfLib.SizedBox(height: 10),
            ],
          );

          // Table Header
          final tableHeaders = ['Date', 'Price'];
          final tableData = records.map<List<String>>((record) {
            final date = _formattedDate(record['date']);
            final price = ' PHP ${(record['price'] as num).toStringAsFixed(2)}'; // Note the space before 'PHP'
            totalAmount += record['price'] as double;
            return [date, price];
          }).toList();

          // Table
          pdfLib.Widget tableWidget = pdfLib.Table.fromTextArray(
            headers: tableHeaders,
            data: tableData,
            cellAlignment: pdfLib.Alignment.center,
            cellHeight: 30,
            cellAlignments: {
              0: pdfLib.Alignment.centerLeft,
              1: pdfLib.Alignment.centerRight
            },
          );

          // Total
          pdfLib.Widget totalWidget = pdfLib.Column(
            crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
            children: [
              pdfLib.SizedBox(height: 20),
              pdfLib.Text('Total Price: PHP ${totalAmount.toStringAsFixed(2)}',
                  style: pdfLib.TextStyle(
                      fontWeight: pdfLib.FontWeight.bold, fontSize: 18)),
            ],
          );

          return pdfLib.Column(
            children: [titleWidget, tableWidget, totalWidget],
          );
        },
      ),
    );

    final directory = await getExternalStorageDirectory();
    final file = File("${directory!.path}/transactions_report.pdf");
    await file.writeAsBytes(await pdf.save());

    print("PDF Saved at: ${file.path}");

    // Open the generated PDF
    OpenFile.open(file.path);

    // Show a notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction Report saved to ${file.path}'),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  String _formattedDate(dynamic date) {
    if (date is DateTime) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else if (date is Timestamp) {
      return '${date.toDate().year}-${date.toDate().month.toString().padLeft(2, '0')}-${date.toDate().day.toString().padLeft(2, '0')}';
    } else {
      return '';
    }
  }
}