import 'package:flutter/material.dart';

class AppointmentsSection extends StatelessWidget {
  final List<dynamic> appointments;
  
  const AppointmentsSection({
    super.key,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Appointments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: appointments.length > 2 ? 2 : appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            
            Color statusColor;
            IconData statusIcon;
            
            switch (appointment['status']) {
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
            
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.2),
                  child: Icon(statusIcon, color: statusColor),
                ),
                title: Text('Session with Counselor'),
                subtitle: Text(
                  '${appointment['date']} at ${appointment['time']}',
                ),
                trailing: Text(
                  appointment['status'].toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}