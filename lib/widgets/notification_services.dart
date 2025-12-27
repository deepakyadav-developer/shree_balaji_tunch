import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialize Firebase Cloud Messaging
  Future<void> initialize() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // Request permission for receiving push notifications (iOS only)
    await _firebaseMessaging.requestPermission(
        alert: true, badge: true, sound: true);

    // Configure FCM settings
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle incoming message when the app is in the foreground
      print("Foreground Message: $message");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle the tap on the notification when the app is in the background or terminated
      print("Background or Terminated Message: $message");
    });

    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    // Get the FCM token
    String? token = await _firebaseMessaging.getToken();

    if (token != null) {
      pref.setString('fcmToken', token);
    }
    if (kDebugMode) {
      print('this is fcmtoken ===================> $token');
    }
  }

  // Handle background messages
  Future<void> _onBackgroundMessage(RemoteMessage message) async {
    print("Handling background message: $message");
    // You can handle background messages here
  }

  // Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print("Subscribed to topic: $topic");
  }

  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print("Unsubscribed from topic: $topic");
  }
}
