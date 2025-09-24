import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rogzarpath/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';

// Global notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Background handler (when app is in background/terminated)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showNotification(message);
}

Future<void> _showNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification == null) return;

  String? imageUrl = message.notification?.android?.imageUrl ?? message.data['image'];
  BigPictureStyleInformation? styleInformation;

  if (imageUrl != null && imageUrl.isNotEmpty) {
    try {
      // Download the image
      final response = await http.get(Uri.parse(imageUrl));
      final documentDirectory = await getApplicationDocumentsDirectory();
      final filePath = '${documentDirectory.path}/notif_image.jpg';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      styleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(filePath),
        contentTitle: notification.title,
        summaryText: notification.body,
      );
    } catch (e) {
      print("❌ Error loading image: $e");
    }
  }

  final androidDetails = AndroidNotificationDetails(
    'default_channel',
    'General Notifications',
    channelDescription: 'This channel is for general notifications',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@drawable/icon',
    largeIcon: const DrawableResourceAndroidBitmap('@drawable/logo2'),
    styleInformation: styleInformation,
  );

  final details = NotificationDetails(android: androidDetails);

  flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification.title,
    notification.body,
    details,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   await MobileAds.instance.initialize();
    FacebookAudienceNetwork.init();

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize local notifications
  const androidInit = AndroidInitializationSettings('@drawable/icon');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission (iOS)
    await messaging.requestPermission();

    // Get token
    fcmToken = await messaging.getToken();
    print("✅ FCM Token: $fcmToken");

    // Subscribe to topic (so all users get app-wide notifications)
    await FirebaseMessaging.instance.subscribeToTopic("all");

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // When app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("📩 Opened from terminated: ${message.data}");
      }
    });

    // When app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("📩 Opened from background: ${message.data}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rozgarpath',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
