class ClientAppointmentModel {
  final DateTime dateTimeFrom;
  final DateTime dateTimeTo;
  final String petName;
  final String status;
  final String uid;
  final String id;

  const ClientAppointmentModel({
    required this.id,
    required this.dateTimeFrom,
    required this.dateTimeTo,
    required this.petName,
    required this.status,
    required this.uid,
  });

  Map<String, dynamic> toMap() {
    return {
      'dateTimeFrom': dateTimeFrom,
      'dateTimeTo': dateTimeTo,
      'petName': petName,
      'status': status,
      'uid': uid,
    };
  }
}
