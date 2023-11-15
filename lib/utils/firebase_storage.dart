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

  Future<String> getImageDownloadUrl(imagePath) async {
    try {
      Reference storageReference =
          FirebaseStorage.instance.ref().child(imagePath);
      final downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return "https://firebasestorage.googleapis.com/v0/b/pet-buddy-251d5.appspot.com/o/profile-images%2Fplaceholder.jpg?alt=media&token=7c934056-bc6a-4919-b5aa-5019fc018262";
    }
  }
}
