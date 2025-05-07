import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shraddha/screens/loginpage/splash_screen.dart';
import 'package:shraddha/utils/api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//Sha 1 debug
// B2:EB:B7:A9:E4:4F:8F:35:4C:10:03:E8:39:5B:53:50:A8:A2:A5:31

//playstore sha1
// E8:F1:56:E2:1A:03:24:F2:AA:A4:C4:5D:CF:BD:57:B4:7E:C7:A0:6F


//release
// B9:DB:F5:CA:95:1C:6D:6C:D1:12:FD:F2:AE:B0:8A:09:7A:3E:FD:10



final SupabaseService _supabaseService = SupabaseService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized before async operations

  // Initialize Firebase
  await Firebase.initializeApp();
  print("🔥 Firebase Initialized Successfully!");

  // Initialize Supabase
  await Supabase.initialize(
    // url: 'https://pxuddyzwjfkghhejsqqv.supabase.co',
    url : 'https://xdkhnyrjdmxeyppqqnym.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhka2hueXJqZG14ZXlwcHFxbnltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwODc5ODUsImV4cCI6MjA1OTY2Mzk4NX0.Nofj-eDByJo88SEK7BXc4oJdadF4NxMziWZLW64JyiU',
    // anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4dWRkeXp3amZrZ2hoZWpzcXF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA1NDYyNzAsImV4cCI6MjA1NjEyMjI3MH0.zKBDHGjsaKXt6je1Cyd8twcTxm6rVz2UYsdt_jNdkbU', // Replace with your Supabase Anon Key
  );

  // Register background notification handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Get FCM token
  await getFCMToken();

  runApp(MyApp());
}

// Fetch and print the Firebase Cloud Messaging (FCM) token
Future<void> getFCMToken() async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request notification permissions
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ Notification permission granted");


      // Get the FCM token
      String? token = await messaging.getToken();
      print("📱 Firebase Device Token: $token");
      if(token != null)
      final fetchedPleas = await _supabaseService.saveFcmToken(token); // Call your function

      print("save successfully");

      // TODO: Send this token to your backend for push notifications
    } else {
      print("❌ Notification permission denied");
    }
  } catch (e) {
    print("❌ Error fetching FCM token: $e");
  }
}

// Background notification handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔔 Background Notification: ${message.notification?.title}");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login UI',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF7E57C2), // Purple Theme
        scaffoldBackgroundColor: Color(0xFFF5F0FF), // Light Lavender Background
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF4A148C)), // Deep Purple Text
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF7E57C2),
        scaffoldBackgroundColor: Color(0xFF121212),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
        ),
      ),
      themeMode: ThemeMode.system, // Auto switch between light & dark
      home: SplashScreen(),
    );
  }
}





// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:shraddha/screens/home_screen.dart';
// import 'package:shraddha/screens/login_page.dart';
// import 'package:shraddha/screens/loginpage/splash_screen.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized before async operations
//
//   // Initialize Firebase
//   await Firebase.initializeApp();
//   print("🔥 Firebase Initialized Successfully!");
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   await Supabase.initialize(
//     url: 'https://pxuddyzwjfkghhejsqqv.supabase.co',// Replace with your Supabase URL
//     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4dWRkeXp3amZrZ2hoZWpzcXF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA1NDYyNzAsImV4cCI6MjA1NjEyMjI3MH0.zKBDHGjsaKXt6je1Cyd8twcTxm6rVz2UYsdt_jNdkbU', // Replace with your Supabase Anon Key
//   );
//
//   runApp(MyApp());
// }
//
// // Background notification handler
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("🔔 Background Notification: ${message.notification?.title}");
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Login UI',
//       theme: ThemeData(
//         brightness: Brightness.light,
//         primaryColor: Color(0xFF7E57C2), // Purple Theme
//         scaffoldBackgroundColor: Color(0xFFF5F0FF), // Light Lavender Background
//         textTheme: TextTheme(
//           bodyLarge: TextStyle(color: Color(0xFF4A148C)), // Deep Purple Text
//         ),
//       ),
//       darkTheme: ThemeData(
//         brightness: Brightness.dark,
//         primaryColor: Color(0xFF7E57C2),
//         scaffoldBackgroundColor: Color(0xFF121212),
//         textTheme: TextTheme(
//           bodyLarge: TextStyle(color: Colors.white),
//         ),
//       ),
//       themeMode: ThemeMode.system, // Auto switch between light & dark
//       home: SplashScreen(),
//     );
//   }
// }