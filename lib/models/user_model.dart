class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? assignedCounselorId;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.assignedCounselorId,
    this.photoUrl,
    this.phoneNumber,
    required this.createdAt,
  });
  
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'client',
      assignedCounselorId: map['assignedCounselorId'],
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      createdAt: map['createdAt'] != null
         ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
         : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,  // Now including uid in the map
      'name': name,
      'email': email,
      'role': role,
      'assignedCounselorId': assignedCounselorId,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}