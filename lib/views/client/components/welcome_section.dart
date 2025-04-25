import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import 'package:jooyful_heaven/controllers/client_controllers/client_controllers.dart';
import 'package:jooyful_heaven/views/client/components/mood_calender_dialog.dart';

class WelcomeSection extends StatelessWidget {
  final AuthController authController;
  final ClientController clientController = Get.find<ClientController>();
  
  WelcomeSection({
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Welcome, ${authController.userModel.value?.name ?? "Friend"}!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: Icon(Icons.calendar_month, color: Colors.white),
                onPressed: () => _showMoodCalendar(context),
                tooltip: 'View Mood History',
              ),
            ],
          ),
          SizedBox(height: 8),
          
          // Show different content based on whether mood has been recorded today
          Obx(() {
            if (clientController.hasMoodRecordedToday.value) {
              // Show today's recorded mood
              return _buildTodaysMoodDisplay();
            } else {
              // Show mood selection UI
              return _buildMoodSelectionUI(context);
            }
          }),
        ],
      ),
    );
  }
  
  Widget _buildMoodSelectionUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            _buildMoodButton(context, '😊', 'Good'),
            _buildMoodButton(context, '😐', 'Okay'),
            _buildMoodButton(context, '😔', 'Low'),
            _buildMoodButton(context, '😰', 'Anxious'),
            _buildMoodButton(context, '😡', 'Angry'),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTodaysMoodDisplay() {
    final moodData = clientController.todaysMood.value;
    
    if (moodData != null) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today you\'re feeling:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        moodData['emoji'] as String,
                        style: TextStyle(fontSize: 32),
                      ),
                      SizedBox(width: 12),
                      Text(
                        moodData['mood'] as String,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    // Reset to allow recording new mood
                    clientController.hasMoodRecordedToday.value = false;
                    clientController.todaysMood.value = null;
                  },
                  child: Text(
                    'Change',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.shade800.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Fallback in case something went wrong
      return _buildMoodSelectionUI(Get.context!);
    }
  }
  
  Widget _buildMoodButton(BuildContext context, String emoji, String label) {
    return GestureDetector(
      onTap: () {
        clientController.saveMood(label, emoji);
      },
      child: Column(
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
      ),
    );
  }
  
  void _showMoodCalendar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MoodCalendarDialog(weeklyMoods: clientController.weeklyMoods),
    );
  }
}