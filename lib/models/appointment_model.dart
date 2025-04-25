// class AppointmentModel {
//   final String id;
//   final String clientId;
//   final String clientName;
//   final String date;
//   final String time;
//   final String status; // pending, accepted, declined, completed

//   AppointmentModel({
//     required this.id,
//     required this.clientId,
//     required this.clientName,
//     required this.date,
//     required this.time,
//     required this.status,
//   });

//   factory AppointmentModel.fromJson(Map<String, dynamic> json) {
//     return AppointmentModel(
//       id: json['id'] ?? '',
//       clientId: json['clientId'] ?? '',
//       clientName: json['clientName'] ?? '',
//       date: json['date'] ?? '',
//       time: json['time'] ?? '',
//       status: json['status'] ?? 'pending',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'clientId': clientId,
//       'clientName': clientName,
//       'date': date,
//       'time': time,
//       'status': status,
//     };
//   }

//   AppointmentModel copyWith({
//     String? id,
//     String? clientId,
//     String? clientName,
//     String? date,
//     String? time,
//     String? status,
//   }) {
//     return AppointmentModel(
//       id: id ?? this.id,
//       clientId: clientId ?? this.clientId,
//       clientName: clientName ?? this.clientName,
//       date: date ?? this.date,
//       time: time ?? this.time,
//       status: status ?? this.status,
//     );
//   }
// }

class AppointmentModel {
  final String id;
  final String clientId;
  final String clientName;
  final String counselorId;
  final String date;
  final String time;
  final String status;
  final int timestamp;

  AppointmentModel({
    required this.id,
    required this.clientId,
    this.clientName = 'Unknown Client',
    required this.counselorId,
    required this.date,
    required this.time,
    required this.status,
    required this.timestamp,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      clientName: json['clientName'] ?? 'Unknown Client',
      counselorId: json['counselorId'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? 'pending',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'counselorId': counselorId,
      'date': date,
      'time': time,
      'status': status,
      'timestamp': timestamp,
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? counselorId,
    String? date,
    String? time,
    String? status,
    int? timestamp,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      counselorId: counselorId ?? this.counselorId,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}