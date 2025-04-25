import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/intern/intern_controller.dart';
import 'package:jooyful_heaven/services/article_service.dart';
import 'package:jooyful_heaven/services/file_service.dart';
import 'package:jooyful_heaven/services/realtime_db_service.dart';

class InternBindings extends Bindings {
  @override
  void dependencies() {
    // Register services
    Get.lazyPut<RealtimeDbService>(() => RealtimeDbService());
    Get.lazyPut<FileService>(() => FileService());
    Get.lazyPut<ArticleService>(() => ArticleService(Get.find<RealtimeDbService>()));
    
    // Register controller
    Get.lazyPut<InternController>(() => InternController(
      articleService: Get.find<ArticleService>(),
      fileService: Get.find<FileService>(),
    ));
  }
}