import 'package:flutter/material.dart';

class RecordCard extends StatelessWidget {
  final DateTime date;
  final String diagnosis;
  final String notes;
  final String petBreed;
  final String petName;
  final String service;
  final String owner;
  final double price;
  final String paymentMethod;

  const RecordCard({
    Key? key,
    required this.date,
    required this.diagnosis,
    required this.notes,
    required this.petBreed,
    required this.petName,
    required this.service,
    required this.owner,
    required this.price,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.pets, color: Colors.blue),
                Text(
                  'Pet Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                Icon(Icons.pets, color: Colors.blue),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                const Icon(Icons.date_range, size: 16.0),
                const SizedBox(width: 5.0),
                Flexible(
                  child: Text(
                    'Date: ${_formattedDate(date)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.person, size: 16.0),
                const SizedBox(width: 5.0),
                Flexible(
                  child: Text(
                    'Owner: $owner',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            Row(
              children: [
                const Icon(Icons.notes, size: 16.0),
                const SizedBox(width: 5.0),
                Flexible(
                  child: Text('Diagnosis: $diagnosis'),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            Row(
              children: [
                const Icon(Icons.notes, size: 16.0),
                const SizedBox(width: 5.0),
                Flexible(
                  child: Text('Notes: $notes'),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            Row(
              children: [
                const Icon(Icons.pets, size: 16.0),
                const SizedBox(width: 5.0),
                Flexible(
                  child: Text('Pet Breed: $petBreed'),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            Row(
              children: [
                const Icon(Icons.pets, size: 16.0),
                const SizedBox(width: 5.0),
                Flexible(
                  child: Text('Pet Name: $petName'),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            Row(
              children: [
                const Icon(Icons.room_service, size: 16.0),
                const SizedBox(width: 5.0),
                Flexible(
                  child: Text('Service: $service'),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            Row(
              children: [
                const Icon(Icons.credit_card, size: 16.0),
                const SizedBox(width: 5.0),
                Flexible(
                  child: Text('Price: PHP $price'),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            Row(
              children: [
                const Icon(Icons.phone_android_outlined, size: 16.0),
                const SizedBox(width: 5.0),
                Flexible(
                  child: Text('Payment Method: $paymentMethod'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formattedDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
