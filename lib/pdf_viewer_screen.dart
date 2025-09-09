import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rogzarpath/constant/AppConstant.dart';
import 'package:rogzarpath/constant/model.dart';

class PDFViewerScreen extends StatefulWidget {
  final SyllabusPDF pdf;

  const PDFViewerScreen({super.key, required this.pdf});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? localPath;
  bool loading = true;
  String? errorMessage;

  int totalPages = 0;
  int currentPage = 0;
  late PDFViewController _pdfViewController;

  @override
  void initState() {
    super.initState();
    downloadPDF();
  }

  Future<void> downloadPDF() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${widget.pdf.pdfUrl.split('/').last}';

      // If file already exists locally, skip download
      if (await File(filePath).exists()) {
        setState(() {
          localPath = filePath;
          loading = false;
        });
        return;
      }

      // Download PDF
      await Dio().download(widget.pdf.pdfUrl, filePath);

      setState(() {
        localPath = filePath;
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "❌ Failed to load PDF.\nPlease check your connection or try again.";
        loading = false;
      });
      debugPrint("Download error: $e");
    }
  }

  Future<void> saveToRozgarpath() async {
  try {
    if (localPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF not loaded yet!")),
      );
      return;
    }

    // Create "Rozgarpath" folder inside /storage/emulated/0/Download
    final downloadsDir = Directory('/storage/emulated/0/Download/Rozgarpath');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    final fileName = widget.pdf.pdfUrl.split('/').last;
    final newPath = '${downloadsDir.path}/$fileName';

    await File(localPath!).copy(newPath);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Saved in Download/Rozgarpath: $fileName")),
    );
  } catch (e) {
    debugPrint("Save error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ Failed to save PDF")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
   
   return Scaffold(
  appBar: AppBar(
    iconTheme: const IconThemeData(color: Colors.white),
    title: Text(
      widget.pdf.pdfTitle,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
    backgroundColor: MyColors.appbar,
    actions: [
      if (localPath != null)
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          tooltip: "Reload PDF",
          onPressed: downloadPDF,
        ),
    ],
  ),
  body: loading
      ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
      : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: MyColors.appbar),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text("Retry", style: TextStyle(color: Colors.white)),
                    onPressed: downloadPDF,
                  )
                ],
              ),
            )
          : Stack(
              children: [
                PDFView(
                  filePath: localPath!,
                  swipeHorizontal: true,
                  autoSpacing: true,
                  pageSnap: true,
                  enableSwipe: true,
                  defaultPage: currentPage,
                  onRender: (pages) {
                    setState(() {
                      totalPages = pages ?? 0;
                    });
                  },
                  onViewCreated: (controller) {
                    _pdfViewController = controller;
                  },
                  onPageChanged: (page, _) {
                    setState(() {
                      currentPage = page ?? 0;
                    });
                  },
                  onError: (error) {
                    setState(() {
                      errorMessage = "❌ Error loading PDF: $error";
                    });
                  },
                ),
                if (totalPages > 0)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Page ${currentPage + 1} of $totalPages",
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  )
              ],
            ),
  floatingActionButton: localPath != null
      ? FloatingActionButton(
          backgroundColor: MyColors.appbar,
          onPressed: saveToRozgarpath,
          child: const Icon(Icons.download, color: Colors.white),
        )
      : null,
);




  }
}
