class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'client', 'counselor', 'intern', 'owner'
  final String? assignedCounselorId; // For clients only
  final Map<String, dynamic>? profileData; // Additional profile data

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.assignedCounselorId,
    this.profileData,
  });

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'assignedCounselorId': assignedCounselorId,
      'profileData': profileData,
    };
  }

  // Create model from JSON
  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      assignedCounselorId: json['assignedCounselorId'] as String?,
      profileData: json['profileData'] != null 
          ? Map<String, dynamic>.from(json['profileData']) 
          : null,
    );
  }
}