// import 'package:get/get.dart';
// import 'package:jooyful_heaven/controllers/intern/article_detail_controller.dart';
// import 'package:jooyful_heaven/services/article_service.dart';
// import 'package:jooyful_heaven/services/bookmark_service.dart';
// import 'package:jooyful_heaven/services/realtime_db_service.dart';

// class ArticleDetailBindings extends Bindings {
//   @override
//   void dependencies() {
//     // Make sure required services are registered
//     if (!Get.isRegistered<RealtimeDbService>()) {
//       Get.lazyPut<RealtimeDbService>(() => RealtimeDbService());
//     }
    
//     if (!Get.isRegistered<ArticleService>()) {
//       Get.lazyPut<ArticleService>(() => ArticleService(Get.find<RealtimeDbService>()));
//     }
    
//     if (!Get.isRegistered<BookmarkService>()) {
//       Get.put<BookmarkService>(BookmarkService(dbService: Get.find<RealtimeDbService>()), permanent: true);
//     }
    
//     // Register controller
//     Get.lazyPut<ArticleDetailController>(() => ArticleDetailController(
//       articleService: Get.find<ArticleService>(),
//       bookmarkService: Get.find<BookmarkService>(),
//     ));
//   }
// }