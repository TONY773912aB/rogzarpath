import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Rozgarpath'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Logo
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/Rozgarpath.png'),
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 20),
              
              // App Intro
              Text(
                "Rozgarpath is your trusted companion in the journey of government exam preparation. Designed for aspirants of SSC, UPSC, Railway, Banking, State PSCs, and other competitive exams, Rozgarpath provides timely updates, quality practice material, and a distraction-free study environment — all in one app.",
                style: GoogleFonts.poppins(fontSize: 15.5),
              ),
              const SizedBox(height: 24),

              // Mission
              sectionTitle("🚀 Our Mission"),
              sectionText(
                "To make government exam preparation accessible, affordable, and effective for every student, especially those from remote and rural areas who lack access to expensive coaching centers.",
              ),

              // Features
              sectionTitle("📚 What We Offer"),
              bulletPoint("Daily Job Alerts – Real-time updates from SSC, UPSC, IBPS, etc."),
              bulletPoint("Mock Tests & Quizzes – Improve your accuracy and speed."),
              bulletPoint("Study Material & PDFs – Notes, previous papers, and more."),
              bulletPoint("Daily Quiz – Practice a 5-minute quiz every day."),
              bulletPoint("User-Friendly Interface – Smooth even on low-end devices."),

              // Audience
              sectionTitle("👥 Who We Serve"),
              bulletPoint("First-time aspirants needing guidance."),
              bulletPoint("Repeat candidates working to improve their scores."),
              bulletPoint("Students preparing for central & state-level exams."),
              bulletPoint("Working professionals balancing job and prep."),

              // Why Choose
              sectionTitle("💡 Why Choose Rozgarpath?"),
              bulletPoint("🔔 Real-time Notifications"),
              bulletPoint("📊 Performance Tracking"),
              bulletPoint("🌐 Hindi & English (Coming Soon)"),
              bulletPoint("🆓 100% Free – No hidden charges"),

              // Our Promise
              sectionTitle("🙏 Our Promise"),
              sectionText(
                "We are committed to supporting your journey with authentic information, regular updates, and exam-focused tools. Your success is our priority.",
              ),

              // Contact
              sectionTitle("📞 Contact Us"),
              sectionText("📧 Email: Tonystark7739@gmail.com"),
              sectionText("📍 Location: Gopalganj, Bihar"),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.indigo,
        ),
      ),
    );
  }

  Widget sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 15.5),
      ),
    );
  }

  Widget bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  ", style: TextStyle(fontSize: 18)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
