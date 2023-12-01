import 'package:flutter/material.dart';
import 'package:pet_buddy/model/client_appointment_model.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/utils/firestore_database.dart';
import 'package:pet_buddy/utils/toast.dart';

class ClientAppointment extends StatefulWidget {
  const ClientAppointment({super.key});

  @override
  State<ClientAppointment> createState() => _ClientAppointmentState();
}

class _ClientAppointmentState extends State<ClientAppointment> {
  FirestoreDatabase firestore = FirestoreDatabase();
  List<ClientAppointmentModel> appointments = [];
  bool isLoading = true;

  UserModel? user = UserSingleton().user;

  bool isInfoVisible = false; // Move the variable here

  Future<void> refreshData() async {
    List<ClientAppointmentModel>? refreshedAppointments =
        await firestore.getAllAppointmentModelsByUser(user!.uid);

    if (refreshedAppointments != null) {
      List<ClientAppointmentModel> filteredAppointments = refreshedAppointments
          .where((appointment) =>
              ['pending', 'accepted', 'cancelled'].contains(appointment.status))
          .toList();

      setState(() {
        appointments = filteredAppointments;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        RefreshIndicator(
          onRefresh: refreshData,
          child: appointments.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No appointments. You can set one by pressing the button below.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
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
              child: const Icon(Icons.add),
            ),
          ),
        ),
        // New section for info icon
        if (isInfoVisible) // Only show the info text when isInfoVisible is true
          Positioned(
            bottom: 70.0,
            right: 16.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.info, color: Colors.grey),
                SizedBox(width: 5.0),
                Text(
                  'Long press an appointment to cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showAddAppointmentDialog(BuildContext context) {
    TextEditingController petNameController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController timeFromController = TextEditingController();
    TextEditingController timeToController = TextEditingController();

    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTimeFrom = TimeOfDay.now();
    TimeOfDay selectedTimeTo = TimeOfDay.now();

    Future<void> selectDate(BuildContext context) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
      );
      if (pickedDate != null && pickedDate != selectedDate) {
        setState(() {
          selectedDate = pickedDate;
          dateController.text =
              "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year.toString()}";
        });
      }
    }

    Future<void> selectTime(
        BuildContext context, TimeOfDay selectedTime, String timeType) async {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime,
      );
      if (pickedTime != null && pickedTime != selectedTime) {
        setState(() {
          if (timeType == 'from') {
            selectedTimeFrom = pickedTime;
            timeFromController.text =
                "${selectedTimeFrom.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
          } else if (timeType == 'to') {
            selectedTimeTo = pickedTime;
            timeToController.text =
                "${selectedTimeTo.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
          }
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Appointment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: TextField(
                    onTap: () => selectDate(context),
                    readOnly: true,
                    controller: dateController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_month),
                      labelText: 'Date',
                      hintText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: TextField(
                    onTap: () => selectTime(context, selectedTimeFrom, 'from'),
                    readOnly: true,
                    controller: timeFromController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.watch),
                      labelText: 'Time From',
                      hintText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: TextField(
                    onTap: () => selectTime(context, selectedTimeFrom, 'to'),
                    readOnly: true,
                    controller: timeToController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.watch),
                      labelText: 'Time To',
                      hintText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: TextField(
                    controller: petNameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.pets),
                      labelText: 'Pet Name',
                      hintText: 'e.g., Beymax',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                ClientAppointmentModel newAppointment = ClientAppointmentModel(
                  id: '',
                  dateTimeFrom: DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTimeFrom.hour,
                    selectedTimeFrom.minute,
                  ),
                  dateTimeTo: DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTimeTo.hour,
                    selectedTimeTo.minute,
                  ),
                  petName: petNameController.text,
                  status: 'pending',
                  uid: user!.uid,
                );

                firestore.addAppointment(newAppointment);

                Navigator.of(context).pop();
                Toast.show(
                  context,
                  "Appointment added. Wait for confirmation!",
                );
                refreshData();
              },
            ),
          ],
        );
      },
    );
  }
}

class AppointmentCard extends StatefulWidget {
  final ClientAppointmentModel appointment;
  final VoidCallback onRefresh;

  const AppointmentCard(
      {Key? key, required this.appointment, required this.onRefresh})
      : super(key: key);

  @override
  _AppointmentCardState createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  FirestoreDatabase firestore = FirestoreDatabase();
  bool isInfoVisible = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        firestore.deleteAppointment(widget.appointment.id);
        Toast.show(context, 'Appointment for ${widget.appointment.petName} cancelled');
        widget.onRefresh();
      },
      onTap: () {
        // Toggle visibility of the info text when tapped
        setState(() {
          isInfoVisible = !isInfoVisible;
        });
      },
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: Colors.blue, width: 2.0),
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
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      'Appointment Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              _buildInfoRow(Icons.date_range,
                  'Date: ${_formattedDate(widget.appointment.dateTimeFrom)}'),
              _buildInfoRow(Icons.punch_clock,
                  'Start: ${_formattedTime(widget.appointment.dateTimeFrom)}'),
              _buildInfoRow(Icons.punch_clock,
                  'End: ${_formattedTime(widget.appointment.dateTimeTo)}'),
              _buildInfoRow(
                  Icons.pets, 'Pet Name: ${widget.appointment.petName}'),
              _buildInfoRow(
                  Icons.flag_circle, 'Status: ${widget.appointment.status}'),
              // Updated section for info icon with added space
              SizedBox(height: 10.0),
              if (isInfoVisible) // Only show the info text when isInfoVisible is true
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.info, color: Colors.grey),
                    SizedBox(width: 5.0),
                    Text(
                      'Long press to cancel appointment',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
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

  const DateTimePicker({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.labelText,
    required this.onDateTimeChanged,
  }) : super(key: key);

  @override
  DateTimePickerState createState() => DateTimePickerState();
}

class DateTimePickerState extends State<DateTimePicker> {
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
          trailing: const Icon(Icons.keyboard_arrow_down),
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
      ],
    );
  }
}
