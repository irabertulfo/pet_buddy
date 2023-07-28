import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pet_buddy/utils/firestore_database.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
            dataSource: _getCalendarDataSource(snapshot.data!),
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
    ));
  }

  return _AppointmentDataSource(appointments);
}
