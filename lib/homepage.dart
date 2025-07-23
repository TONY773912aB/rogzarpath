import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:rogzarpath/daily_news_screen.dart';
import 'package:rogzarpath/dashboard.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});


final List<_HomeFeature> features = [
  _HomeFeature("Govt Jobs", Icons.work_rounded, (context) {
    print("Govt Jobs tapped");
  }),
  _HomeFeature("Practice MCQs", Icons.quiz_rounded, (context) {
    print("Practice MCQs tapped");
  }),
  _HomeFeature("Mock Tests", Icons.assignment_turned_in, (context) {
    print("Mock Tests tapped");
  }),
  _HomeFeature("Daily Quiz", Icons.calendar_today, (context) {
    print("Daily Quiz tapped");
  }),
  _HomeFeature("PDF Notes", Icons.picture_as_pdf, (context) {
    print("PDF Notes tapped");
  }),
  _HomeFeature("Test History", Icons.history_edu, (context) {
    print("Test History tapped");
  }),
  _HomeFeature("Leaderboard", Icons.leaderboard, (context) {
    print("Leaderboard tapped");
  }),
  _HomeFeature("Current Affairs", Icons.newspaper, (context) {
    print("Current Affairs..........................................");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DailyNewsScreen()),
    );
    print("Notifications tapped");
  }),
  _HomeFeature("More", Icons.more_horiz, (context) {
    print("More tapped");
  }),
];


  final List<Map<String, String>> sliderData = [
    {
      'image':
          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=800&q=60',
      'title': 'UPSC 2025 Preparation',
      'desc': 'Stay updated with daily quizzes & notes'
    },
    {
      'image':
          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=800&q=60',
      'title': 'SSC Exams Mock Tests',
      'desc': 'Practice with real exam pattern tests'
    },
    {
      'image':
          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=800&q=60',
      'title': 'Banking Exam Updates',
      'desc': 'Get latest IBPS, SBI & RBI notifications'
    },
  ];

  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Home', 'icon': Icons.home},
    {'title': 'Bookmarks', 'icon': Icons.bookmark},
    {'title': 'Downloads', 'icon': Icons.download},
    {'title': 'Notifications', 'icon': Icons.notifications},
    {'title': 'Settings', 'icon': Icons.settings},
    {'title': 'Logout', 'icon': Icons.logout},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.indigo,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage('assets/avatar.png'),
                    ),
                    SizedBox(height: 10),
                    Text("Welcome, Student",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
              ...menuItems.map((item) {
                return ListTile(
                  leading: Icon(item['icon'], color: Colors.indigo),
                  title: Text(item['title']),
                  onTap: () {
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text("RogzarPath"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/Rozgarpath.png'), // or NetworkImage
              radius: 18,
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Padding(
        padding: const EdgeInsets.all(0.0),
        child: CarouselSlider.builder(
          itemCount: sliderData.length,
          itemBuilder: (context, index, realIndex) {
            final item = sliderData[index];
            return Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item['image']!,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.4),
                    colorBlendMode: BlendMode.darken,
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']!,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['desc']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          options: CarouselOptions(
            height: 220,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.85,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: Duration(seconds: 2),
          ),
        ),
      ),
    SizedBox(height: 20,),
            Expanded(
              child: GridView.builder(
                itemCount: features.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final feature = features[index];
                  return GestureDetector(
                    onTap: () {
                      feature.onTap(context);
                      // Navigate to respective screen
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.shade100,
                            blurRadius: 6,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(feature.icon, size: 34, color: Colors.deepPurple),
                          const SizedBox(height: 10),
                          Text(
                            feature.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.deepPurple.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeFeature {
  final String label;
  final IconData icon;
  final void Function(BuildContext context) onTap;

  _HomeFeature(this.label, this.icon, this.onTap);
}
