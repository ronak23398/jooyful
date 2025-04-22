import 'package:flutter/material.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';

class WelcomeSection extends StatelessWidget {
  final AuthController authController;
  
  const WelcomeSection({
    Key? key,
    required this.authController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${authController.userModel.value?.name ?? "Friend"}!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMoodButton('😊', 'Good'),
              _buildMoodButton('😐', 'Okay'),
              _buildMoodButton('😔', 'Low'),
              _buildMoodButton('😰', 'Anxious'),
              _buildMoodButton('😡', 'Angry'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMoodButton(String emoji, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Text(
            emoji,
            style: TextStyle(fontSize: 24),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}