import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_buddy/model/records_model.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/utils/firestore_database.dart';
import 'package:pet_buddy/view/home/admin/records_management/record_search_bar.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class RecordsClientScreen extends StatefulWidget {
  const RecordsClientScreen({Key? key}) : super(key: key);

  @override
  State<RecordsClientScreen> createState() => _RecordsClientScreenState();
}

class _RecordsClientScreenState extends State<RecordsClientScreen> {
  FirestoreDatabase firestoreDatabase = FirestoreDatabase();
  UserModel? loggedInUser = UserSingleton().user;

  String _filterText = '';
  String? _selectedFilter;

  void _onFilter(String searchText, String? selectedFilter) {
    setState(() {
      _filterText = searchText;
      _selectedFilter = selectedFilter;
    });
  }

  List<RecordModel> _filterRecords(List<RecordModel> records) {
    if (_selectedFilter == "Pet Name") {
      return records.where((record) {
        return record.petName.toLowerCase().contains(_filterText.toLowerCase());
      }).toList();
    } else if (_selectedFilter == "Date") {
      return records.where((record) {
        final formattedDate =
            '${record.date.month}/${record.date.day}/${record.date.year}';
        return formattedDate.contains(_filterText);
      }).toList();
    }
    return records;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Records History",
          style: Theme.of(context).textTheme.displaySmall,
        ),
        RecordsSearchBar(onFilter: _onFilter),
        Expanded(
          child: SingleChildScrollView(
            child: FutureBuilder<List<RecordModel>?>(
              future: firestoreDatabase.getRecordsByUser(loggedInUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('An error occurred.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No records found.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  );
                } else {
                  final records = snapshot.data;
                  final filteredRecords = _filterRecords(records!);

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];

                      return RecordClientCard(record: record);
                    },
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class RecordClientCard extends StatelessWidget {
  final RecordModel record;

  const RecordClientCard({Key? key, required this.record}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: Colors.blue, width: 2.0),
      ),
      child: GestureDetector(
        onLongPress: () {
          _generateAndShowReceipt(context, record);
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.pets, color: Colors.blue, size: 36.0),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      'Record# ${record.id.toUpperCase()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              _buildInfoRow(Icons.date_range, 'Date',
                  '${record.date.month}/${record.date.day}/${record.date.year}'),
              _buildInfoRow(Icons.pets, 'Pet Name', record.petName),
              _buildInfoRow(Icons.pets, 'Pet Breed', record.petBreed),
              _buildInfoRow(Icons.healing, 'Diagnosis', record.diagnosis),
              _buildInfoRow(Icons.notes, 'Notes', record.notes),
              _buildInfoRow(Icons.medical_services, 'Service', record.service),
              _buildInfoRow(Icons.attach_money, 'Price', '₱${record.price}'),
              _buildInfoRow(
                  Icons.payment, 'Payment Method', record.paymentMethod),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20.0, color: Colors.blue),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              '$title: $content',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _generateAndShowReceipt(
    BuildContext context, RecordModel record) async {
  final pdf = pw.Document();

  final ByteData imageData =
      await rootBundle.load('assets/images/pet_buddy_logo.png');
  final Uint8List imageBytes = imageData.buffer.asUint8List();

  pw.Widget infoRow(String label, String content) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(width: 10),
        pw.Text(content, style: const pw.TextStyle(fontSize: 14)),
      ],
    );
  }

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Image(
                pw.MemoryImage(Uint8List.fromList(imageBytes)),
                width: 150,
                height: 150,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text('Pet Buddy Veterinary Clinic',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 20)),
            ),
            pw.Center(
              child: pw.Text('1C Elizco Rd, Pasig, Metro Manila'),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text('Receipt for Record #${record.id.toUpperCase()}',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 20)),
            ),
            pw.SizedBox(height: 20),
            infoRow('Date',
                '${record.date.month}/${record.date.day}/${record.date.year}'),
            infoRow('Pet Name', record.petName),
            infoRow('Pet Breed', record.petBreed),
            infoRow('Diagnosis', record.diagnosis),
            infoRow('Notes', record.notes),
            infoRow('Service', record.service),
            infoRow('Price', 'PHP${record.price}'),
            infoRow('Payment Method', record.paymentMethod),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Thank you for choosing Pet Buddy Veterinary Clinic.',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'This serves a valid receipt.',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),
          ],
        );
      },
    ),
  );

  final pdfData = await pdf.save();

  final directory = await getExternalStorageDirectory();
  final path = '${directory!.path}/Receipt_${record.id}.pdf';

  final file = File(path);
  await file.writeAsBytes(pdfData);

  // ignore: use_build_context_synchronously
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('PDF saved to $path'),
    duration: const Duration(seconds: 5),
  ));
}
