import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:skillyfta/pages/beranda_page.dart';
import 'firebase_options.dart';
import 'screens/screen_one.dart';
import 'package:skillyfta/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.scheduleDailyNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skillyfta',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        fontFamily: 'FamiljenGrotesk',
        scaffoldBackgroundColor: const Color(0xFF2c2a4a),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              ),
            );
          }

          if (snapshot.hasData) {
            return const BerandaPage(); 
          }

          return const ScreenOne(); 
        },
      ),
    );
  }
}