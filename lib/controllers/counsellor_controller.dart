import 'package:get/get.dart';
import 'package:jooyful_heaven/services/realtime_db_service.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';
import '../models/chat_model.dart';
import '../services/firebase_auth_service.dart';

class CounselorController extends GetxController {
  final FirebaseAuthService authService;
  final RealtimeDbService dbService;

  CounselorController({
    required this.authService,
    required this.dbService,
  });

  final RxList<UserModel> assignedClients = <UserModel>[].obs;
  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<UserModel?> selectedClient = Rx<UserModel?>(null);
  final RxList<ChatModel> currentChat = <ChatModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAssignedClients();
    fetchAppointments();
  }

 Future<void> fetchAssignedClients() async {
  try {
    isLoading.value = true;
    
    // Get current counselor ID
    final counselorId = authService.currentUser?.uid;
    if (counselorId == null) return;
    
    // Query users where assignedCounselorId equals current counselor ID
    final clients = await dbService.getWhere('users', 'assignedCounselorId', counselorId);
    
    // Convert to UserModel objects
    assignedClients.value = clients.map((clientData) {
      Map<String, dynamic> data = clientData as Map<String, dynamic>;
      return UserModel.fromMap(data);
    }).toList();
    
  } catch (e) {
    Get.snackbar('Error', 'Failed to load clients: ${e.toString()}');
  } finally {
    isLoading.value = false;
  }
}

  Future<void> fetchAppointments() async {
    try {
      isLoading.value = true;
      final counselorId = authService.currentUser?.uid;
      if (counselorId == null) return;
      
      // Get all appointments for this counselor
      final appointmentsData = await dbService.get('appointments/$counselorId');
      
      if (appointmentsData != null && appointmentsData is Map) {
        List<AppointmentModel> appointmentsList = [];
        
        appointmentsData.forEach((appointmentId, data) {
          final appointment = AppointmentModel.fromJson({
            'id': appointmentId,
            ...data as Map<String, dynamic>,
          });
          appointmentsList.add(appointment);
        });
        
        appointments.value = appointmentsList;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load appointments: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void selectClient(UserModel client) {
    selectedClient.value = client;
    loadClientChat(client.uid);
  }

  Future<void> loadClientChat(String clientId) async {
    try {
      final counselorId = authService.currentUser?.uid;
      if (counselorId == null) return;
      
      final chatId = '${clientId}_$counselorId';
      final chatData = await dbService.get('chats/$chatId');
      
      if (chatData != null && chatData is Map) {
        List<ChatModel> chatMessages = [];
        
        chatData.forEach((messageId, data) {
  Map<String, dynamic> messageData = data as Map<String, dynamic>;
  final message = ChatModel.fromMap(
    {
      ...messageData,
      'id': messageId,
    },
    messageId  // Pass messageId as the second parameter
  );
  chatMessages.add(message);
});
        
        // Sort messages by timestamp
        chatMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        currentChat.value = chatMessages;
      } else {
        currentChat.value = [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load chat: ${e.toString()}');
    }
  }

  Future<void> sendMessage(String text) async {
    try {
      if (selectedClient.value == null) return;
      
      final counselorId = authService.currentUser?.uid;
      if (counselorId == null) return;
      
      final clientId = selectedClient.value!.uid;
      final chatId = '${clientId}_$counselorId';
      
      final newMessage = ChatModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: counselorId,
        text: text,
        timestamp: DateTime.now(), receiverId: clientId,
      );
      
      await dbService.set('chats/$chatId/${newMessage.id}', newMessage.toMap());
      
      // Add to local list
      currentChat.add(newMessage);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: ${e.toString()}');
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      final counselorId = authService.currentUser?.uid;
      if (counselorId == null) return;
      
      await dbService.update('appointments/$counselorId/$appointmentId', {'status': status});
      
      // Update local list
      final index = appointments.indexWhere((appointment) => appointment.id == appointmentId);
      if (index != -1) {
        final updated = appointments[index].copyWith(status: status);
        appointments[index] = updated;
      }
      
      Get.snackbar('Success', 'Appointment status updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update appointment: ${e.toString()}');
    }
  }
}