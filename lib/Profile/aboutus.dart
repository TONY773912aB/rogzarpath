import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About RozgarPath'),
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
                "RozgarPath is a private educational app (not affiliated with any government entity) designed to help aspirants prepare for Indian competitive exams such as SSC, UPSC, Railway, Banking, Defence, and State PSCs. It provides job alerts, mock tests, quizzes, study material, and more—all for educational purposes.",
                style: GoogleFonts.poppins(fontSize: 15.5),
              ),
              const SizedBox(height: 24),

              // Mission
              sectionTitle("🚀 Our Mission"),
              sectionText(
                "To make government exam preparation accessible, effective, and affordable for every student, especially those in remote areas with limited access to coaching.",
              ),

              // Features
              sectionTitle("📚 Key Features"),
              bulletPoint("Daily Job Alerts – Sourced from official recruitment portals via our secure Vacancygyan.in API."),
              bulletPoint("Mock Tests & Quizzes – Practice and track your performance."),
              bulletPoint("PDF Notes & Study Material – Covers History, Polity, Science, Geography, Current Affairs, and more."),
              bulletPoint("Daily Quiz – Improve GK and Current Affairs daily."),
              bulletPoint("User-Friendly Interface – Smooth experience even on low-end devices."),
              bulletPoint("Offline Mode (Coming Soon) – Download content and study without internet."),

              // Audience
              sectionTitle("👥 Who Can Use RozgarPath"),
              bulletPoint("First-time aspirants seeking guidance."),
              bulletPoint("Repeat candidates aiming to improve scores."),
              bulletPoint("Students preparing for central & state-level exams."),
              bulletPoint("Working professionals balancing preparation with jobs."),

              // Why Choose
              sectionTitle("💡 Why Choose RozgarPath?"),
              bulletPoint("🔔 Real-time Notifications"),
              bulletPoint("📊 Performance Tracking"),
              bulletPoint("🌐 Hindi & English Content"),
              bulletPoint("🆓 Completely Free – No hidden charges"),
              bulletPoint("✅ Trusted Educational Platform for Government Exams"),

              // Disclaimer Note
              sectionTitle("❗ Disclaimer"),
              sectionText(
                "RozgarPath is not affiliated with any government authority. All job information is collected from official recruitment portals and Vacancygyan.in API. Users should verify details on official websites before applying.",
              ),

              // Contact
              sectionTitle("📞 Contact Us"),
              sectionText("📧 Email: Tonystark7739@gmail.com"),
              sectionText("📍 Location: Gopalganj, Bihar, India"),

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
