import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import 'package:jooyful_heaven/models/user_model.dart';
import 'package:jooyful_heaven/routes/app_routes.dart';
import 'package:jooyful_heaven/controllers/client_controllers/client_controllers.dart';
import 'package:jooyful_heaven/services/counsellor_req_service.dart';
import 'package:jooyful_heaven/services/realtime_db_service.dart';

class CounselorSection extends StatefulWidget {
  
  final ClientController controller;
  final UserModel? counselor; 
  final String assignedCounselorId;
  final bool hasCounselorRequest;
  
  const CounselorSection({
    super.key,
    required this.controller,
    this.counselor,
    required this.assignedCounselorId,
    required this.hasCounselorRequest,
  });

  @override
  State<CounselorSection> createState() => _CounselorSectionState();
}

class _CounselorSectionState extends State<CounselorSection> {
  final RealtimeDbService _dbService = RealtimeDbService();
  
  final AuthController _authController = Get.find<AuthController>();
  bool _isRequestingAppointment = false;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_alt, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Your Counselor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (widget.assignedCounselorId.isNotEmpty && widget.counselor != null)
              // Counselor is assigned
              Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, color: Colors.blue),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.counselor!.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text('Professional Counselor'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.chat),
                          label: Text('Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Get.toNamed(
                            AppRoutes.CHAT_SCREEN,
                            arguments: {'counselorId': widget.assignedCounselorId}
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildAppointmentButton(),
                      ),
                    ],
                  ),
                ],
              )
            else if (widget.hasCounselorRequest)
              // Request is pending
              Center(
                child: Column(
                  children: [
                    Icon(Icons.hourglass_top, size: 40, color: Colors.amber),
                    SizedBox(height: 8),
                    Text(
                      'Counselor request is pending',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.amber.shade800,
                      ),
                    ),
                    Text(
                      'We will assign you a counselor soon',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              // No counselor yet
              Center(
                child: Column(
                  children: [
                    Icon(Icons.person_add, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No counselor assigned yet',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => widget.controller.requestCounselor(),
                      child: Text('Request a Counselor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppointmentButton() {
    // Get the client ID from the auth controller
    String? clientId = _authController.userModel.value?.uid;
    
    // Check if there's an upcoming confirmed appointment
    Map<String, dynamic>? confirmedAppointment = widget.controller.appointments
        .firstWhereOrNull((appointment) => 
            appointment['status'] == 'confirmed' && 
            _isUpcomingAppointment(appointment['date']));
    
    if (confirmedAppointment != null) {
      // Show confirmed appointment details
      return ElevatedButton.icon(
        icon: Icon(Icons.event_available),
        label: Text('${confirmedAppointment['date']} at ${confirmedAppointment['time']}'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        onPressed: null, // Disabled since it's already confirmed
      );
    }
    
    // Check if there's a pending appointment
    bool hasPendingAppointment = widget.controller.appointments
        .any((appointment) => appointment['status'] == 'pending');
    
    if (hasPendingAppointment || _isRequestingAppointment) {
      return ElevatedButton.icon(
        icon: Icon(Icons.hourglass_bottom),
        label: Text('Request Pending'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.white,
        ),
        onPressed: null, // Disabled since it's pending
      );
    }
    
    // Default: Request Appointment button
    return ElevatedButton.icon(
      icon: Icon(Icons.calendar_today),
      label: Text('Appointment'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      onPressed: clientId == null ? null : () async {
        setState(() {
          _isRequestingAppointment = true;
        });
        
        try {
          await CounselorRequestService(_dbService).createCounselorRequest(clientId);
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Appointment request sent successfully!'))
          );
        } catch (e) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to request appointment: $e'))
          );
          setState(() {
            _isRequestingAppointment = false;
          });
        }
      },
    );
  }
  
  bool _isUpcomingAppointment(String dateString) {
    try {
      final appointmentDate = DateTime.parse(dateString);
      final now = DateTime.now();
      return appointmentDate.isAfter(now);
    } catch (e) {
      return false;
    }
  }
}