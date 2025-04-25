import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MoodCalendarDialog extends StatefulWidget {
  final RxMap<String, Map<String, dynamic>> weeklyMoods;
  
  const MoodCalendarDialog({
    super.key,
    required this.weeklyMoods,
  });

  @override
  _MoodCalendarDialogState createState() => _MoodCalendarDialogState();
}

class _MoodCalendarDialogState extends State<MoodCalendarDialog> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.week; // Show weekly view by default
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Your Mood History'),
      content: Container(
        width: double.maxFinite,
        child: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TableCalendar(
              firstDay: DateTime.now().subtract(Duration(days: 30)),
              lastDay: DateTime.now(),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  // Format date to match our storage format (YYYY-MM-DD)
                  final dateString = date.toString().substring(0, 10);
                  final moodData = widget.weeklyMoods[dateString];
                  
                  if (moodData != null) {
                    return Container(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        moodData['emoji'] as String,
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 16),
            _buildSelectedDayMood(),
          ],
        )),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSelectedDayMood() {
    // Format selected day to match our storage format (YYYY-MM-DD)
    final dateString = _selectedDay.toString().substring(0, 10);
    final moodData = widget.weeklyMoods[dateString];
    
    if (moodData != null) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              moodData['emoji'] as String,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d').format(_selectedDay),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('You felt: ${moodData['mood']}'),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.mood_bad, color: Colors.grey),
            SizedBox(width: 12),
            Text('No mood recorded for this day'),
          ],
        ),
      );
    }
  }
}