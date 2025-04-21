import 'package:firebase_database/firebase_database.dart';
import 'realtime_db_service.dart';

class AppointmentService {
  final RealtimeDbService _dbService;
  
  AppointmentService(this._dbService);
  
  // Create appointment request
  Future<void> createAppointmentRequest(
    String clientId,
    String counselorId,
    String date,
    String time,
  ) async {
    try {
      String appointmentId =
          _dbService.dbRef.child('appointments').child(clientId).push().key ??
          DateTime.now().millisecondsSinceEpoch.toString();

      await _dbService.dbRef.child('appointments').child(clientId).child(appointmentId).set({
        'clientId': clientId,
        'counselorId': counselorId,
        'date': date,
        'time': time,
        'status': 'pending',
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      print("Error creating appointment request: $e");
      throw e;
    }
  }

  // Get appointments for client
  Future<List<Map<String, dynamic>>> getClientAppointments(
    String clientId,
  ) async {
    try {
      DataSnapshot snapshot =
          await _dbService.dbRef.child('appointments').child(clientId).get();

      List<Map<String, dynamic>> appointments = [];

      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Map<dynamic, dynamic> appointment = value as Map<dynamic, dynamic>;
          appointment['id'] = key;
          appointments.add(Map<String, dynamic>.from(appointment));
        });
      }

      return appointments;
    } catch (e) {
      print("Error getting client appointments: $e");
      throw e;
    }
  }

  // Get appointments for counselor (across all clients)
  Future<List<Map<String, dynamic>>> getCounselorAppointments(
    String counselorId,
  ) async {
    try {
      // Get all appointments
      DataSnapshot snapshot = await _dbService.dbRef.child('appointments').get();
      List<Map<String, dynamic>> appointments = [];

      if (snapshot.exists) {
        Map<dynamic, dynamic> clientAppointments =
            snapshot.value as Map<dynamic, dynamic>;

        // Loop through each client's appointments
        clientAppointments.forEach((clientId, clientAppts) {
          Map<dynamic, dynamic> appts = clientAppts as Map<dynamic, dynamic>;

          // Loop through each appointment for this client
          appts.forEach((appointmentId, appointmentData) {
            Map<dynamic, dynamic> appointment =
                appointmentData as Map<dynamic, dynamic>;

            // Check if this appointment is for the specified counselor
            if (appointment['counselorId'] == counselorId) {
              appointment['id'] = appointmentId;
              appointment['clientId'] = clientId;
              appointments.add(Map<String, dynamic>.from(appointment));
            }
          });
        });
      }

      return appointments;
    } catch (e) {
      print("Error getting counselor appointments: $e");
      throw e;
    }
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(
    String appointmentId,
    String clientId,
    String status,
  ) async {
    try {
      await _dbService.dbRef
          .child('appointments')
          .child(clientId)
          .child(appointmentId)
          .update({'status': status});
    } catch (e) {
      print("Error updating appointment status: $e");
      throw e;
    }
  }
}