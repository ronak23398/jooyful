import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/counsellor/counsellor_controller.dart';
import 'package:jooyful_heaven/models/appointment_model.dart';
import 'package:intl/intl.dart';

class ViewAppointmentsScreen extends StatefulWidget {
  @override
  State<ViewAppointmentsScreen> createState() => _ViewAppointmentsScreenState();
}

class _ViewAppointmentsScreenState extends State<ViewAppointmentsScreen> {
  final CounselorController controller = Get.find<CounselorController>();

  @override
  void initState() {
    super.initState();
    // Refresh appointments when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchAppointments(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No appointments scheduled',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        // Sort appointments by date - most recent first
        final sortedAppointments = List<AppointmentModel>.from(controller.appointments)
          ..sort((a, b) {
            // Parse dates
            final dateA = _parseDate(a.date);
            final dateB = _parseDate(b.date);
            return dateB.compareTo(dateA);
          });

        // Create tabs for different appointment status
        final pendingAppointments = sortedAppointments
            .where((appointment) => appointment.status == 'pending')
            .toList();
            
        final acceptedAppointments = sortedAppointments
            .where((appointment) => appointment.status == 'accepted')
            .toList();
            
        final pastAppointments = sortedAppointments
            .where((appointment) => 
                appointment.status == 'completed' || 
                appointment.status == 'cancelled' ||
                appointment.status == 'declined')
            .toList();

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                labelColor: Theme.of(context).primaryColor,
                indicatorColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Pending (${pendingAppointments.length})'),
                  Tab(text: 'Upcoming (${acceptedAppointments.length})'),
                  Tab(text: 'Past (${pastAppointments.length})'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildAppointmentsList(pendingAppointments, true),
                    _buildAppointmentsList(acceptedAppointments, false),
                    _buildAppointmentsList(pastAppointments, false),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      return DateTime(
        int.parse(parts[0]), // year
        int.parse(parts[1]), // month
        int.parse(parts[2]), // day
      );
    } catch (e) {
      return DateTime.now();
    }
  }

  Widget _buildAppointmentsList(List<AppointmentModel> appointments, bool showActions) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No appointments in this category',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchAppointments();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment, showActions);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment, bool showActions) {
    Color statusColor;
    IconData statusIcon;
    
    switch (appointment.status) {
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'declined':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'completed':
        statusColor = Colors.purple;
        statusIcon = Icons.task_alt;
        break;
      case 'cancelled':
        statusColor = Colors.red.shade300;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    // Format date for display
    String formattedDate = _formatDate(appointment.date);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: statusColor.withOpacity(0.2),
              child: Icon(statusIcon, color: statusColor, size: 32),
            ),
            title: Text(
              appointment.clientName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      appointment.time,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    appointment.status.toUpperCase(),
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
          if (showActions)
  Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.close, color: Colors.red),
          label: const Text('Decline'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          onPressed: () {
            _showConfirmationDialog(
              context, 
              'Decline Appointment', 
              'Are you sure you want to decline this appointment?',
              () => controller.updateAppointmentStatus(appointment.id, 'declined'),
            );
          },
        ),
        const SizedBox(width: 16),
        // Wrap the ElevatedButton.icon in a SizedBox or Container with a defined width
        SizedBox(
          width: 120, // Adjust this width as needed
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Accept'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              _showConfirmationDialog(
                context, 
                'Accept Appointment', 
                'Are you sure you want to accept this appointment?',
                () => controller.updateAppointmentStatus(appointment.id, 'accepted'),
              );
            },
          ),
        ),
      ],
    ),
  ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    } catch (e) {
      return dateStr; // Return original if parsing fails
    }
  }

  void _showConfirmationDialog(
  BuildContext context,
  String title,
  String message,
  Function() onConfirm,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Container(
            width: 100, // Set a fixed width or use another constraint approach
            child: ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ),
        ],
      );
    },
  );
}
}