class AppointmentModel {
  final String id;
  final String clientId;
  final String counselorId;
  final DateTime date;
  final String time;
  final String status; // pending, confirmed, cancelled
  final String? notes;
  
  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.counselorId,
    required this.date,
    required this.time,
    required this.status,
    this.notes,
  });
  
  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      id: id,
      clientId: map['clientId'] ?? '',
      counselorId: map['counselorId'] ?? '',
      date: map['date'] != null 
        ? DateTime.parse(map['date'])
        : DateTime.now(),
      time: map['time'] ?? '',
      status: map['status'] ?? 'pending',
      notes: map['notes'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'counselorId': counselorId,
      'date': date.toString().substring(0, 10), // YYYY-MM-DD
      'time': time,
      'status': status,
      'notes': notes,
    };
  }
}