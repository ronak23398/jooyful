import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import 'package:jooyful_heaven/controllers/client_controllers/client_controllers.dart';
import 'package:jooyful_heaven/views/client/components/appointment_section.dart';
import 'package:jooyful_heaven/views/client/components/article_section.dart';
import 'package:jooyful_heaven/views/client/components/clients_drawr.dart';
import 'package:jooyful_heaven/views/client/components/test_result_section.dart';
import 'package:jooyful_heaven/views/client/components/test_scetion.dart';
import 'components/welcome_section.dart';
import 'components/counselor_section.dart';

class ClientHomeScreen extends GetView<ClientController> {
  final AuthController authController = Get.find<AuthController>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joooyful Heaven'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      drawer: ClientDrawer(authController: authController),
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
                  WelcomeSection(authController: authController),
                  
                  SizedBox(height: 20),
                  
                  // Counselor section
                  CounselorSection(
                    controller: controller,
                    counselor: controller.counselor.value,
                    assignedCounselorId: controller.assignedCounselorId.value,
                    hasCounselorRequest: controller.hasCounselorRequest.value,
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Psychological Tests section
                  TestsSection(tests: controller.tests),
                  
                  SizedBox(height: 20),
                  
                  // Articles section
                  ArticlesSection(articles: controller.articles),
                  
                  // If we have test results, show them
                  if (controller.testResults.isNotEmpty) ...[
                    SizedBox(height: 20),
                    TestResultsSection(testResults: controller.testResults),
                  ],
                  
                  // If we have appointments, show them
                  if (controller.appointments.isNotEmpty) ...[
                    SizedBox(height: 20),
                    AppointmentsSection(appointments: controller.appointments),
                  ],
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
      ),
    );
  }
}