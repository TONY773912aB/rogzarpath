import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:rogzarpath/api_service.dart';
import 'package:rogzarpath/constant/AppConstant.dart';

class DailyQuizLeaderboardScreen extends StatefulWidget {
  @override
  _DailyQuizLeaderboardScreenState createState() => _DailyQuizLeaderboardScreenState();
}

class _DailyQuizLeaderboardScreenState extends State<DailyQuizLeaderboardScreen> {
  List<dynamic> leaderboard = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }
  

  Future<void> fetchLeaderboard() async {
    final response = await http.get(Uri.parse('${ApiService.appUrl}get_quiz_leaderboard.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status']) {
        setState(() {
          leaderboard = data['leaderboard'];
          isLoading = false;
        });
      }
    }
  }

  Color getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return Colors.blueGrey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6FD),
      appBar: AppBar(
        iconTheme: IconThemeData(
    color: Colors.white, // Change this to your desired color
  ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: MyColors.appbar
          ),
        ),
        title: Text("🏆 Daily Quiz Leaderboard", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize:17)),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : leaderboard.isEmpty
              ? Center(child: Text("No leaderboard data found"))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final user = leaderboard[index];
                    final isTop3 = index < 3;

                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isTop3
                              ? [getRankColor(index).withOpacity(0.6), getRankColor(index)]
                              : [Colors.white, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
  radius: 25,
  backgroundColor:  isTop3 ? getRankColor(index) : Colors.deepPurple,
  backgroundImage: (user['photo_url'] != null && user['photo_url'].toString().isNotEmpty)
      ? NetworkImage(user['photo_url'])
      : AssetImage('assets/Rozgarpath.png') as ImageProvider,

      // Text(
                          //   "#${index + 1}",
                          //   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          // ),
)

                        
                        ,
                        title: Text(
                          user['name'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          "Correct: ${user['correct']} | Accuracy: ${user['accuracy']}%",
                          style: GoogleFonts.poppins(color: Colors.black54),
                        ),
                        trailing:  Text(
                            "#${index + 1}",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                       // Icon(Icons.emoji_events, color: isTop3 ? Colors.orange : Colors.green),
                      ),
                    );
                  },
                ),
    );
  }
}
