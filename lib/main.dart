import 'package:chat_app/ui/screen/home_chat.dart';
import 'package:chat_app/ui/screen/screen.dart';
import 'package:chat_app/ui/screen/signin.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tenures',
      debugShowCheckedModeBanner: false,
      //theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      // themeMode: ThemeMode.dark,

      home: SplashScreen(),
    );
  }
}
