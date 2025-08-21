import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_signup/screens/welcome_screen.dart';
import 'package:login_signup/screens/signin_screen.dart';
import 'package:login_signup/screens/signup_screen.dart';
import 'package:login_signup/screens/home_page.dart';
import 'package:login_signup/screens/admin_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _initialPage = const WelcomeScreen();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? role = prefs.getString("role");

    if (role != null) {
      if (role == "follower") {
        setState(() {
          _initialPage = HomePage();
        });
      } else if (role == "admin") {
        setState(() {
          _initialPage = const AdminPage();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "MLA Project",
      home: _initialPage,
    );
  }
}
