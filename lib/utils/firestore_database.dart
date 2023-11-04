import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_buddy/model/client_appointment_model.dart';
import 'package:pet_buddy/model/inventory_model.dart';
import 'package:pet_buddy/model/records_model.dart';
import 'package:pet_buddy/model/user_model.dart';

class FirestoreDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _userCollection = 'users';
  final String _appointmentCollection = 'appointments';
  final String _recordsCollection = 'records';
  final String _inventoryCollection = 'inventory';
  final String _categoryCollection = 'categories';

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

  Future<void> createRecord(RecordModel record) async {
    try {
      await _firestore.collection(_recordsCollection).add(record.toMap());
    } catch (e) {
      print(e.toString);
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
      print(e.toString());
      return [];
    }
  }

  Future<UserModel?> getUserInfo(String uid) async {
    CollectionReference userCollection =
        FirebaseFirestore.instance.collection(_userCollection);

    final snapshot = await userCollection.doc(uid).get();
    final userData = snapshot.data()! as Map<String, dynamic>;

    UserModel user = UserModel(
        uid: uid,
        email: userData['email'],
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        profileImagePath: userData['profileImagePath'],
        userType: userData['userType']);

    return user;
  }

  Future<ClientAppointmentModel?> getAppointmentDetails(String id) async {
    try {
      final snapshot =
          await _firestore.collection(_appointmentCollection).doc(id).get();

      final appointmentData = snapshot.data()!;

      ClientAppointmentModel appointment = ClientAppointmentModel(
          id: id,
          dateTimeFrom: appointmentData['dateTimeFrom'].toDate(),
          dateTimeTo: appointmentData['dateTimeTo'].toDate(),
          petName: appointmentData['petName'],
          status: appointmentData['status'],
          uid: appointmentData['uid']);

      return appointment;
    } catch (e) {
      print(e.toString());
      return null;
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

  Future<RecordModel> getRecordById(String id) async {
    CollectionReference recordsCollection =
        FirebaseFirestore.instance.collection(_recordsCollection);

    final snapshot = await recordsCollection.doc(id).get();
    final recordData = snapshot.data()! as Map<String, dynamic>;

    RecordModel record = RecordModel(
        id: id,
        uid: recordData['uid']!,
        date: recordData['date']!,
        owner: recordData['owner']!,
        diagnosis: recordData['diagnosis']!,
        notes: recordData['notes']!,
        petBreed: recordData['petBreed']!,
        petName: recordData['petName']!,
        service: recordData['service']!,
        price: recordData['price']!,
        paymentMethod: recordData['paymentMethod']!);

    return record;
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

  Future<List<CategoryModel>> getAllCategories() async {
    List<CategoryModel> categories = [];

    try {
      final categoriesSnapshot =
          await _firestore.collection(_categoryCollection).get();

      CategoryModel placeholder = CategoryModel(id: '', name: 'All');
      categories.add(placeholder);

      for (var doc in categoriesSnapshot.docs) {
        final categoryData = doc.data();

        CategoryModel category =
            CategoryModel(id: doc.id, name: categoryData['name']);

        categories.add(category);
      }
    } catch (e) {
      print(e.toString());
    }

    return categories;
  }

  Future<List<InventoryModel>> getAllInventory() async {
    List<InventoryModel> items = [];
    try {
      final inventorySnapshot =
          await _firestore.collection(_inventoryCollection).get();

      for (var doc in inventorySnapshot.docs) {
        final inventoryData = doc.data();

        final categorySnapshot = await _firestore
            .collection(_categoryCollection)
            .doc(inventoryData['categoryId'])
            .get();
        final categoryData = categorySnapshot.data();

        CategoryModel category = CategoryModel(
            id: inventoryData['categoryId'], name: categoryData!['name']);

        InventoryModel item = InventoryModel(
            id: doc.id,
            category: category,
            name: inventoryData['name'],
            stock: inventoryData['stock']);

        items.add(item);
      }
    } catch (e) {
      print(e.toString());
    }

    return items;
  }

  Future<void> updateItemStock(String id, String method) async {
    try {
      final inventorySnapshot =
          await _firestore.collection(_inventoryCollection).doc(id).get();

      if (inventorySnapshot.exists) {
        final currentStock = inventorySnapshot.data()!['stock'];
        int newStock;

        if (method == 'add') {
          newStock = currentStock + 1;
        } else if (method == 'subtract') {
          newStock = currentStock - 1;
        } else {
          print("Invalid method. Use 'add' or 'subtract'.");
          return;
        }

        await _firestore.collection(_inventoryCollection).doc(id).update({
          'stock': newStock,
        });
      } else {
        print("Item with ID $id not found in the inventory.");
      }
    } catch (e) {
      print(e.toString());
      return;
    }
  }

  Future<void> deleteItemInInventory(String id) async {
    try {
      final itemDoc = _firestore.collection(_inventoryCollection).doc(id);
      await itemDoc.delete();
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  Future<void> addItemToInventory(InventoryModel item) async {
    try {
      final inventoryCollection = _firestore.collection(_inventoryCollection);
      await inventoryCollection.add(item.toMap());
    } catch (e) {
      print('Error adding item: $e');
    }
  }
}
