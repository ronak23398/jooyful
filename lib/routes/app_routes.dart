import 'package:get/get.dart';
import 'package:jooyful_heaven/bindings/auth_binding.dart';
import 'package:jooyful_heaven/bindings/client_binding.dart';
import 'package:jooyful_heaven/bindings/counsellor_binding.dart';
import 'package:jooyful_heaven/bindings/intern_binding.dart';
import 'package:jooyful_heaven/bindings/owner_binding.dart';
import 'package:jooyful_heaven/controllers/article_controller.dart';
import 'package:jooyful_heaven/controllers/client_controllers/client_chat_controller.dart';
import 'package:jooyful_heaven/controllers/counsellor/counsellor_chat_controller.dart';
import 'package:jooyful_heaven/controllers/counsellor/counsellor_controller.dart';
import 'package:jooyful_heaven/controllers/owner_controller.dart';
import 'package:jooyful_heaven/services/firebase_auth_service.dart';
import 'package:jooyful_heaven/services/realtime_db_service.dart';
import 'package:jooyful_heaven/views/client/client_chat_screen.dart';
import 'package:jooyful_heaven/views/client/client_home_screen.dart';
import 'package:jooyful_heaven/views/counsellor/counsellor_appointment_screen.dart';
import 'package:jooyful_heaven/views/counsellor/counsellor_chat_screen.dart';
import 'package:jooyful_heaven/views/counsellor/counsellor_home_screen.dart';
import 'package:jooyful_heaven/views/counsellor/list_of_clients_screen.dart';
import 'package:jooyful_heaven/views/intern/intern_home_screen.dart';
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
   static const String CHAT_SCREEN = '/chat_screen';
  static const COUNSELOR_HOME = '/counselor_home';
  static const INTERN_HOME = '/intern_home';

  // Add more routes as needed
  static const ALL_CLIENTS = '/all_clients';
  static const ALL_COUNSELORS = '/all_counselors';
  static const ALL_INTERNS = '/all_interns';
  static const ASSIGN_COUNSELOR = '/assign_counselor';
  static const UPLOAD_ARTICLE = '/upload_article';
  static const TEST_SCREEN = '/TEST_SCREEN';
  
  // New routes from CounselorHomeScreen
  static const LIST_OF_CLIENTS = '/listofClients';
  static const COUNSELOR_VIEW_APPOINTMENTS = '/counselor/appointments';
  static const UPCOMING_APPOINTMENTS = '/upcoming_appointments';
  static const COUNSELLOR_CHAT = '/counselor/chat';
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
        Get.lazyPut<ArticleController>(() => ArticleController());
      }),
    ),
  GetPage(
    name: AppRoutes.COUNSELOR_HOME,
    page: () => CounselorHomeScreen(),
    binding: CounselorBinding(),
  ),
   GetPage(
  name: AppRoutes.LIST_OF_CLIENTS,
  page: () => MyClientsScreen(), // You'll need to create this screen
  binding: BindingsBuilder(() {
    Get.lazyPut<CounselorController>(() => CounselorController(
      authService: Get.find<FirebaseAuthService>(),
      dbService: Get.find<RealtimeDbService>(),
    ));
  }),
),
GetPage(
  name: AppRoutes.COUNSELOR_VIEW_APPOINTMENTS,
  page: () => ViewAppointmentsScreen(), // You'll need to create this screen
  binding: BindingsBuilder(() {
    Get.lazyPut<CounselorController>(() => CounselorController(
      authService: Get.find<FirebaseAuthService>(),
      dbService: Get.find<RealtimeDbService>(),
    ));
  }),
),
GetPage(
  name: AppRoutes.UPCOMING_APPOINTMENTS,
  page: () => ViewAppointmentsScreen(), // You'll need to create this screen
  binding: BindingsBuilder(() {
    Get.lazyPut<CounselorController>(() => CounselorController(
      authService: Get.find<FirebaseAuthService>(),
      dbService: Get.find<RealtimeDbService>(),
    ));
  }),
),
GetPage(
  name: AppRoutes.COUNSELLOR_CHAT,
  page: () => CounselorChatScreen(),
  binding: BindingsBuilder(() {
    // Use put() instead of lazyPut() to ensure immediate initialization
    Get.put(CounselorChatController());
  }),
),
GetPage(
      name: AppRoutes.CHAT_SCREEN,
      page: () => ClientChatScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ClientChatController>(() => ClientChatController());
      }),
    ),
  GetPage(
    name: AppRoutes.INTERN_HOME,
    page: () => InternHomePage(),
    binding: InternBindings(),
  ),
  // Add more pages here
];