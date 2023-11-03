import 'package:cloud_firestore/cloud_firestore.dart';

class RecordModel {
  final String id;
  final String uid;
  final DateTime date;
  final String owner;
  final String diagnosis;
  final String notes;
  final String petBreed;
  final String petName;
  final String service;
  final double price;
  final String paymentMethod;

  const RecordModel(
      {required this.id,
      required this.uid,
      required this.date,
      required this.owner,
      required this.diagnosis,
      required this.notes,
      required this.petBreed,
      required this.petName,
      required this.service,
      required this.price,
      required this.paymentMethod});

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'diagnosis': diagnosis,
      'notes': notes,
      'petBreed': petBreed,
      'petName': petName,
      'price': price,
      'service': service,
      'uid': uid,
      'paymentMethod': paymentMethod
    };
  }
}
