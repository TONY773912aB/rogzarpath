import 'package:flutter/material.dart';
import 'package:rogzarpath/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String email = '';
  String photoUrl = '';
  String examTarget = 'SSC';

  final List<String> examTargets = ['SSC', 'UPSC', 'Railway', 'Banking', 'Defence'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      email = prefs.getString('email') ?? '';
      photoUrl = prefs.getString('photoUrl') ?? '';
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : AssetImage('assets/user.png') as ImageProvider,
              radius: 50,
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(email, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 20),

            /// Exam Target Dropdown
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: examTarget,
                  icon: Icon(Icons.arrow_drop_down),
                  items: examTargets.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text("Target: $value"),
                    );
                  }).toList(),
                  onChanged: (newVal) {
                    setState(() {
                      examTarget = newVal!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// Profile Options
            _buildOption(Icons.edit, "Edit Profile", () {
              // Add logic or navigation
            }),
            _buildOption(Icons.history, "Test History", () {
              // Navigate to TestHistoryScreen
            }),
            _buildOption(Icons.bookmark, "Bookmarked Questions", () {
              // Navigate to BookmarkedQuestionsScreen
            }),
            _buildOption(Icons.logout, "Logout", _logout, color: Colors.red),

            const SizedBox(height: 30),
            Text(
              "App version 1.0.0",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.deepPurple),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }
}
