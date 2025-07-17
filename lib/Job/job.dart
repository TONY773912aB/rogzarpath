// lib/screens/jobs_screen.dart
import 'package:flutter/material.dart';
import 'package:rogzarpath/api_service.dart';

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

    return DefaultTabController(
      length: categories.length + 1,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            'Govt Job Updates',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          bottom: TabBar(
            controller: tabController,
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              const Tab(text: "All"),
              ...categories.map((cat) => Tab(text: cat['name'])).toList(),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            const JobsListWidget(), // All jobs
            ...categories.map((cat) => JobsListWidget(categoryId: cat['id'])).toList(),
          ],
        ),
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadJobs();
  }

  void loadJobs() async {
    final fetchedJobs = await ApiService.fetchJobs(categoryId: widget.categoryId);
    setState(() {
      jobs = fetchedJobs;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (jobs.isEmpty) {
      return const Center(
        child: Text("No jobs found", style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        final title = job['title']['rendered'];
        final date = job['date'];

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(date, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              // TODO: Navigate to Job Detail Page
            },
          ),
        );
      },
    );
  }
}
