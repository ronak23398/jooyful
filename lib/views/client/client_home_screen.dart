import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import 'package:jooyful_heaven/controllers/client_controllers.dart';
import '../../routes/app_routes.dart';

class ClientHomeScreen extends GetView<ClientController> {
  final AuthController authController = Get.find<AuthController>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joooyful Heaven'),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.notifications),
          //   onPressed: () => Get.toNamed(AppRoutes.NOTIFICATIONS),
          // ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Obx(() => controller.isLoading.value 
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => controller.loadClientData(),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  _buildWelcomeSection(),
                  
                  SizedBox(height: 20),
                  
                  // Counselor section
                  _buildCounselorSection(),
                  
                  SizedBox(height: 20),
                  
                  // Psychological Tests section
                  _buildTestsSection(),
                  
                  SizedBox(height: 20),
                  
                  // Articles section
                  _buildArticlesSection(),
                  
                  // If we have test results, show them
                  if (controller.testResults.isNotEmpty) ...[
                    SizedBox(height: 20),
                    _buildTestResultsSection(),
                  ],
                  
                  // If we have appointments, show them
                  if (controller.appointments.isNotEmpty) ...[
                    SizedBox(height: 20),
                    _buildAppointmentsSection(),
                  ],
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
      ),
    );
  }
  
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                SizedBox(height: 10),
                Text(
                  authController.userModel.value?.name ?? 'Client',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                  authController.userModel.value?.email ?? '',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // ListTile(
          //   leading: Icon(Icons.psychology),
          //   title: Text('Psychological Tests'),
          //   onTap: () => Get.toNamed(AppRoutes.TEST_SCREEN),
          // ),
          // ListTile(
          //   leading: Icon(Icons.article),
          //   title: Text('Articles'),
          //   onTap: () => Get.toNamed(AppRoutes.ARTICLES_SCREEN),
          // ),
          // ListTile(
          //   leading: Icon(Icons.chat),
          //   title: Text('Chat with Counselor'),
          //   onTap: () => Get.toNamed(AppRoutes.CHAT_SCREEN),
          // ),
          // ListTile(
          //   leading: Icon(Icons.calendar_today),
          //   title: Text('Request Appointment'),
          //   onTap: () => Get.toNamed(AppRoutes.REQUEST_APPOINTMENT_SCREEN),
          // ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => authController.logout(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWelcomeSection() {
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
  
  Widget _buildCounselorSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_alt, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Your Counselor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (controller.assignedCounselorId.value.isNotEmpty && controller.counselor.value != null)
              // Counselor is assigned
              Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, color: Colors.blue),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.counselor.value!.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text('Professional Counselor'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      // Expanded(
                      //   child: ElevatedButton.icon(
                      //     icon: Icon(Icons.chat),
                      //     label: Text('Chat'),
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.blue,
                      //       foregroundColor: Colors.white,
                      //     ),
                      //     onPressed: () => Get.toNamed(AppRoutes.CHAT_SCREEN),
                      //   ),
                      // ),
                      // SizedBox(width: 8),
                      // Expanded(
                      //   child: ElevatedButton.icon(
                      //     icon: Icon(Icons.calendar_today),
                      //     label: Text('Appointment'),
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.green,
                      //       foregroundColor: Colors.white,
                      //     ),
                      //     onPressed: () => Get.toNamed(AppRoutes.REQUEST_APPOINTMENT_SCREEN),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              )
            else if (controller.hasCounselorRequest.value)
              // Request is pending
              Center(
                child: Column(
                  children: [
                    Icon(Icons.hourglass_top, size: 40, color: Colors.amber),
                    SizedBox(height: 8),
                    Text(
                      'Counselor request is pending',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.amber.shade800,
                      ),
                    ),
                    Text(
                      'We will assign you a counselor soon',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              // No counselor yet
              Center(
                child: Column(
                  children: [
                    Icon(Icons.person_add, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No counselor assigned yet',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.requestCounselor(),
                      child: Text('Request a Counselor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Psychological Tests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // TextButton(
            //   onPressed: () => Get.toNamed(AppRoutes.TEST_SCREEN),
            //   child: Text('See All'),
            // ),
          ],
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: controller.tests.isEmpty
            ? Center(child: Text('No tests available'))
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.tests.length,
                itemBuilder: (context, index) {
                  final test = controller.tests[index];
                  return Container(
                    width: 200,
                    margin: EdgeInsets.only(right: 12),
                    child: Card(
                      color: Colors.purple.shade50,
                      child: InkWell(
                        onTap: () => Get.toNamed(
                          AppRoutes.TEST_SCREEN, 
                          arguments: {'testId': test['id']}
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.psychology, color: Colors.purple),
                              SizedBox(height: 8),
                              Text(
                                test['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  test['description'],
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${test['questions']} questions',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
  
  Widget _buildArticlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mental Health Articles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // TextButton(
            //   onPressed: () => Get.toNamed(AppRoutes.ARTICLES_SCREEN),
            //   child: Text('See All'),
            // ),
          ],
        ),
        SizedBox(height: 8),
        controller.articles.isEmpty
          ? Center(child: Text('No articles available'))
          : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.articles.length > 3 ? 3 : controller.articles.length,
              itemBuilder: (context, index) {
                final article = controller.articles[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Icon(Icons.article, color: Colors.green),
                    ),
                    title: Text(article['title']),
                    subtitle: Text(
                      article['category'],
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    // onTap: () => Get.toNamed(
                    //   AppRoutes.ARTICLES_SCREEN,
                    //   arguments: {'articleId': article['id']}
                    // ),
                  ),
                );
              },
            ),
      ],
    );
  }
  
  Widget _buildTestResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Recent Tests',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.testResults.length > 2 ? 2 : controller.testResults.length,
          itemBuilder: (context, index) {
            final result = controller.testResults[index];
            final score = result['score'];
            final maxScore = result['maxScore'];
            final percentage = (score / maxScore) * 100;
            
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          result['testName'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          result['date'],
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: score / maxScore,
                              minHeight: 10,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                percentage < 30 ? Colors.green : 
                                percentage < 60 ? Colors.amber : Colors.red,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '$score/$maxScore',
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    if (result['counselorComment'] != null) ...[
                      SizedBox(height: 12),
                      Divider(),
                      SizedBox(height: 4),
                      Text(
                        'Counselor Comment:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        result['counselorComment'],
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildAppointmentsSection() {
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
          itemCount: controller.appointments.length > 2 ? 2 : controller.appointments.length,
          itemBuilder: (context, index) {
            final appointment = controller.appointments[index];
            
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