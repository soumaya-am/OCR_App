import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ocr_application2/screens/text_recognition_app.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'screens/login_page.dart';
import 'screens/profile_page.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';
import 'screens/saved_scans_pages.dart';
import 'screens/scan_history_page.dart';
import 'screens/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await requestCameraPermission(); // Request camera permission
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'OCR App',
          theme: themeProvider.isDarkMode
              ? ThemeData.dark().copyWith(
                  primaryColor: Colors.blueGrey,
                  colorScheme: ColorScheme.fromSwatch(
                    primarySwatch: Colors.blueGrey,
                    brightness: Brightness.dark,
                  ),
                )
              : ThemeData.light().copyWith(
                  primaryColor: Colors.blue,
                  colorScheme: ColorScheme.fromSwatch(
                    primarySwatch: Colors.blue,
                    brightness: Brightness.light,
                  ),
                ),
          routes: {
            '/login': (context) => const LoginPage(),
            '/profile': (context) => const ProfilePage(),
            '/settings': (context) => const SettingsPage(),
            '/register': (context) => const RegisterPage(),
            '/home': (context) => const HomePage(),
            '/ocr': (context) => const OCRApp(),
            '/history': (context) => const ScanHistoryPage(),
            '/saved': (context) => const SavedScansPage(),
          },
          initialRoute: '/login',
        );
      },
    );
  }
}
