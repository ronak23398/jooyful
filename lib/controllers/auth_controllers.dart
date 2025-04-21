import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jooyful_heaven/routes/app_routes.dart';
import '../services/firebase_auth_service.dart';
import '../services/realtime_db_service.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final RealtimeDbService _dbService = RealtimeDbService();
  
  // Observable variables
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString selectedRole = 'client'.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_authService.authStateChanges);
    ever(firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) async {
  // Add a small delay to ensure GetMaterialApp is initialized
  await Future.delayed(Duration(milliseconds: 100));
  
  if (user == null) {
    // Not logged in, navigate to login
    Get.offAllNamed(AppRoutes.LOGIN);
  } else {
      // User logged in, get user data
      try {
        isLoading.value = true;
        userModel.value = await _dbService.getUserData(user.uid);
        // Only navigate if user model is not null
        if (userModel.value != null) {
          _navigateBasedOnRole();
        } else {
          // Handle case where user exists in Auth but not in Realtime DB
          Get.snackbar('Error', 'User profile not found');
          await _authService.signOut(); // Sign out and return to login
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to load user data: ${e.toString()}');
      } finally {
        isLoading.value = false;
      }
    }
  }

  void _navigateBasedOnRole() {
    // Add null check to prevent null pointer exception
    if (userModel.value == null) {
      Get.offAllNamed(AppRoutes.LOGIN);
      return;
    }
    
    final role = userModel.value?.role;
    switch (role) {
      case 'owner':
        Get.offAllNamed(AppRoutes.OWNER_HOME);
        break;
      case 'client':
        Get.offAllNamed(AppRoutes.CLIENT_HOME);
        break;
      case 'counselor':
        Get.offAllNamed(AppRoutes.COUNSELOR_HOME);
        break;
      case 'intern':
        Get.offAllNamed(AppRoutes.INTERN_HOME);
        break;
      default:
        // Role not set or invalid, stay on login
        Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  // Sign up with email
  Future<void> signup(String name, String email, String password) async {
    try {
      isLoading.value = true;
      
      // 1. First create the auth user
      User? user = await _authService.signUp(email, password);
      
      if (user != null) {
        print("Firebase Auth user created with UID: ${user.uid}");
        
        // 2. Create user model with current timestamp for createdAt
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          role: selectedRole.value,
          createdAt: DateTime.now(),
        );
        
        print("About to save user to Realtime DB: ${newUser.toMap()}");
        
        // 3. Save to database
        try {
          await _dbService.createUser(newUser);
          print("User successfully saved to Realtime DB");
          
          // 4. Set user model
          userModel.value = newUser;
          
          Get.snackbar('Success', 'Account created successfully');
          
          // Explicitly navigate based on role instead of waiting for the auth stream
          _navigateBasedOnRole();
        } catch (dbError) {
          print("Database error: $dbError");
          // If DB save fails, delete the auth user to maintain consistency
          await user.delete();
          throw dbError;
        }
      } else {
        throw Exception("Failed to create user account");
      }
    } catch (e) {
      print("Signup error: $e");
      Get.snackbar('Error', 'Failed to create account: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Login with email
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _authService.signIn(email, password);
      // _setInitialScreen will handle navigation via the auth state stream
    } catch (e) {
      Get.snackbar('Error', 'Failed to login: ${e.toString()}');
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> logout() async {
    try {
      await _authService.signOut();
      userModel.value = null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: ${e.toString()}');
    }
  }

  // Check if user is owner (for admin functions)
  bool isOwner() {
    return userModel.value?.role == 'owner';
  }
}