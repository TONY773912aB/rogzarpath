import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<_HomeFeature> features = const [
    _HomeFeature("Govt Jobs", Icons.work_rounded),
    _HomeFeature("Practice MCQs", Icons.quiz_rounded),
    _HomeFeature("Mock Tests", Icons.assignment_turned_in),
    _HomeFeature("Daily Quiz", Icons.calendar_today),
    _HomeFeature("PDF Notes", Icons.picture_as_pdf),
    _HomeFeature("Test History", Icons.history_edu),
    _HomeFeature("Leaderboard", Icons.leaderboard),
    _HomeFeature("Notifications", Icons.notifications),
    _HomeFeature("More", Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RogzarPath"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/user.png'), // or NetworkImage
              radius: 18,
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
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
    );
  }
}

class _HomeFeature {
  final String label;
  final IconData icon;
  const _HomeFeature(this.label, this.icon);
}
