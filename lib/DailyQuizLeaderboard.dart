import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:rogzarpath/api_service.dart';
import 'package:rogzarpath/constant/admanager.dart';

class DailyQuizLeaderboardScreen extends StatefulWidget {
  @override
  _DailyQuizLeaderboardScreenState createState() =>
      _DailyQuizLeaderboardScreenState();
}

class _DailyQuizLeaderboardScreenState
    extends State<DailyQuizLeaderboardScreen> {
  List<dynamic> leaderboard = [];
  bool isLoading = true;
  String filterType = "today"; // today, week, month

  @override
  void initState() {
    super.initState();
    _showRewardedAdThenFetch();
  }

  void _showRewardedAdThenFetch() async {
    AdManager.fetchAds().then((ads) {
      final rewardedAd = ads.firstWhere(
        (ad) => ad['ad_format'] == 'rewarded',
        orElse: () => null,
      );

      if (rewardedAd != null) {
        AdManager.loadRewarded(
          rewardedAd,
          onRewarded: () {
            debugPrint("✅ Rewarded Ad Completed → Unlock Leaderboard");
            fetchLeaderboard();
          },
        );
      } else {
        fetchLeaderboard();
      }
    });
  }

  Future<void> fetchLeaderboard() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(
          '${ApiService.appUrl}get_quiz_leaderboard.php?filter=$filterType'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status']) {
          setState(() {
            leaderboard = data['leaderboard'];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Error fetching leaderboard: $e");
      setState(() => isLoading = false);
    }
  }

  // 🏆 Podium UI for top 3
  Widget buildPodium() {
    if (leaderboard.length < 3) return const SizedBox();

    final first = leaderboard[0];
    final second = leaderboard[1];
    final third = leaderboard[2];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.deepPurple.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildPodiumUser(second, 2, 110),
          buildPodiumUser(first, 1, 140, isWinner: true),
          buildPodiumUser(third, 3, 95),
        ],
      ),
    );
  }

  Widget buildPodiumUser(user, int rank, double height,
      {bool isWinner = false}) {
    // Parse accuracy safely
    final accuracy = double.tryParse(user['accuracy']?.toString() ?? "0") ?? 0;
    // Example points system: correct * 10
    final points =
        (int.tryParse(user['correct']?.toString() ?? "0") ?? 0) * 10;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            CircleAvatar(
              radius: isWinner ? 45 : 38,
              backgroundImage: (user['photo_url'] != null &&
                      user['photo_url'].toString().isNotEmpty)
                  ? NetworkImage(user['photo_url'])
                  : const AssetImage('assets/Rozgarpath.png') as ImageProvider,
            ),
            if (isWinner)
              const Positioned(
                top: -10,
                child: Icon(Icons.emoji_events,
                    color: Colors.amber, size: 40),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width/4,
          child: Text(
            user['name'],
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500, fontSize: 15, color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: height,
          width: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isWinner
                  ? [Colors.amber, Colors.orange]
                  : [Colors.white, Colors.grey.shade300],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            "$rank",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isWinner ? Colors.black : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Acc: ${accuracy.toStringAsFixed(0)}%",
          style: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          "$points pts",
          style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.amber),
        ),
      ],
    );
  }

  // 🎨 Modern leaderboard card
  Widget buildLeaderboardItem(user, int rank) {
    final correct =
        int.tryParse(user['correct']?.toString() ?? "0") ?? 0;
    final attempted =
        int.tryParse(user['attempted']?.toString() ?? "0") ?? 0;
    final accuracy =
        double.tryParse(user['accuracy']?.toString() ?? "0") ?? 0;
    final points = correct * 10;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: (user['photo_url'] != null &&
                    user['photo_url'].toString().isNotEmpty)
                ? NetworkImage(user['photo_url'])
                : const AssetImage('assets/Rozgarpath.png') as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$rank. ${user['name']}",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text("$correct  ",
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.w500)),
                    const Icon(Icons.cancel, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text("$attempted  ",
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w500)),
                    const Icon(Icons.insights, color: Colors.blue, size: 16),
                    const SizedBox(width: 4),
                    Text("${accuracy.toStringAsFixed(0)}%",
                        style: const TextStyle(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "$points pts",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Filter chips
  Widget buildFilterChips() {
    final filters = ["today", "week", "month"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: filters.map((f) {
        final isSelected = filterType == f;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: ChoiceChip(
            label: Text(
              f.toUpperCase(),
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87),
            ),
            selected: isSelected,
            selectedColor: Colors.deepPurple,
            onSelected: (_) {
              setState(() {
                filterType = f;
              });
              fetchLeaderboard();
            },
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F8),
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        title: Text(
          "🏆 Daily Quiz Leaderboard",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : leaderboard.isEmpty
              ? const Center(
                  child: Text(
                    "No leaderboard data found",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              : Column(
                  children: [
                    buildPodium(),
                    const SizedBox(height: 16),
                    buildFilterChips(),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: leaderboard.length,
                        itemBuilder: (context, i) {
                          if (i < 3) return const SizedBox();
                          return buildLeaderboardItem(leaderboard[i], i + 1);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
