import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rogzarpath/BannerCarousel.dart';
import 'package:rogzarpath/DailyQuizLeaderboard.dart';
import 'package:rogzarpath/Job/job.dart';
import 'package:rogzarpath/Mcq/bookmark_question.dart';
import 'package:rogzarpath/Profile/aboutus.dart';
import 'package:rogzarpath/Profile/deawer.dart';
import 'package:rogzarpath/constant/model.dart';
import 'package:rogzarpath/currentaffair/currentaffairtab.dart';
import 'package:rogzarpath/daily_news_screen.dart';
import 'package:rogzarpath/daily_quiz_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rogzarpath/dashboard.dart';
import 'package:rogzarpath/syllabus_list_screen.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final int index=0;

final List<_HomeFeature> features = [
  
  _HomeFeature("Daily Quiz", Icons.calendar_today, (context,index) {
    print("Daily Quiz tapped");
    Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => DailyQuizScreen()),
);
  
  }),
   _HomeFeature("Jobs", Icons.work_outline_rounded, (context,index) {
    print("Jobs..........................................");
    if (index == 1) {
      // open Jobs tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(initialIndex: 1)),
      );}


    print("Jobs tapped");
    print(index);
  }),
   _HomeFeature("MCQs", Icons.quiz_rounded, (context,index) {
    print("MCQS..........................................");
    if (index == 2) {
      // open Jobs tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(initialIndex: 2)),
      );}


    print("Jobs tapped");
    print(index);
  }),

   _HomeFeature("Mock Test", Icons.quiz_rounded, (context,index) {
    print("Mock Test..........................................");
    if (index == 3) {
      // open Jobs tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(initialIndex: 3)),
      );}


    print("Jobs tapped");
    print(index);
  }),
  _HomeFeature("PDF Notes", Icons.picture_as_pdf, (context,index) {
    print("PDF Notes tapped");
    
    Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => SyllabusListScreen()),
);
  }),
  _HomeFeature("MCQs History", Icons.history_edu, (context,index) {
    print("Mock History tapped");
    Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => BookmarkPage()),
);
  }),
  _HomeFeature("Leaderboard", Icons.leaderboard, (context,index) {
    print("Leaderboard tapped");
    
    Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => DailyQuizLeaderboardScreen()),
);
  }),
  _HomeFeature("Current Affairs", Icons.newspaper, (context,index) {
    print("Current Affairs..........................................");
    Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => HomeTabs()),
);

    print("Notifications tapped");
  }),

  
 
];


  final List<Map<String, String>> sliderData = [
    {
      'image':
          'assets/banner.png',
      'title': '',
      'desc': ''
    },
    {
      'image':
          'assets/banner.png',
      'title': '',
      'desc': ''
    },
    
  ];

  
  final List<Map<String, dynamic>> menuItems = [
    {'title': 'About us', 'icon': Icons.info},
    {'title': 'Share', 'icon': Icons.share},
    {'title': 'Rate This App', 'icon': Icons.star},
    {'title': 'Disclaimer', 'icon': Icons.notification_add},
    {'title': 'Privacy Policy', 'icon': Icons.privacy_tip},
    {'title': 'Terms & Condition', 'icon': Icons.privacy_tip_outlined},
  ];


 final String whatsappUrl = "https://chat.whatsapp.com/GnVhxxw7rpmJPNwophB8En";

  // Function to open WhatsApp link
  Future<void> _openWhatsApp() async {
    final uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch WhatsApp");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     drawer: CustomDrawer(menuItems: [
  {'icon': Icons.info, 'title': 'About us', 'type': 'page', 'page': AboutPage()},
  {'icon': Icons.share, 'title': 'Share', 'type': 'share'},
  {'icon': Icons.star_rate, 'title': 'Rate This App', 'type': 'url', 'url': 'https://play.google.com/store/apps/details?id=com.rogzarpath.govexam'},
  {'icon': Icons.security, 'title': 'Disclaimer', 'type': 'url', 'url': 'https://vacancygyan.in/disclaimer-for-rozgarpath/'},
  {'icon': Icons.privacy_tip, 'title': 'Privacy Policy', 'type': 'url', 'url': 'https://vacancygyan.in/rozgarpath-privacy-policy/'},
  {'icon': Icons.policy, 'title': 'Terms & Condition', 'type': 'url', 'url': 'https://vacancygyan.in/terms-and-conditions-for-rozgarpath/'},
])
,
    
       floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _openWhatsApp,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.group, size: 32, color: Colors.white),
        ),
      ),
      appBar: AppBar(
        title:  Text("Rozgarpath",style: GoogleFonts.poppins(fontWeight:FontWeight.w600),),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/Rozgarpath.png'), // or NetworkImage
              radius: 28,
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
             
         
         BannerCarousel(),
         
           
           Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 10 ),
          itemCount: features.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
      final feature = features[index];
      return GestureDetector(
        onTap: () => feature.onTap(context,index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade400,
                Colors.deepPurple.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(4, 6),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            onTap: () => feature.onTap(context,index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circle icon background
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  child: Icon(
                    feature.icon,
                    size: 36,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  feature.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
          },
        ),
      )
      
          
          ],
        ),
      ),
    );
  }
}

class _HomeFeature {
  final String label;
  final IconData icon;
  final void Function(BuildContext context, int index) onTap;

  _HomeFeature(this.label, this.icon, this.onTap);
}
