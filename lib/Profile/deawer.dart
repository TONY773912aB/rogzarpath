import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rogzarpath/constant/AppConstant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class CustomDrawer extends StatefulWidget {
  final List<Map<String, dynamic>> menuItems;

  const CustomDrawer({super.key, required this.menuItems});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? name;
  String? email;
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'Guest';
      email = prefs.getString('email') ?? 'guest@example.com';
      photoUrl = prefs.getString('photoUrl') ?? '';
    });
  }

  

void _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open the link')),
    );
  }
}


void _shareApp() {
  Share.share('Check out Rozgarpath – Government Exam Prep App:\nhttps://play.google.com/store/apps/details?id=com.rozgarpath.app');
}


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MyColors.appbar,
                boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black26)],
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 6)],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
                          ? NetworkImage(photoUrl!)
                          : AssetImage('assets/Rozgarpath.png') as ImageProvider,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    name ?? 'Guest',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    email ?? '',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            Expanded(
              child: ListView(
                children: widget.menuItems.map((item) {
                  return ListTile(
                    leading: Icon(item['icon'], color: Colors.indigo),
                    title: Text(
                      item['title'],
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    horizontalTitleGap: 10,
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.pop(context);
                       final type = item['type'];
  if (type == 'url') {
    final url = item['url'];
    if (url != null) {
      _launchURL(url);
    }
  } else if (type == 'share') {
    _shareApp();
  } else if (type == 'page') {
    final Widget? page = item['page'];
    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    }
  }
                      // Add navigation logic here
                    },
                  );
                }).toList(),
              ),
            ),

            // Divider(thickness: 1),

            // ListTile(
            //   leading: Icon(Icons.logout, color: Colors.redAccent),
            //   title: Text(
            //     "Logout",
            //     style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
            //   ),
            //   onTap: () {
            //     // Add logout logic
            //   },
            // ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
