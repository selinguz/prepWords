import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/pages/categories_content.dart';
import 'package:prep_words/pages/exam_calendar_page.dart';
import 'package:prep_words/pages/home_page.dart';
import 'package:prep_words/pages/levels_page.dart';
import 'package:prep_words/pages/sign_in_page.dart';
import 'package:prep_words/pages/sign_up_page.dart';
import 'package:prep_words/pages/words_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prep_words/provider/word_status_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('tr_TR', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WordStatusProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/levels') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => LevelsPage(
              level: args['level'],
              levelName: args['levelName'],
              unitCount: args['unitCount'],
            ),
          );
        } else if (settings.name == '/words') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => WordsPage(unit: args['unit']),
          );
        }
        return MaterialPageRoute(
          builder: (context) {
            switch (settings.name) {
              case '/':
                return SplashScreen();
              case '/signin':
                return SignInPage();
              case '/signup':
                return SignUpPage();
              case '/categories':
                return CategoriesContent();
              case '/home':
                return HomePage();
              case '/examCalendar':
                return ExamCalendarPage();
              default:
                return SplashScreen();
            }
          },
        );
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
      const Duration(seconds: 3),
      () {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Kullanıcı giriş yapmış -> HomePage
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Kullanıcı giriş yapmamış -> SignInPage
          Navigator.pushReplacementNamed(context, '/signin');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowGreen, // Splash Screen background color
      body: Center(
        child: Image.asset('assets/images/splashYellowGreen.gif'),
      ),
    );
  }
}
