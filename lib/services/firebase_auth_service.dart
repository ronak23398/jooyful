import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/client_controllers/client_chat_controller.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw e;
    }
  }

  // Sign up with email and password
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw e;
    }
  }

  // Sign out
 Future<void> signOut() async {
  try {
    // Clean up all Firebase listeners before sign out
    _cleanupAllListeners();
    
    // Then sign out
    return await _auth.signOut();
  } catch (e) {
    throw e;
  }
}

void _cleanupAllListeners() {
  // Clean up ClientChatController listeners if it exists
  if (Get.isRegistered<ClientChatController>()) {
    Get.find<ClientChatController>().cancelAllListeners();
  }
  
  // Clean up any other controllers with Firebase listeners
  // Add similar checks for other controllers
}

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw e;
    }
  }
}