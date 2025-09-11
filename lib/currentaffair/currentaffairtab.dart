import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:rogzarpath/api_service.dart';
import 'package:rogzarpath/constant/AppConstant.dart';
import 'package:rogzarpath/daily_news_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeTabs extends StatefulWidget {
  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Current Affairs',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: MyColors.appbar,
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          tabs: const [
            Tab( text: 'Daily'),
            Tab( text: 'Weekly PDFs'),
            Tab( text: 'Monthly PDFs'),
            Tab( text: 'Articles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          DailyTab(),
          PdfListTab(endpoint: 'weekly_list.php', uploadBase: 'uploads/weekly/'),
          PdfListTab(endpoint: 'monthly_list.php', uploadBase: 'monthly/'),
          DailyNewsScreen()
        ],
      ),
    );
  }
}

// ---------------- DAILY TAB ----------------
class DailyTab extends StatefulWidget {
  @override
  State<DailyTab> createState() => _DailyTabState();
}

class _DailyTabState extends State<DailyTab> {
  List dates = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchDates();
  }

  Future<void> fetchDates() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final resp = await http.get(Uri.parse('${ApiService.appUrl}daily_list.php'));
      if (resp.statusCode == 200) {
        final obj = jsonDecode(resp.body);
        if (obj['success']) {
          setState(() => dates = obj['data']);
        } else {
          error = obj['message'] ?? 'Failed to load data';
        }
      } else {
        error = 'Server error: ${resp.statusCode}';
      }
    } catch (e) {
      error = 'Could not connect to server';
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error.isNotEmpty) {
      return Center(child: Text(error, style: const TextStyle(color: Colors.red)));
    }
    if (dates.isEmpty) {
      return const Center(child: Text('No current affairs found.'));
    }

    return RefreshIndicator(
      onRefresh: fetchDates,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: dates.length,
        itemBuilder: (c, i) {
          final d = dates[i];
          final dateStr = d['affair_date'];
          final formatted = DateFormat.yMMMMd().format(DateTime.parse(dateStr));
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DailyDetailScreen(date: dateStr)),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5, offset: const Offset(0, 3)),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                title: Text(
                  d['title'] ?? formatted,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(formatted, style: GoogleFonts.poppins(color: Colors.white70)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------- DAILY DETAIL ----------------
class DailyDetailScreen extends StatefulWidget {
  final String date;
  DailyDetailScreen({required this.date});

  @override
  State<DailyDetailScreen> createState() => _DailyDetailScreenState();
}

class _DailyDetailScreenState extends State<DailyDetailScreen> {
  bool loading = true;
  String error = '';
  Map? data;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final resp = await http.get(Uri.parse('${ApiService.appUrl}daily_detail.php?date=${widget.date}'));
      if (resp.statusCode == 200) {
        final obj = jsonDecode(resp.body);
        if (obj['success']) {
          data = obj['data'];
        } else {
          error = obj['message'] ?? 'No details found';
        }
      } else {
        error = 'Server error';
      }
    } catch (e) {
      error = 'Could not fetch details';
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    if (error.isNotEmpty) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(error, style: const TextStyle(color: Colors.red))));
    }
    if (data == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('No data')));
    }
    
 final rawBullets = data!['bullets'];
List<dynamic> bullets = [];
if (rawBullets is List) {
  bullets = rawBullets;
} else if (rawBullets is Map) {
  bullets = rawBullets.values.toList();
} else if (rawBullets != null) {
  bullets = [rawBullets.toString()];
}
    final formatted = DateFormat.yMMMMd().format(DateTime.parse(data!['affair_date']));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: MyColors.appbar,
         iconTheme: IconThemeData(
    color: Colors.white, // Change this to your desired color
  ),
        title: Text(data!['title'] ?? formatted,style: GoogleFonts.poppins(color:Colors.white, fontSize:16),)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.separated(
          itemCount: bullets.length,
          separatorBuilder: (_, i) => const SizedBox(height: 8),
          itemBuilder: (c, i) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text('${i + 1}', style: const TextStyle(color: Colors.white)),
                ),
                title: Text(bullets[i].toString(), style: GoogleFonts.poppins()),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------- PDF LIST TAB ----------------
class PdfListTab extends StatefulWidget {
  final String endpoint;
  final String uploadBase;

  PdfListTab({required this.endpoint, required this.uploadBase});

  @override
  State<PdfListTab> createState() => _PdfListTabState();
}

class _PdfListTabState extends State<PdfListTab> {
  List items = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchList();
  }

  Future<void> fetchList() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final resp = await http.get(Uri.parse('${ApiService.appUrl}${widget.endpoint}'));
      if (resp.statusCode == 200) {
        final obj = jsonDecode(resp.body);
        if (obj['success']) {
          setState(() => items = obj['data']);
        } else {
          error = obj['message'] ?? 'No PDFs found';
        }
      } else {
        error = 'Server error';
      }
    } catch (e) {
      error = 'Could not fetch PDF list';
    }
    setState(() => loading = false);
  }

  Future<void> downloadAndOpen(String filename) async {
    String basePath = widget.uploadBase;
    if (basePath.endsWith('/')) {
      basePath = basePath.substring(0, basePath.length - 1);
    }
    filename = filename.replaceAll(RegExp(r'^/+'), '');
    final String url = "https://rozgarpathadmin.vacancygyan.in/$basePath/$filename";
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception("Cannot open PDF");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to open PDF")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error.isNotEmpty) {
      return Center(child: Text(error, style: const TextStyle(color: Colors.red)));
    }
    if (items.isEmpty) {
      return const Center(child: Text('No PDFs uploaded yet.'));
    }

    return RefreshIndicator(
      onRefresh: fetchList,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (c, i) {
          final it = items[i];
          final title = it['title'] ?? '';
          final file = it['pdf_file'] ?? '';
          final subtitle = it['week_start'] != null
              ? '${it['week_start']} - ${it['week_end'] ?? ''}'
              : (it['month_year'] ?? '');
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
              ],
            ),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
              title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              subtitle: Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey[600])),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => downloadAndOpen(file),
            ),
          );
        },
      ),
    );
  }
}
