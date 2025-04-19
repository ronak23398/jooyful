

import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/counsellor/counsellor_controller.dart';
import 'package:jooyful_heaven/services/firebase_auth_service.dart';
import 'package:jooyful_heaven/services/realtime_db_service.dart';

class CounselorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CounselorController>(() => CounselorController(
          authService: Get.find<FirebaseAuthService>(),
          dbService: Get.find<RealtimeDbService>(),
        ));
  }
}