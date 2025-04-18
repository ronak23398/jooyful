import 'package:get/get.dart';
import 'package:jooyful_heaven/bindings/auth_binding.dart';
import 'package:jooyful_heaven/bindings/client_binding.dart';
import 'package:jooyful_heaven/bindings/owner_binding.dart';
import 'package:jooyful_heaven/controllers/owner_controller.dart';
import 'package:jooyful_heaven/views/client/client_home_screen.dart';
import 'package:jooyful_heaven/views/owner/all_clients_screen.dart';
import 'package:jooyful_heaven/views/owner/all_counsellors_screen.dart';
import 'package:jooyful_heaven/views/owner/all_interns_screen.dart';
import 'package:jooyful_heaven/views/owner/assign_counsellor_screen.dart';
import 'package:jooyful_heaven/views/owner/owner_home_screen.dart';
import 'package:jooyful_heaven/views/owner/upload_article_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/signup_screen.dart';

// Define route names
class AppRoutes {
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';
  static const OWNER_HOME = '/owner_home';
  static const CLIENT_HOME = '/client_home';
  static const COUNSELOR_HOME = '/counselor_home';
  static const INTERN_HOME = '/intern_home';

  // Add more routes as needed
  static const ALL_CLIENTS = '/all_clients';
  static const ALL_COUNSELORS = '/all_counselors';
  static const ALL_INTERNS = '/all_interns';
  static const ASSIGN_COUNSELOR = '/assign_counselor';
  static const UPLOAD_ARTICLE = '/upload_article';
  static const TEST_SCREEN = '/TEST_SCREEN';
  // ... add all the routes from your plan
}

// Define pages with bindings
final appPages = [
  GetPage(
    name: AppRoutes.LOGIN,
    page: () => LoginScreen(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: AppRoutes.SIGNUP,
    page: () => SignupScreen(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: AppRoutes.OWNER_HOME,
    page: () => OwnerHomeScreen(),
    binding: OwnerBinding(),
  ),
  GetPage(
    name: AppRoutes.CLIENT_HOME,
    page: () => ClientHomeScreen(),
    binding: ClientBinding(),
  ),
   GetPage(
      name: AppRoutes.ASSIGN_COUNSELOR, 
      page: () => AssignCounselorScreen(),
      binding: BindingsBuilder(() {
        // Make sure OwnerController is available
        Get.lazyPut<OwnerController>(() => OwnerController());
      }),
    ),
    GetPage(
      name: AppRoutes.ALL_CLIENTS, 
      page: () => AllClientsScreen(),
      binding: BindingsBuilder(() {
        // Make sure OwnerController is available
        Get.lazyPut<OwnerController>(() => OwnerController());
      }),
    ),
    GetPage(
      name: AppRoutes.ALL_COUNSELORS, 
      page: () => AllCounselorsScreen(),
      binding: BindingsBuilder(() {
        // Make sure OwnerController is available
        Get.lazyPut<OwnerController>(() => OwnerController());
      }),
    ),
    GetPage(
      name: AppRoutes.ALL_INTERNS, 
      page: () => AllInternsScreen(),
      binding: BindingsBuilder(() {
        // Make sure OwnerController is available
        Get.lazyPut<OwnerController>(() => OwnerController());
      }),
    ),
    GetPage(
      name: AppRoutes.UPLOAD_ARTICLE, 
      page: () => UploadArticleScreen(),
      binding: BindingsBuilder(() {
        // Make sure OwnerController is available
        Get.lazyPut<OwnerController>(() => OwnerController());
      }),
    ),
  // GetPage(
  //   name: AppRoutes.COUNSELOR_HOME,
  //   page: () => CounselorHomeScreen(),
  //   binding: CounselorBinding(),
  // ),
  // GetPage(
  //   name: AppRoutes.INTERN_HOME,
  //   page: () => InternHomeScreen(),
  //   binding: InternBinding(),
  // ),
  // Add more pages here
];