

import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import 'package:jooyful_heaven/controllers/client_controllers/client_controllers.dart';
import 'package:jooyful_heaven/services/realtime_db_service.dart';

class ClientBinding implements Bindings {
  @override
  void dependencies() {
    // Ensure RealtimeDbService is registered
    if (!Get.isRegistered<RealtimeDbService>()) {
      Get.lazyPut<RealtimeDbService>(
        () => RealtimeDbService(),
        fenix: true,
      );
    }
    
    // Ensure AuthController is registered
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(
        () => AuthController(),
        fenix: true,
      );
    }
    
    // Register ClientController
    Get.lazyPut<ClientController>(
      () => ClientController(),
      fenix: true,
    );
  }

  
}