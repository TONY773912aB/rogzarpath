import 'package:flutter/material.dart';
import 'package:rogzarpath/Job/job.dart';
import 'package:rogzarpath/Mcq/examlist.dart';
import 'package:rogzarpath/MockTest/mockexamlist.dart';
import 'package:rogzarpath/Profile/profile.dart';
import 'package:rogzarpath/constant/model.dart';
import 'package:rogzarpath/homepage.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
   
   @override
  void initState() {
    print("User ID: ${UserTable.googleId}");
print("User Name: ${UserTable.name}");
print("Email: ${UserTable.email}");
    super.initState();
  }

  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    JobsScreen(),
    ExamScreen(),
    MockExamList(),
    ProfileScreen(),

  ];

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline_rounded),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_rounded),
            label: 'MCQs',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            label: 'MockTest',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
