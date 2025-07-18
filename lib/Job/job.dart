import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rogzarpath/Job/job_detail_screen.dart';
import 'package:rogzarpath/api_service.dart';
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
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest Govt Jobs'),
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: "All"),
            ...categories.map((cat) => Tab(text: cat['name'])).toList()
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          JobsListWidget(), // All jobs
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
    if (jobs.isEmpty) return const Center(child: Text("No jobs found"));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        final jobId = job['id'].toString();
        final title = job['title']['rendered'];
        final date = DateFormat('dd MMM yyyy').format(DateTime.parse(job['date']));
        final isFavourite = favouriteJobIds.contains(jobId);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text("Published: $date"),
            ),
            trailing: IconButton(
              icon: Icon(
                isFavourite ? Icons.favorite : Icons.favorite_border,
                color: isFavourite ? Colors.red : Colors.grey,
              ),
              onPressed: () => toggleFavourite(jobId),
            ),
            onTap: () {
              print('Job ID: ${job['id']}');

              Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => JobDetailScreen(
      jobId: job['id'],
    jobTitle: job['title']['rendered'],
    ),
  ),
);

              // TODO: Navigate to job details
            },
          ),
        );
      },
    );
  }
}
