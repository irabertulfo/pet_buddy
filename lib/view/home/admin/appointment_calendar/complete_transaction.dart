import 'package:flutter/material.dart';
import 'package:pet_buddy/model/client_appointment_model.dart';
import 'package:pet_buddy/model/records_model.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/utils/firestore_database.dart';
import 'package:intl/intl.dart';
import 'package:pet_buddy/utils/toast.dart';

// ignore: must_be_immutable
class CompleteTransactionScreen extends StatefulWidget {
  String appointmentID;
  final Future<void> onReloadCalendar;
  CompleteTransactionScreen(
      {super.key, required this.appointmentID, required this.onReloadCalendar});

  @override
  State<CompleteTransactionScreen> createState() =>
      _CompleteTransactionScreenState();
}

class _CompleteTransactionScreenState extends State<CompleteTransactionScreen> {
  FirestoreDatabase firestoreDatabase = FirestoreDatabase();

  TextEditingController dateController = TextEditingController();
  TextEditingController ownerController = TextEditingController();
  TextEditingController petNameController = TextEditingController();
  TextEditingController diagnosisController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController petBreedController = TextEditingController();
  TextEditingController serviceController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  late ClientAppointmentModel? appointment;
  late UserModel? user;

  late String? selectedPaymentMethod = 'Cash';

  @override
  void initState() {
    super.initState();

    _initializeData();
  }

  void _initializeData() async {
    appointment =
        await firestoreDatabase.getAppointmentDetails(widget.appointmentID);

    user = await firestoreDatabase.getUserInfo(appointment!.uid);

    dateController.text =
        DateFormat('MM-dd-yyyy HH:mma').format(DateTime.now());
    ownerController.text = '${user!.firstName} ${user!.lastName}';
    petNameController.text = appointment!.petName;
  }

  void handlePaymentMethodSelected(String? selectedMethod) {
    selectedPaymentMethod = selectedMethod;
    print('Selected Payment Method: $selectedMethod');
  }

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
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
                child: const Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.date_range),
                    labelText: 'Date',
                    hintText: "Date",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: ownerController,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    labelText: 'Owner',
                    hintText: "Owner",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  readOnly: true,
                  controller: petNameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.pets),
                    labelText: 'Pet Name',
                    hintText: "Pet Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: petBreedController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.pets),
                    labelText: 'Breed',
                    hintText: "Breed",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: diagnosisController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.medical_information),
                    labelText: 'Diagnosis',
                    hintText: "What's your diagnosis?",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: notesController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.note),
                    labelText: 'Note',
                    hintText: "Note/prescription",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: serviceController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.room_service),
                    labelText: 'Service',
                    hintText: "Services",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefix: const Text('₱ '),
                    prefixIcon: const Icon(
                        IconData(0x20B1, fontFamily: 'MaterialIcons')),
                    labelText: 'Price',
                    hintText: "Price",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: PaymentMethodDropdown(
                    onPaymentMethodSelected: handlePaymentMethodSelected,
                  )),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ElevatedButton(
                  onPressed: () {
                    if (petBreedController.text == '') {
                      Toast.show(context, 'Breed is required.');
                    } else if (diagnosisController.text == '') {
                      Toast.show(context, 'Diagnosis is required.');
                    } else if (notesController.text == '') {
                      Toast.show(context, 'Note is required.');
                    } else if (serviceController.text == '') {
                      Toast.show(context, 'Service is required.');
                    } else if (priceController.text == '') {
                      Toast.show(context, 'Price is required.');
                    } else {
                      if (selectedPaymentMethod == 'GCash') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const ImageDialog();
                          },
                        ).then((value) {
                          firestoreDatabase.updateAppointmentStatus(
                              widget.appointmentID, 'completed');

                          RecordModel newRecord = RecordModel(
                              id: '',
                              uid: user!.uid,
                              date: DateTime.now(),
                              owner: ownerController.text,
                              diagnosis: diagnosisController.text,
                              notes: notesController.text,
                              petBreed: petBreedController.text,
                              petName: petNameController.text,
                              service: serviceController.text,
                              price: double.parse(priceController.text),
                              paymentMethod: selectedPaymentMethod!);

                          firestoreDatabase.createRecord(newRecord);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                      } else {
                        firestoreDatabase.updateAppointmentStatus(
                            widget.appointmentID, 'completed');

                        RecordModel newRecord = RecordModel(
                          id: '',
                          uid: user!.uid,
                          date: DateTime.now(),
                          owner: ownerController.text,
                          diagnosis: diagnosisController.text,
                          notes: notesController.text,
                          petBreed: petBreedController.text,
                          petName: petNameController.text,
                          service: serviceController.text,
                          price: double.parse(priceController.text),
                          paymentMethod: selectedPaymentMethod!,
                        );

                        firestoreDatabase.createRecord(newRecord);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text('COMPLETE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentMethodDropdown extends StatefulWidget {
  final Function(String?) onPaymentMethodSelected;

  const PaymentMethodDropdown(
      {super.key, required this.onPaymentMethodSelected});

  @override
  PaymentMethodDropdownState createState() => PaymentMethodDropdownState();
}

class PaymentMethodDropdownState extends State<PaymentMethodDropdown> {
  String? selectedPaymentMethod = 'Cash';

  List<Map<String, dynamic>> paymentMethods = [
    {'name': 'Cash', 'icon': Icons.monetization_on},
    {'name': 'GCash', 'icon': Icons.phone_android},
    {'name': 'Credit/Debit (coming soon)', 'icon': Icons.credit_card},
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton<String>(
        value: selectedPaymentMethod,
        icon: const Icon(Icons.arrow_drop_down),
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(color: Colors.deepPurple),
        onChanged: (String? newValue) {
          if (newValue != 'Credit/Debit (coming soon)') {
            setState(() {
              selectedPaymentMethod = newValue;
            });
            widget.onPaymentMethodSelected(newValue);
          }
        },
        items: paymentMethods.map((Map<String, dynamic> paymentMethod) {
          return DropdownMenuItem<String>(
            value: paymentMethod['name'],
            child: Row(
              children: [
                Icon(paymentMethod['icon'], size: 24),
                const SizedBox(width: 10),
                Text(paymentMethod['name']),
              ],
            ),
            onTap: () {
              if (paymentMethod['name'] == 'Credit/Debit (coming soon)') {
                return;
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

class ImageDialog extends StatelessWidget {
  const ImageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Container(
            color: Colors.black,
            child: Center(
              child: Image.asset(
                'assets/images/gcash-qr.jpg',
                fit: BoxFit
                    .contain, // Ensure the image fits within the container
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              child: const Row(
                children: [
                  Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  Text(
                    "Go Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20, // Adjusted font size for a better look
                      fontWeight: FontWeight.bold, // Added bold style
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
