import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pet_buddy/utils/firestore_database.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}

class AppointmentCalendar extends StatefulWidget {
  const AppointmentCalendar({super.key});

  @override
  AppointmentCalendarState createState() => AppointmentCalendarState();
}

class AppointmentCalendarState extends State<AppointmentCalendar> {
  FirestoreDatabase firestoreDatabase = FirestoreDatabase();
  String selectedAppointmentID = '';

  Future<void> _showDialog(Appointment appointment) async {
    String status = appointment.notes!.split(',')[1];
    String owner = appointment.subject;
    String date = DateFormat.yMMMMd().format(appointment.startTime);
    String timeFrom = DateFormat.jm().format(appointment.startTime);
    String timeTo = DateFormat.jm().format(appointment.endTime);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    (status == 'pending')
                        ? 'Appointment Details'
                        : 'Scheduled Appointment',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      _buildInfoRow('Owner:', owner),
                      _buildInfoRow('Date:', date),
                      _buildInfoRow('Time:', '$timeFrom - $timeTo'),
                    ],
                  ),
                ),
                if (status == 'pending')
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton('Reject', Colors.red, () {
                          firestoreDatabase.updateAppointmentStatus(
                              selectedAppointmentID, 'rejected');
                          _updateCalendarData();
                          Navigator.of(context).pop();
                        }),
                        _buildActionButton('Accept', Colors.green, () {
                          firestoreDatabase.updateAppointmentStatus(
                              selectedAppointmentID, 'accepted');
                          _updateCalendarData();
                          Navigator.of(context).pop();
                        }),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildActionButton('Cancel Appointment', Colors.blue,
                        () {
                      firestoreDatabase.updateAppointmentStatus(
                          selectedAppointmentID, 'cancelled');
                      _updateCalendarData();
                      Navigator.of(context).pop();
                    }),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: color,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _updateCalendarData() async {
    final data = await firestoreDatabase.getAppointmentListWithUserInfo();
    setState(() {
      calendarDataSource = _getCalendarDataSource(data);
    });
  }

  CalendarDataSource calendarDataSource = _AppointmentDataSource([]);

  @override
  void initState() {
    super.initState();
    _updateCalendarData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>?>(
      future: firestoreDatabase.getAppointmentListWithUserInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('No data available.'));
        } else {
          return SfCalendar(
            view: CalendarView.month,
            monthViewSettings: const MonthViewSettings(showAgenda: true),
            timeZone: 'Singapore Standard Time',
            dataSource: calendarDataSource,
            onLongPress: (CalendarLongPressDetails details) {
              if (details.appointments != null &&
                  details.appointments!.isNotEmpty) {
                Appointment appointment = details.appointments![0];

                selectedAppointmentID = appointment.notes!.split(',')[0];

                _showDialog(appointment);
              }
            },
          );
        }
      },
    );
  }
}

_AppointmentDataSource _getCalendarDataSource(List<Map<String, dynamic>> data) {
  List<Appointment> appointments = <Appointment>[];
  Random random = Random();

  for (var appointmentData in data) {
    DateTime startTime = appointmentData['dateTimeFrom'].toDate();
    DateTime endTime = appointmentData['dateTimeTo'].toDate();
    String subject =
        '${appointmentData['firstName']} ${appointmentData['lastName']}';
    String id = appointmentData['documentID'];
    String status = appointmentData['status'];
    Color color = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );

    appointments.add(Appointment(
        startTime: startTime,
        endTime: endTime,
        subject: subject,
        color: color,
        startTimeZone: '',
        endTimeZone: '',
        notes: '${id},${status}'));
  }

  return _AppointmentDataSource(appointments);
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
