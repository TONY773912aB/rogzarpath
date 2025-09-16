import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rogzarpath/Mcq/bookmark_question.dart';
import 'package:rogzarpath/Job/BookmarkedJobsScreen.dart';
import 'package:rogzarpath/api_service.dart';
import 'package:rogzarpath/constant/model.dart';
import 'package:rogzarpath/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String email = '';
  String photoUrl = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'Guest';
      email = prefs.getString('email') ?? 'guest@example.com';
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

  Future<void> _openBookmarkedJobs() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BookmarkedJobsScreen()),
    );
  }

   bool _isLoading = false;

Future<void> deleteProfile() async {
    setState(() {
      _isLoading = true;
    });
 SharedPreferences prefs = await SharedPreferences.getInstance();
 String? googleId = prefs.getString('uid');
 print(googleId);
 print("google id........................................");
    try {
      final response = await http.post(
  Uri.parse("${ApiService.appUrl}delete_profile.php"),
  headers: {
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'google_id': googleId,
  }),
);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Clear any stored data
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
 Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
         
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Unknown error')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

 void confirmDelete() {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismiss by tapping outside
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.red, size: 30),
          SizedBox(width: 10),
          Text("Delete Profile", style: GoogleFonts.poppins(color: Colors.red, fontWeight:FontWeight.w600)),
        ],
      ),
      content: Text(
        "Are you sure you want to delete your profile? "
        "This action cannot be undone and all your data will be lost.",
        style: TextStyle(fontSize: 16),
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actions: [
        ElevatedButton.icon(
          onPressed: () => Navigator.of(ctx).pop(),
          icon: Icon(Icons.cancel),
          label: Text("Cancel"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(ctx).pop();
            deleteProfile();
          },
          icon: Icon(Icons.delete_forever),
          label: Text("Delete"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    ),
  );
}


  Future<void> _openBookmarkedMCQ() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BookmarkPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
//final themeColor = Colors.deepPurple;
    final MaterialColor themeColor = Colors.deepPurple;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      body: Column(
        children: [
          _buildHeader(themeColor),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
               // _buildOption(Icons.person_outline, "Edit Profile", () {}),
                _buildOption(Icons.quiz_outlined, "MCQ History", _openBookmarkedMCQ),
                _buildOption(Icons.bookmark_border, "Bookmarked Jobs", _openBookmarkedJobs),
                _buildOption(Icons.delete_forever, "Delete Profile", confirmDelete,color: Colors.red),
                _buildOption(Icons.logout, "Logout", _logout, color: Colors.red),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    "📱 App Version 1.0.0",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(MaterialColor themeColor) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
  colors: [themeColor[700]!, themeColor[400]!], // Use [] instead of .shade
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade200,
            offset: const Offset(0, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            child: CircleAvatar(
              radius: 52,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 48,
                backgroundImage: photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : const AssetImage('assets/logo.png') as ImageProvider,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            name,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        leading: Container(
          decoration: BoxDecoration(
            color: (color ?? Colors.deepPurple).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color ?? Colors.deepPurple, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}


