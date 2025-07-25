import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rogzarpath/auth_service.dart';
import 'package:rogzarpath/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

void saveLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('isLoggedIn', true);
}

  void _handleGoogleLogin() async {
    setState(() => _isSigningIn = true);
    final user = await _authService.signInWithGoogle();

    if (user != null) {
      saveLoginStatus();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    }

    setState(() => _isSigningIn = false);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_rounded, size: 90, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  "Welcome to RogzarPath",
                  style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your Govt. Exam Preparation Guide",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 40),
                _isSigningIn
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.login),
                        label: const Text("Sign in with Google"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: _handleGoogleLogin,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
