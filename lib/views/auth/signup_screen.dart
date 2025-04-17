import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class SignupScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Role Selection
              Text(
                'I am a:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Role selection chips
              Obx(() => Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Client'),
                    selected: authController.selectedRole.value == 'client',
                    onSelected: (selected) {
                      if (selected) authController.selectedRole.value = 'client';
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Counselor'),
                    selected: authController.selectedRole.value == 'counselor',
                    onSelected: (selected) {
                      if (selected) authController.selectedRole.value = 'counselor';
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Intern'),
                    selected: authController.selectedRole.value == 'intern',
                    onSelected: (selected) {
                      if (selected) authController.selectedRole.value = 'intern';
                    },
                  ),
                ],
              )),
              const SizedBox(height: 24),
              
              // Name field
              CustomTextField(
                controller: nameController,
                hintText: 'Full Name',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              
              // Email field
              CustomTextField(
                controller: emailController,
                hintText: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // Password field
              CustomTextField(
                controller: passwordController,
                hintText: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              
              // Confirm Password field
              CustomTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Additional fields for counselors
              Obx(() => authController.selectedRole.value == 'counselor'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Professional Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hintText: 'Specialization',
                          prefixIcon: Icons.psychology,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          hintText: 'License Number',
                          prefixIcon: Icons.card_membership,
                        ),
                        const SizedBox(height: 24),
                      ],
                    )
                  : const SizedBox.shrink()),
              
              // Sign Up Button
              Obx(() => CustomButton(
                text: 'Sign Up',
                isLoading: authController.isLoading.value,
                onPressed: () {
                  if (_validateFields()) {
                    authController.signup(
                      nameController.text,
                      emailController.text,
                      passwordController.text,
                    );
                  }
                },
              )),
              const SizedBox(height: 16),
              
              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateFields() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (!emailController.text.isEmail) {
      Get.snackbar(
        'Error',
        'Please enter a valid email',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }
}