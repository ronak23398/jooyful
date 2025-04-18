import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();
  
  // Upload article image to Firebase Storage
  Future<String> uploadArticleImage(File imageFile) async {
    try {
      // Generate a unique filename
      final String fileName = '${_uuid.v4()}${path.extension(imageFile.path)}';
      
      // Create a reference to the path in storage
      final Reference storageRef = _storage.ref().child('articles/$fileName');
      
      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get the download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
  
  // Delete article image from Firebase Storage
  Future<void> deleteArticleImage(String imageUrl) async {
    try {
      // Extract the path from the full URL
      final Reference storageRef = _storage.refFromURL(imageUrl);
      
      // Delete the file
      await storageRef.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}