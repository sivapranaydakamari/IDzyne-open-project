// Removed few important lines in code for not giving complete implementation

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idzyne/home_screen.dart';
import 'package:idzyne/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return AuthScreen();
  }
}


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement the UI for AuthScreen here
    return Container(); // Placeholder widget
  }
}

class LoginPage extends StatefulWidget {
  final VoidCallback onNavigate;
  const LoginPage({super.key, required this.onNavigate});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isViewPassword = true;

  Future<void> loginUser(String email, String password) async {
    final url = Uri.parse('https://example.com/api/user/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final String userName = data['name'];
        final String userId = data['_id'];

        final token = data['_id'];

        data = json.decode(response.body);
        await saveLoginState(userId, userName);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['_id']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => HomeScreen(userName: userName, userId: userId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Login failed")),
        );
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    'assets/images/Login.gif',
                    height: 100,
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 32),
                Center(
                  child: Text(
                    'Welcome back',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Log in',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          labelText: 'Email address',
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          border: const UnderlineInputBorder(),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(119, 158, 158, 158),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: isViewPassword,
                        keyboardType: TextInputType.visiblePassword,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          border: const UnderlineInputBorder(),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(119, 158, 158, 158),
                            ),
                          ),
                          suffixIcon: IconButton(
                            iconSize: 20,
                            onPressed: () {
                              setState(() {
                                isViewPassword = !isViewPassword;
                              });
                            },
                            icon:
                                isViewPassword
                                    ? const Icon(Icons.visibility_off)
                                    : const Icon(Icons.visibility),
                            color: const Color.fromARGB(255, 33, 36, 36),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: widget.onNavigate,
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: OutlinedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState?.validate() ?? false) {
                        await loginUser(
                          _emailController.text,
                          _passwordController.text,
                        );
                      } else {
                        debugPrint('Validation failed!');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1.5),
                      shape: const RoundedRectangleBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 84,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Log In',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotAndResetScreen extends StatefulWidget {
  final VoidCallback onNavigate;
  const ForgotAndResetScreen({super.key, required this.onNavigate});

  @override
  State<ForgotAndResetScreen> createState() => _ForgotAndResetScreenState();
}

class _ForgotAndResetScreenState extends State<ForgotAndResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool isOtpSent = false;
  bool isOtpVerified = false;
  bool isPasswordHidden = true;
  bool isLoading = false;
  String? receivedOtp;

  Future<void> sendOtp() async {
    setState(() => isLoading = true);
    final url = Uri.parse('https://example.com/api/user/forgot-password');

    try {
      debugPrint('Sending OTP to: ${_emailController.text.trim()}');

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text.trim()}),
      );

      debugPrint('OTP Response Status: ${res.statusCode}');
      debugPrint('OTP Response Body: ${res.body}');

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        receivedOtp = data['otp']?.toString();
        debugPrint('OTP received from backend: $receivedOtp');
        setState(() => isOtpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'OTP sent successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to send OTP')),
        );
      }
    } catch (e) {
      debugPrint("Error sending OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please try again.')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    final url = Uri.parse('https://example.com/api/user/verify-otp');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("OTP verified: ${data['message']}");
      return true;
    } else {
      debugPrint("Failed to verify OTP: ${response.body}");
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    final url = Uri.parse('https://example.com/api/user/reset-password');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'newPassword': newPassword}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("Password reset successful: ${data['message']}");
      return true;
    } else {
      debugPrint("Failed to reset password: ${response.body}");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.8),
      body: SafeArea(
        child: Row(
          children: [
            const SizedBox(height: 20),
            Text(
              isOtpVerified
                  ? 'Set New Password'
                  : isOtpSent
                  ? 'Enter OTP'
                  : 'Forgot Password',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isOtpVerified
                  ? 'Create your new password'
                  : isOtpSent
                  ? 'Check your email for the OTP'
                  : 'Enter your email to receive OTP',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
                
            TextFormField(
              controller: _emailController,
              enabled: !isOtpSent,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black,
              ),
              keyboardType: TextInputType.emailAddress,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                labelText: 'Email address',
                labelStyle: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 12,
                ),
                border: const UnderlineInputBorder(),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(119, 158, 158, 158),
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // removed OTP and New Password fields
            isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  !isOtpSent
                      ? 'Send OTP'
                      : !isOtpVerified
                      ? 'Verify OTP'
                      : 'Reset Password',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // removed few lines of code for not giving complete code
            const SizedBox(height: 40),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: widget.onNavigate,
              child: Text(
                '← Back to Login',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
