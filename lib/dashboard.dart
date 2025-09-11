import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rogzarpath/Job/job.dart';
import 'package:rogzarpath/Mcq/examlist.dart';
import 'package:rogzarpath/MockTest/mockexamlist.dart';
import 'package:rogzarpath/Profile/profile.dart';
import 'package:rogzarpath/constant/AppConstant.dart';
import 'package:rogzarpath/constant/model.dart';
import 'package:rogzarpath/homepage.dart';


class DashboardScreen extends StatefulWidget {
   final int initialIndex;
  const DashboardScreen({super.key,this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
   
   @override
  void initState() {
    _currentIndex = widget.initialIndex; 
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

  
  Future<bool> exitConfirm() async {
    return await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text('Are you sure?',
                  style: GoogleFonts.poppins(
                    fontSize: 17.0,
                    color: Colors.blue[900],
                    fontWeight: FontWeight.w700,
                  )),
              content: Text('Do you want to exit an App',
                  style: GoogleFonts.poppins(
                    fontSize: 15.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  )),
              actions: <Widget>[
                MaterialButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No'),
                ),
                MaterialButton(
                  onPressed: () => exit(0),
                  /*Navigator.of(context).pop(true)*/
                  child: Text('Yes'),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }
  @override
  Widget build(BuildContext context) {
    return 
    
  WillPopScope(
      onWillPop: exitConfirm,
      child:  Scaffold(
        body: _screens[_currentIndex],
      
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          backgroundColor: MyColors.appbar,
          selectedItemColor: Colors.white,
          selectedLabelStyle: GoogleFonts.poppins(),
          unselectedLabelStyle: GoogleFonts.poppins(),
          unselectedItemColor: Colors.grey[400],
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
      ),
    );
  }
}
