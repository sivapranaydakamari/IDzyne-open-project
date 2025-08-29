// Removed few important lines in code for not giving complete implementation

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idzyne/home_screen.dart';
import 'package:idzyne/login_signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:idzyne/widgets/custom_bottom_navbar.dart';

Future<void> saveLoginState(String userId, String username) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userId', userId);
  await prefs.setString('username', username);
  await prefs.setBool('isLoggedIn', true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String? username = prefs.getString('username');
  final String? loginUserId = prefs.getString('userId');

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          isLoggedIn && username != null && loginUserId != null
              ? HomeScreen(userName: username, userId: loginUserId)
              : const LoginScreen(),
    ),
  );
}

