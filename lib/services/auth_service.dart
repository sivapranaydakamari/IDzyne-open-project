// Removed few important lines in code for not giving complete implementation

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _isLoggedInKey = 'is_logged_in';

  // Save user data after successful login
  static Future<void> saveUserData({
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, userName);
    await prefs.setString(_userEmailKey, userEmail);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Check if user is logged in
  // static Future<bool> isLoggedIn() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getBool(_isLoggedInKey) ?? false;
  // }

  // // Get stored user ID
  // static Future<String?> getUserId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(_userIdKey);
  // }

  // // Get stored user name
  // static Future<String?> getUserName() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(_userNameKey);
  // }

  // Get stored user email
  // static Future<String?> getUserEmail() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(_userEmailKey);
  // }

  // Clear all user data (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Clear all stored data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}