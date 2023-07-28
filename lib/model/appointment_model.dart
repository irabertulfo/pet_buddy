import 'package:flutter/material.dart';

class AppointmentModel {
  final String title;
  final String description;
  final DateTime dateTimeFrom;
  final DateTime dateTimeTo;
  final Color backgroundColor;
  final bool isAllDay;

  const AppointmentModel(
      {required this.title,
      required this.description,
      required this.dateTimeFrom,
      required this.dateTimeTo,
      this.backgroundColor = Colors.lightBlue,
      this.isAllDay = false});
}
