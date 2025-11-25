import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:skillyfta/pages/beranda_page.dart';
import 'firebase_options.dart';
import 'screens/screen_one.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
          // KONDISI LOADING: cek token di HP
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              ),
            );
          }

          // UDH LOGIN: Ada data user -> Langsung ke Beranda
          if (snapshot.hasData) {
            return const BerandaPage(); 
          }

          // BELUM LOGIN / LOGOUT: -> Ke Halaman awal
          return const ScreenOne(); 
        },
      ),
    );
  }
}