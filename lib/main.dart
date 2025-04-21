import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import 'routes/app_routes.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with your configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inject Auth Controller as a permanent dependency
  Get.put(AuthController(), permanent: true);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mental Health App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: AppRoutes.LOGIN,
      getPages: appPages,
      debugShowCheckedModeBanner: false,
      // Enable GetX error reporting in debug mode
      enableLog: true,
      // Initialize GetX logging system
      logWriterCallback: (String text, {bool isError = false}) {
        if (isError) {
          debugPrint("GetX ERROR: $text");
        } else {
          debugPrint("GetX LOG: $text");
        }
      },
      // Default transitions for routes
      defaultTransition: Transition.fade,
      // Error handling for routes
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => Scaffold(
          body: Center(
            child: Text("Route not found"),
          ),
        ),
      ),
    );
  }
}