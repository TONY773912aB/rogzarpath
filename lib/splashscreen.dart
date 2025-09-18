import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rogzarpath/constant/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rogzarpath/loginscreen.dart';
import 'package:rogzarpath/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    _logoController.forward();
    _textController.forward();

    Timer(const Duration(seconds: 3), checkLoginStatus);
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      String googleId = prefs.getString('uid') ?? "";
      String name = prefs.getString('name') ?? "";
      String email = prefs.getString('email') ?? "";
      String photoUrl = prefs.getString('photoUrl') ?? "";

      UserTable.setUser(
        id: googleId,
        userName: name,
        userEmail: email,
        userPhoto: photoUrl,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    body: Stack(
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Glass effect
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.1),
          ),
        ),
        // Centered logo & text
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _logoAnimation,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/logo2.png',
                    height: 190,
                    width: 190,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FadeTransition(
                opacity: _textAnimation,
                child: Column(
                  children: [
                    Text(
                      "RozgarPath",
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Your Govt. Exam Guide",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Disclaimer at the bottom
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Disclaimer: RozgarPath is not affiliated with or represents any government entity. All content is for educational purposes only.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                height: 1.3,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}
