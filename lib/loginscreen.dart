import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
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
      body: Stack(
        children: [
          /// Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// Glassmorphism Login Card
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Logo
                    CircleAvatar(
                      backgroundImage: const AssetImage('assets/Rozgarpath.png'),
                      radius: 55,
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                    const SizedBox(height: 20),

                    /// Title
                    Text(
                      "Welcome to Rozgarpath",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// Subtitle
                    Text(
                      "Your Govt. Exam Preparation Guide",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 35),

                    /// Google Sign-In Button
                    _isSigningIn
                        ? const CircularProgressIndicator(color: Colors.white)
                        : ElevatedButton.icon(
                            icon: Image.asset(
                              "assets/google.png",
                              height: 24,
                            ),
                            label: Text(
                              "Sign in with Google",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 3,
                            ),
                            onPressed: _handleGoogleLogin,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
