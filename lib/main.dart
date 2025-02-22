import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';
import 'screens/text_detector_view.dart';
import 'screens/text_recognition_app.dart';
import 'screens/text_recognizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await requestCameraPermission(); // Request camera permission
  runApp(const MyApp());
}

// Function to request camera permissions
Future<void> requestCameraPermission() async {
  var status = await Permission.camera.request();
  if (status.isDenied || status.isPermanentlyDenied) {
    // Handle denied permissions here
    print("Camera permission denied.");
  } else {
    print("Camera permission granted.");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _darkModeEnabled = false;

  void _toggleDarkMode(bool isEnabled) {
    setState(() {
      _darkModeEnabled = isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Agdour',
      theme: _darkModeEnabled ? ThemeData.dark() : ThemeData.light(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        //'/ocr': (context) => const OcrPage(),
        '/ocr': (context) => const TextRecognitionApp(),
        '/textRecognizer1': (context) => const TextRecognizerView(),
        '/textRecognizer': (context) => const TextRecognizerPage(),
        
        
        
      },
      initialRoute: '/login',
    );
  }
}
