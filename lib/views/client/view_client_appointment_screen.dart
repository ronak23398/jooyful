import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import 'package:jooyful_heaven/controllers/client_controllers/client_controllers.dart';
import 'package:jooyful_heaven/services/appointment_service.dart';
import 'package:jooyful_heaven/services/realtime_db_service.dart';
import 'package:intl/intl.dart';

class ClientViewAppointmentScreen extends GetView<ClientController> {
  final AppointmentService _appointmentService = AppointmentService(RealtimeDbService());

  @override
  Widget build(BuildContext context) {
    // Fetch appointments when page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAppointments();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('My Appointments'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshAppointments,
          ),
        ],
      ),
      body: Obx(() => _buildAppointmentsList(context)),
    );
  }

  Widget _buildAppointmentsList(BuildContext context) {
    if (controller.isLoading.value) {
      return Center(child: CircularProgressIndicator());
    }

    if (controller.appointments.isEmpty) {
      return _buildEmptyState();
    }

    // Sort appointments by date (latest first)
    final sortedAppointments = List.from(controller.appointments)
      ..sort((a, b) {
        // Parse dates for comparison
        final dateA = _parseAppointmentDateTime(a['date'], a['time']);
        final dateB = _parseAppointmentDateTime(b['date'], b['time']);
        return dateB.compareTo(dateA); // Latest first
      });

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: sortedAppointments.length,
      itemBuilder: (context, index) {
        final appointment = sortedAppointments[index];
        return _buildAppointmentCard(context, appointment);
      },
    );
  }

  DateTime _parseAppointmentDateTime(String date, String time) {
    try {
      // Parse date (assuming format is YYYY-MM-DD)
      final dateParts = date.split('-');
      
      // Parse time (assuming format like "10:00 AM")
      final timeParts = time.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1].split(' ')[0]);
      final isPM = time.toLowerCase().contains('pm');
      
      // Adjust hour for PM
      if (isPM && hour < 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      
      return DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        hour,
        minute,
      );
    } catch (e) {
      // Return current date as fallback
      return DateTime.now();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No appointments scheduled',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your appointments will appear here when scheduled',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Schedule Appointment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Show appointment scheduling dialog
              _showScheduleAppointmentDialog(Get.context!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Map<String, dynamic> appointment) {
    final String status = appointment['status'] ?? 'unknown';
    final bool isPast = _isAppointmentInPast(appointment['date'], appointment['time']);
    
    // Determine colors and icons based on status
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.amber;
        statusIcon = Icons.hourglass_top;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }
    
    // Format date for display
    String formattedDate = _formatDate(appointment['date']);
    
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: statusColor.withOpacity(0.2),
              child: Icon(statusIcon, color: statusColor, size: 32),
            ),
            title: Text(
              'Counseling Session',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade700),
                    SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade700),
                    SizedBox(width: 8),
                    Text(
                      appointment['time'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if ((status == 'pending' || status == 'confirmed') && !isPast)
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    label: Text('Cancel Appointment'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () => _showCancelConfirmationDialog(context, appointment),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _isAppointmentInPast(String date, String time) {
    final appointmentDateTime = _parseAppointmentDateTime(date, time);
    return appointmentDateTime.isBefore(DateTime.now());
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    } catch (e) {
      return dateStr; // Return original if parsing fails
    }
  }

  void _showCancelConfirmationDialog(BuildContext context, Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to cancel this appointment?'),
              SizedBox(height: 16),
              Text(
                'Date: ${_formatDate(appointment['date'])}',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                'Time: ${appointment['time']}',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                'Cancellations should be made at least 24 hours in advance when possible.',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('No, Keep Appointment'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Yes, Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _cancelAppointment(appointment);
              },
            ),
          ],
        );
      },
    );
  }

  void _cancelAppointment(Map<String, dynamic> appointment) async {
    try {
      controller.isLoading.value = true;
      
      // Get user ID from AuthController - using Get.find to access it directly
      final authController = Get.find<AuthController>();
      final String? userId = authController.userModel.value?.uid;
      
      if (userId == null) {
        Get.snackbar('Error', 'User not found');
        return;
      }
      
      await _appointmentService.updateAppointmentStatus(
        appointment['id'],
        userId,
        'cancelled',
      );
      
      // Refresh appointments list
      _refreshAppointments();
      
      Get.snackbar(
        'Success',
        'Appointment cancelled successfully',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel appointment: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      controller.isLoading.value = false;
    }
  }

  void _refreshAppointments() async {
    try {
      controller.isLoading.value = true;
      
      // Get user ID from AuthController - using Get.find to access it directly
      final authController = Get.find<AuthController>();
      final String? userId = authController.userModel.value?.uid;
      
      if (userId != null) {
        // Use existing controller method
        await controller.loadAppointments(userId);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load appointments: ${e.toString()}');
    } finally {
      controller.isLoading.value = false;
    }
  }

 void _showScheduleAppointmentDialog(BuildContext context) {
  // Default to tomorrow's date
  final tomorrow = DateTime.now().add(Duration(days: 1));
  final initialDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
  
  DateTime selectedDate = initialDate;
  String selectedTime = '10:00 AM';
  
  final timeSlots = [
    '9:00 AM', '10:00 AM', '11:00 AM', '1:00 PM', 
    '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM'
  ];
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Schedule Appointment'),
            content: IntrinsicHeight( // Add this widget
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select date and time for your appointment:'),
                  SizedBox(height: 16),
                  
                  // Date selector
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  OutlinedButton(
                    child: Text('Change Date'),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 90)),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Time selector
                  Text(
                    'Select Time:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  SizedBox( // Use SizedBox instead of Container
                    height: 40,
                    width: 300, // Add a fixed width constraint
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: timeSlots.length,
                      itemBuilder: (context, index) {
                        final time = timeSlots[index];
                        final isSelected = time == selectedTime;
                        
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(time),
                            selected: isSelected,
                            selectedColor: Colors.blue,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  selectedTime = time;
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('Schedule'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _requestAppointment(
                    DateFormat('yyyy-MM-dd').format(selectedDate),
                    selectedTime,
                  );
                },
              ),
            ],
          );
        }
      );
    },
  );
}

  void _requestAppointment(String date, String time) async {
    try {
      await controller.requestAppointment(date, time);
      // The requestAppointment method already shows success message
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to schedule appointment: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
      );
    }
  }
}