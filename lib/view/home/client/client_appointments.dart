import 'package:flutter/material.dart';
import 'package:pet_buddy/model/client_appointment_model.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/utils/firestore_database.dart';
import 'package:pet_buddy/utils/toast.dart';

class ClientAppointment extends StatefulWidget {
  const ClientAppointment({Key? key});

  @override
  State<ClientAppointment> createState() => _ClientAppointmentState();
}

class _ClientAppointmentState extends State<ClientAppointment> {
  FirestoreDatabase firestore = FirestoreDatabase();
  List<ClientAppointmentModel> appointments = [];
  bool isLoading = true;

  UserModel? user = UserSingleton().user;

  Future<void> refreshData() async {
    List<ClientAppointmentModel>? refreshedAppointments =
        await firestore.getAllAppointmentModelsByUser(user!.uid);

    if (refreshedAppointments != null) {
      setState(() {
        appointments = refreshedAppointments;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        RefreshIndicator(
          onRefresh: refreshData,
          child: ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              return AppointmentCard(
                appointment: appointments[index],
                onRefresh: refreshData,
              );
            },
          ),
        ),
        Positioned(
          bottom: 16.0,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton(
              onPressed: () {
                _showAddAppointmentDialog(context);
              },
              child: Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddAppointmentDialog(BuildContext context) {
    TextEditingController petNameController = TextEditingController();
    DateTime selectedStartDate = DateTime.now();
    DateTime selectedEndDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: petNameController,
                decoration: InputDecoration(labelText: 'Pet Name'),
              ),
              SizedBox(height: 10),
              DateTimePicker(
                initialDate: selectedStartDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                labelText: 'Start Date and Time',
                onDateTimeChanged: (date) {
                  selectedStartDate = date;
                },
              ),
              DateTimePicker(
                initialDate: selectedEndDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                labelText: 'End Date and Time',
                onDateTimeChanged: (date) {
                  selectedEndDate = date;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                ClientAppointmentModel newAppointment = ClientAppointmentModel(
                    id: '',
                    dateTimeFrom: selectedStartDate,
                    dateTimeTo: selectedEndDate,
                    petName: petNameController.text,
                    status: 'pending',
                    uid: user!.uid);

                firestore.addAppointment(newAppointment);

                Navigator.of(context).pop();
                Toast.show(
                    context, "Appointment added. Wait for confirmation!");
                refreshData();
              },
            ),
          ],
        );
      },
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final ClientAppointmentModel appointment;
  final VoidCallback onRefresh;

  const AppointmentCard(
      {Key? key, required this.appointment, required this.onRefresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirestoreDatabase firestore = FirestoreDatabase();

    return GestureDetector(
      onLongPress: () async {
        firestore.deleteAppointment(appointment.id);
        Toast.show(context, 'Appointment for ${appointment.petName} cancelled');
        onRefresh();
      },
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.blue, width: 2.0),
        ),
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
                  Icon(Icons.pets, color: Colors.blue, size: 36.0),
                  const SizedBox(width: 10.0),
                  Text(
                    'Appointment Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              _buildInfoRow(Icons.date_range,
                  'Date: ${_formattedDate(appointment.dateTimeFrom)}'),
              _buildInfoRow(Icons.punch_clock,
                  'Start: ${_formattedTime(appointment.dateTimeFrom)}'),
              _buildInfoRow(Icons.punch_clock,
                  'End: ${_formattedTime(appointment.dateTimeTo)}'),
              _buildInfoRow(Icons.pets, 'Pet Name: ${appointment.petName}'),
              _buildInfoRow(Icons.flag_circle, 'Status: ${appointment.status}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20.0, color: Colors.blue),
        const SizedBox(width: 10.0),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 18.0,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  String _formattedDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formattedTime(DateTime time) {
    String formattedTime =
        '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    String period = time.hour < 12 ? 'AM' : 'PM';
    if (time.hour > 12) {
      formattedTime =
          '${time.hour - 12}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '$formattedTime $period';
  }
}

class DateTimePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String labelText;
  final ValueChanged<DateTime> onDateTimeChanged;

  DateTimePicker({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.labelText,
    required this.onDateTimeChanged,
  }) : super(key: key);

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.labelText),
        ListTile(
          title: Text(
            "${selectedDate.toLocal()}".split(' ')[0],
          ),
          trailing: Icon(Icons.keyboard_arrow_down),
          onTap: () async {
            DateTime? date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate);
            if (date != null && date != selectedDate) {
              setState(() {
                selectedDate = date;
                widget.onDateTimeChanged(date);
              });
            }
          },
        ),
        ListTile(
          title: Text(
            "${selectedDate.toLocal()}".split(' ')[1],
          ),
          trailing: Icon(Icons.keyboard_arrow_down),
          onTap: () async {
            TimeOfDay? t = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(selectedDate));
            if (t != null) {
              DateTime newDate = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                t.hour,
                t.minute,
              );
              setState(() {
                selectedDate = newDate;
                widget.onDateTimeChanged(newDate);
              });
            }
          },
        ),
      ],
    );
  }
}
