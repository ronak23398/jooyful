class AppointmentModel {
  final String id;
  final String clientId;
  final String clientName;
  final String date;
  final String time;
  final String status; // pending, accepted, declined, completed

  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.date,
    required this.time,
    required this.status,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      clientName: json['clientName'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'date': date,
      'time': time,
      'status': status,
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? date,
    String? time,
    String? status,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
    );
  }
}