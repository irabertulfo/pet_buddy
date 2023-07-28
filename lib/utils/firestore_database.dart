import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_buddy/model/user_model.dart';

class FirestoreDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _userCollection = 'users';
  final String _appointmentCollection = 'appointments';

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

        final userSnapshot = await _firestore
            .collection(_userCollection)
            .where('uid', isEqualTo: appointmentData['uid'])
            .get();

        final userData = userSnapshot.docs.first.data();

        Map<String, dynamic> combinedData = {
          ...appointmentData,
          ...userData,
        };

        appointmentList.add(combinedData);
      }

      return appointmentList;
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
}
