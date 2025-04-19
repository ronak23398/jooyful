import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/counsellor_controller.dart';
import 'package:jooyful_heaven/services/realtime_db_service.dart';
import '../services/firebase_auth_service.dart';

class CounselorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CounselorController>(() => CounselorController(
          authService: Get.find<FirebaseAuthService>(),
          dbService: Get.find<RealtimeDbService>(),
        ));
  }
}