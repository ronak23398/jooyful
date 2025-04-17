import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import '../services/firebase_auth_service.dart';
import '../services/realtime_db_service.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    // Register FirebaseAuthService
    Get.lazyPut<FirebaseAuthService>(
      () => FirebaseAuthService(),
      fenix: true,
    );
    
    // Register RealtimeDbService
    Get.lazyPut<RealtimeDbService>(
      () => RealtimeDbService(),
      fenix: true,
    );

    // Register AuthController
    Get.lazyPut<AuthController>(
      () => AuthController(),
      fenix: true,
    );
  }
}