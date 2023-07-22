import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> uploadFile(File file, String originalFilename) async {
    try {
      Reference ref = _storage.ref().child(originalFilename);

      await ref.putFile(file);
    } catch (e) {
      throw Exception('Failed to upload file');
    }
  }
}
