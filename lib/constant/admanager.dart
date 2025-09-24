import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:rogzarpath/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdManager {
  // Fetch active ads from admin panel API

   static Future<List<dynamic>> fetchAds() async {
    try {
      final response = await http.get(Uri.parse("${ApiService.appUrl}get_ads.php"));

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);

        if (jsonBody["success"] == true && jsonBody["data"] != null) {
          return jsonBody["data"] as List<dynamic>;
        } else {
          throw Exception("❌ Invalid API response format");
        }
      } else {
        throw Exception("❌ Failed to fetch ads: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error in fetchAds: $e");
      return [];
    }
  }


 
// Load banner ad
static Widget loadBanner(
  Map ad, {
  VoidCallback? onAdLoaded,
  Function(LoadAdError)? onAdFailed,
}) {
  if (ad["ad_network"] == "admob") {
    BannerAd bannerAd = BannerAd(
      adUnitId: ad["placement_id"] ??"ca-app-pub-3940256099942544/6300978111",
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print("✅ AdMob Banner Loaded");
          if (onAdLoaded != null) onAdLoaded();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print("❌ AdMob Banner Failed: $error");
          ad.dispose();
          if (onAdFailed != null) onAdFailed(error);
        },
      ),
    );
    bannerAd.load();

    return Container(
      margin: EdgeInsets.only(bottom: 5),
      alignment: Alignment.center,
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  } else if (ad["ad_network"] == "facebook") {
    return FacebookBannerAd(
      placementId: ad["placement_id"] ?? "IMG_16_9_APP_INSTALL#YOUR_PLACEMENT_ID",
      bannerSize: BannerSize.STANDARD,
      listener: (result, value) {
        print("📢 Facebook Banner: $result --> $value");
        if (result == BannerAdResult.LOADED && onAdLoaded != null) {
          onAdLoaded();
        } else if (result == BannerAdResult.ERROR && onAdFailed != null) {
          onAdFailed(value);
        }
      },
      keepAlive: true,
    );
  }
  return const SizedBox.shrink();
}


  // Load interstitial ad
  static void loadInterstitial(Map ad, {Function? onAdClosed}) {
    if (ad["ad_network"] == "admob") {
      InterstitialAd.load(
        adUnitId: ad["placement_id"],
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd interstitialAd) {
            interstitialAd.show();
            interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                interstitialAd.dispose();
                if (onAdClosed != null) onAdClosed();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                interstitialAd.dispose();
                if (onAdClosed != null) onAdClosed();
              },
            );
          },
          onAdFailedToLoad: (error) {
            print("AdMob Interstitial failed to load: $error");
          },
        ),
      );
    } else if (ad["ad_network"] == "facebook") {
      FacebookInterstitialAd.loadInterstitialAd(
        placementId: ad["placement_id"], // demo placement ID for testing
        listener: (result, value) {
          if (result == InterstitialAdResult.LOADED) {
            FacebookInterstitialAd.showInterstitialAd();
          } else if (result == InterstitialAdResult.DISMISSED) {
            if (onAdClosed != null) onAdClosed();
          }
        },
      );
    }
  }



  // Load rewarded ad
  static void loadRewarded(Map ad, {Function? onRewarded}) {
    if (ad["ad_network"] == "admob") {
      RewardedAd.load(
        adUnitId: ad["placement_id"],
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd rewardedAd) {
            rewardedAd.show(onUserEarnedReward: (ad, reward) {
              if (onRewarded != null) onRewarded();
            });
            rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                rewardedAd.dispose();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                rewardedAd.dispose();
              },
            );
          },
          onAdFailedToLoad: (error) {
            print("AdMob Rewarded failed to load: $error");
          },
        ),
      );
    } else if (ad["ad_network"] == "facebook") {
      FacebookRewardedVideoAd.loadRewardedVideoAd(
        placementId: ad["placement_id"], // demo placement ID for testing
        listener: (result, value) {
          if (result == RewardedVideoAdResult.VIDEO_COMPLETE ||
              result == RewardedVideoAdResult.VIDEO_CLOSED) {
            if (onRewarded != null) onRewarded();
          }
        },
      );
    }
  }

  
  // Load native ad
static Widget loadNative(Map ad, {double? height}) {
  final adHeight = height ?? 120.0; // default height

  if (ad["ad_network"] == "admob") {
    NativeAd nativeAd = NativeAd(
      adUnitId: ad["placement_id"] ?? "ca-app-pub-3940256099942544/2247696110", // fallback test ID
      factoryId: 'listTile', // must be registered in main.dart
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) => print("✅ AdMob Native Loaded"),
        onAdFailedToLoad: (ad, error) {
          print("❌ AdMob Native Failed: $error");
          ad.dispose();
        },
      ),
    );
    nativeAd.load();
    return Container(
      width: double.infinity,
      height: adHeight,
      alignment: Alignment.center,
      child: AdWidget(ad: nativeAd),
    );
  } 
  else if (ad["ad_network"] == "facebook") {
    return SizedBox(
      width: double.infinity,
      height: adHeight,
      child: FacebookNativeAd(
        placementId: ad["placement_id"] ?? "IMG_16_9_APP_INSTALL#YOUR_PLACEMENT_ID",
        adType: NativeAdType.NATIVE_AD,
        width: double.infinity,
        height: adHeight,
        backgroundColor: Colors.white,
        titleColor: Colors.black,
        descriptionColor: Colors.black87,
        buttonColor: Colors.blue,
        buttonTitleColor: Colors.white,
        buttonBorderColor: Colors.blue,
        keepAlive: true,
        listener: (result, value) {
          print("Facebook Native: $result --> $value");
        },
      ),
    );
  }

  return const SizedBox.shrink();
}


}


class AdHelper {
  /// Navigate with interstitial ad every [tapInterval] taps
  static Future<void> navigateWithInterstitial({
    required BuildContext context,
    required Widget destination,
    int tapInterval = 3,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Increment tap count
    int tapCount = prefs.getInt('tapCount') ?? 0;
    tapCount++;
    prefs.setInt('tapCount', tapCount);

    // Fetch ads from backend
    final ads = await AdManager.fetchAds();
    final interstitialAd = ads.firstWhere(
      (ad) => ad['ad_format'] == 'interstitial',
      orElse: () => null,
    );

    if (tapCount % tapInterval == 0 && interstitialAd != null) {
      // Show interstitial ad
      AdManager.loadInterstitial(interstitialAd, onAdClosed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      });
    } else {
      // Navigate immediately
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    }
  }
}
