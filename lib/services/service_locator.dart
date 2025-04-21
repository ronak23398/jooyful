import 'package:jooyful_heaven/services/counsellor_req_service.dart';

import 'realtime_db_service.dart';
import 'user_service.dart';
import 'article_service.dart';
import 'chat_service.dart';
import 'test_service.dart';
import 'appointment_service.dart';

class ServiceLocator {
  // Singleton pattern
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Services
  late final RealtimeDbService _dbService;
  late final UserService _userService;
  late final ArticleService _articleService;
  late final ChatService _chatService;
  late final TestService _testService;
  late final AppointmentService _appointmentService;
  late final CounselorRequestService _counselorRequestService;

  // Initialize all services
  void initialize() {
    _dbService = RealtimeDbService();
    _userService = UserService(_dbService);
    _articleService = ArticleService(_dbService);
    _chatService = ChatService(_dbService);
    _testService = TestService(_dbService);
    _appointmentService = AppointmentService(_dbService);
    _counselorRequestService = CounselorRequestService(_dbService);
  }

  // Getters for each service
  RealtimeDbService get dbService => _dbService;
  UserService get userService => _userService;
  ArticleService get articleService => _articleService;
  ChatService get chatService => _chatService;
  TestService get testService => _testService;
  AppointmentService get appointmentService => _appointmentService;
  CounselorRequestService get counselorRequestService => _counselorRequestService;
}

// Create a global instance for easy access
final serviceLocator = ServiceLocator();