import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
// ignore: duplicate_import
import 'package:path_provider/path_provider.dart';

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

  @override
  void initState() {
    super.initState();
    downloadPDF();
  }

  Future<void> downloadPDF() async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${widget.pdf.pdfUrl.split('/').last}';
      await Dio().download(widget.pdf.pdfUrl, filePath);
      setState(() {
        localPath = filePath;
        loading = false;
      });
    } catch (e) {
      print("❌ Download error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pdf.pdfTitle),
        backgroundColor: Colors.deepPurple,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: localPath!,
              swipeHorizontal: true,
              autoSpacing: true,
              pageSnap: true,
            ),
    );
  }
}
