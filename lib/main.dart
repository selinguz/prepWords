import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/pages/categories_page.dart';
import 'package:prep_words/pages/sign_in_page.dart';
import 'package:prep_words/pages/sign_up_page.dart';
import 'package:prep_words/pages/words_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/signin': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/words': (context) => WordsPage(),
        '/categories': (context) => CategoryPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 5),
      () => Navigator.pushReplacementNamed(context, '/signin'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary, // Splash Screen background color
      body: Center(
        child: Image.asset('assets/images/splash.gif'),
      ),
    );
  }
}
