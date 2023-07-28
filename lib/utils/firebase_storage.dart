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
      print('Error getting image download URL: $e');
      // Return a placeholder URL or some default image URL in case of an error.
      return "YOUR_PLACEHOLDER_URL_OR_DEFAULT_IMAGE_URL";
    }
  }
}
