import 'package:get/get.dart';
import '../controllers/owner_controller.dart';
import '../services/realtime_db_service.dart';

class OwnerBinding implements Bindings {
  @override
  void dependencies() {
    // Register RealtimeDbService if not already registered
    if (!Get.isRegistered<RealtimeDbService>()) {
      Get.lazyPut<RealtimeDbService>(
        () => RealtimeDbService(),
        fenix: true,
      );
    }
    
    // Register OwnerController
    Get.lazyPut<OwnerController>(
      () => OwnerController(),
      fenix: true,
    );
  }
}