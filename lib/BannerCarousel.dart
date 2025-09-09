import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:rogzarpath/api_service.dart';
import 'package:rogzarpath/constant/model.dart';
import 'package:http/http.dart' as http;

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  


Future<List<BannerModel>> fetchBanners() async {
  try {
    final response = await http.get(
      Uri.parse("${ApiService.appUrl}get_banners.php"),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData["status"] == "success") {
        final List<dynamic> banners = jsonData["banners"];

        return banners.map((item) => BannerModel.fromJson(item)).toList();
      } else {
        throw Exception("API returned error: ${jsonData['status']}");
      }
    } else {
      throw Exception("Failed to load banners. Status: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Failed to load banners: $e");
  }
}



  late Future<List<BannerModel>> futureBanners;

  @override
  void initState() {
    super.initState();
    futureBanners = fetchBanners();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BannerModel>>(
      future: futureBanners,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("❌ Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No banners available"));
        }

        final banners = snapshot.data!;
        return CarouselSlider.builder(
          itemCount: banners.length,
          itemBuilder: (context, index, realIndex) {
            final item = banners[index];
            return Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 🔥 Load image from API
                  Image.network(
                    item.imageUrl,
                    fit: BoxFit.fill,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 50),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          options: CarouselOptions(
            height: 240,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.98,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}
