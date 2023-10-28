import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_buddy/model/client_appointment_model.dart';
import 'package:pet_buddy/model/user_model.dart';

class FirestoreDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _userCollection = 'users';
  final String _appointmentCollection = 'appointments';
  final String _recordsCollection = 'records';

  Future<Map<String, dynamic>?> getUserInfoByUUID(String uid) async {
    try {
      final snapshot = await _firestore
          .collection(_userCollection)
          .where('uid', isEqualTo: uid)
          .get();

      final userDocument = snapshot.docs.first.data();

      return userDocument;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAppointmentListWithUserInfo() async {
    try {
      final snapshot =
          await _firestore.collection(_appointmentCollection).get();
      List<Map<String, dynamic>> appointmentList = [];

      for (var doc in snapshot.docs) {
        final appointmentData = doc.data();

        final userSnapshot = await _firestore.collection(_userCollection).get();

        appointmentData['documentID'] = doc.id;

        final userData = userSnapshot.docs.first.data();

        Map<String, dynamic> combinedData = {
          ...appointmentData,
          ...userData,
        };

        if (combinedData['status'] == 'pending' ||
            combinedData['status'] == 'accepted') {
          appointmentList.add(combinedData);
        }
      }

      return appointmentList;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecords() async {
    try {
      final snapshot = await _firestore.collection(_recordsCollection).get();
      List<Map<String, dynamic>> recordList = [];

      for (var doc in snapshot.docs) {
        final recordData = doc.data();

        final userSnapshot = await _firestore.collection(_userCollection).get();

        final userData = userSnapshot.docs.first.data();

        Map<String, dynamic> combinedData = {
          ...recordData,
          ...userData,
        };

        recordList.add(combinedData);
      }

      return recordList;
    } catch (e) {
      return [];
    }
  }

  Future<void> createNewUser(UserModel newUser) async {
    try {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection(_userCollection);

      await usersCollection.doc(newUser.uid).set(newUser.toMap());
    } catch (e) {
      return;
    }
  }

  Future<void> createAppointment(ClientAppointmentModel newAppointment) async {
    try {
      CollectionReference appointmentCollection =
          FirebaseFirestore.instance.collection(_appointmentCollection);

      await appointmentCollection.doc().set(newAppointment.toMap());
    } catch (e) {
      return;
    }
  }

  Future<List<ClientAppointmentModel>?> getAllAppointmentModelsByUser(
      String uid) async {
    List<ClientAppointmentModel> appointments = [];

    try {
      final snapshot = await _firestore
          .collection(_appointmentCollection)
          .where('uid', isEqualTo: uid)
          .get();

      for (var appointmentDoc in snapshot.docs) {
        final appointmentData = appointmentDoc.data();

        ClientAppointmentModel appointment = ClientAppointmentModel(
          id: appointmentDoc.id.toString(),
          dateTimeFrom: (appointmentData['dateTimeFrom'] as Timestamp).toDate(),
          dateTimeTo: (appointmentData['dateTimeTo'] as Timestamp).toDate(),
          petName: appointmentData['petName'].toString(),
          status: appointmentData['status'].toString(),
          uid: appointmentData['uid'].toString(),
        );

        appointments.add(appointment);
      }
    } catch (e) {
      return [];
    }

    return appointments;
  }

  Future<void> addAppointment(ClientAppointmentModel appointment) async {
    try {
      CollectionReference appointmentCollection =
          FirebaseFirestore.instance.collection(_appointmentCollection);

      appointmentCollection.add(appointment.toMap());
    } catch (e) {
      return;
    }
  }

  Future<void> deleteAppointment(String id) async {
    try {
      CollectionReference appointmentCollection =
          FirebaseFirestore.instance.collection(_appointmentCollection);

      appointmentCollection.doc(id).delete();
    } catch (e) {
      return;
    }
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    try {
      CollectionReference appointmentCollection =
          FirebaseFirestore.instance.collection(_appointmentCollection);

      appointmentCollection.doc(id).update({'status': status});
    } catch (e) {
      return;
    }
  }
}
