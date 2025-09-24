import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rogzarpath/api_service.dart';
import 'package:rogzarpath/constant/AppConstant.dart';
import 'package:rogzarpath/constant/admanager.dart';
import 'package:rogzarpath/constant/model.dart';
import 'mock_test_screen.dart';

class MockTestListScreen extends StatefulWidget {
  final int examId;
  final String examName;

  const MockTestListScreen({required this.examId, required this.examName});

  @override
  _MockTestListScreenState createState() => _MockTestListScreenState();
}

class _MockTestListScreenState extends State<MockTestListScreen> {
  late Future<List<MockTest>> futureTests;

  @override
  void initState() {
    super.initState();
    futureTests = MockTestService.getTests(widget.examId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.examName,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: MyColors.appbar,
        centerTitle: true,
      ),
     
     
      body: Column(
        children: [

          Expanded(
            child: FutureBuilder<List<MockTest>>(
              future: futureTests,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
            
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No mock tests found.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
            
                final tests = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: tests.length,
                  itemBuilder: (_, index) {
                    final test = tests[index];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MockTestScreen(test: test),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade200],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  child: const Icon(Icons.quiz,
                                      size: 32, color: Colors.deepPurple),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        test.title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          _buildInfoChip(
                                              icon: Icons.timer,
                                              label: "${test.duration} mins"),
                                          const SizedBox(width: 8),
                                          _buildInfoChip(
                                              icon: Icons.star,
                                              label: "${test.totalMarks} Marks"),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios,
                                    size: 18, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
       FutureBuilder(
  future: AdManager.fetchAds(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Text("❌ Error: ${snapshot.error}");
    }

    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
      final ads = snapshot.data as List<dynamic>;

      // Pick banner ad
      final bannerAd = ads.firstWhere(
        (ad) => ad['ad_format'] == 'banner',
        orElse: () => null,
      );

      if (bannerAd != null) {
        return AdManager.loadBanner(
          bannerAd,
          onAdLoaded: () => print("🎯 Banner Ad Loaded Successfully"),
          onAdFailed: (error) => print("❌ Banner Ad Failed: $error"),
        );
      }
    }

    return const SizedBox.shrink();
  },
)
,
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
