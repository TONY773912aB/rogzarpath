import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rogzarpath/Job/job_detail_screen.dart';
import 'package:rogzarpath/api_service.dart';
import 'package:rogzarpath/constant/admanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> with TickerProviderStateMixin {
  List<dynamic> categories = [];
  late TabController tabController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    final fetchedCategories = await ApiService.fetchCategories();
    setState(() {
      categories = fetchedCategories;
      tabController = TabController(length: categories.length + 1, vsync: this);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title:  Text('Latest Government Jobs',style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize:20,color: Colors.white,),),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize:15),
          tabs: [
            const Tab(text: "All"),
            ...categories.map((cat) => Tab(text: cat['name'])).toList()
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          
          JobsListWidget(),
          ...categories.map((cat) => JobsListWidget(categoryId: cat['id'])).toList()
        ],
      ),
    );
  }
}

class JobsListWidget extends StatefulWidget {
  final int? categoryId;
  const JobsListWidget({super.key, this.categoryId});

  @override
  State<JobsListWidget> createState() => _JobsListWidgetState();
}

class _JobsListWidgetState extends State<JobsListWidget> {
  List<dynamic> jobs = [];
  List<String> favouriteJobIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadJobs();
    loadFavourites();
  }

  void loadJobs() async {
    final fetchedJobs = await ApiService.fetchJobs(categoryId: widget.categoryId);
    setState(() {
      jobs = fetchedJobs;
      isLoading = false;
    });
  }

  void loadFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favouriteJobs') ?? [];
    setState(() {
      favouriteJobIds = saved;
    });
  }

  void toggleFavourite(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favouriteJobIds.contains(jobId)) {
        favouriteJobIds.remove(jobId);
      } else {
        favouriteJobIds.add(jobId);
      }
      prefs.setStringList('favouriteJobs', favouriteJobIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (jobs.isEmpty) return const Center(child: Text("❌ No jobs found", style: TextStyle(fontSize: 16)));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: jobs.length + (jobs.length ~/ 4), 
      itemBuilder: (context, index) {
        if ((index + 1) % 5 == 0) {
    // Every 5th item show banner
    return FutureBuilder(
      future: AdManager.fetchAds(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final ads = snapshot.data as List<dynamic>;
          final bannerAd = ads.firstWhere(
            (ad) => ad['ad_format'] == 'banner',
            orElse: () => null,
          );
          if (bannerAd != null) {
            return AdManager.loadBanner(
              bannerAd,
              onAdLoaded: () => print("🎯 Banner Ad Loaded"),
              onAdFailed: (error) => print("❌ Banner Ad Failed: $error"),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Adjust index to skip banners
         final jobIndex = index - (index ~/ 5);
         final job = jobs[jobIndex];
        //final job = jobs[index];
        final jobId = job['id'].toString();
        final title = job['title']['rendered'];
        final date = DateFormat('dd MMM yyyy').format(DateTime.parse(job['date']));
        final isFavourite = favouriteJobIds.contains(jobId);

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
           
           
           onTap: () {
  AdHelper.navigateWithInterstitial(
    context: context,
    destination: JobDetailScreen(
      jobId: job['id'],
      jobTitle: job['title']['rendered'],
    ),
    tapInterval: 3, // Show interstitial every 3 taps
  );
},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.date_range, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "Published: $date",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          isFavourite ? Icons.favorite : Icons.favorite_border,
                          color: isFavourite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => toggleFavourite(jobId),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
