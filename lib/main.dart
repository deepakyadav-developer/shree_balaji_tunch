import 'dart:async';
import 'dart:io' as a;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:shreebalaji_tounch/screens/auth/login.dart';
import 'package:shreebalaji_tounch/screens/base/splash_screens.dart';
import 'package:shreebalaji_tounch/screens/register.dart';
import 'package:shreebalaji_tounch/widgets/local_notidicationserviecs.dart';
import 'package:shreebalaji_tounch/widgets/notification_services.dart';
import 'package:shreebalaji_tounch/config/translations.dart';
import 'package:shreebalaji_tounch/controllers/language_controller.dart';
import 'package:shreebalaji_tounch/config/bindings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'constant/APP_INFO.dart';

var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
FlutterTts flutterTts = FlutterTts();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✓ Firebase initialized successfully');
  } catch (e) {
    print('✗ Error initializing Firebase: $e');
  }

  try {
    // Initialize notifications
    await createNotificationChannel();
    print('✓ Notification channel created successfully');
  } catch (e) {
    print('✗ Error creating notification channel: $e');
  }

  try {
    await setFirebase();
    print('✓ Firebase messaging initialized successfully');
  } catch (e) {
    print('✗ Error setting up Firebase messaging: $e');
  }

  try {
    LocalNotificationService.initialize();
    print('✓ Local notification service initialized successfully');
  } catch (e) {
    print('✗ Error initializing local notification service: $e');
  }

  try {
    // Initialize Firebase messaging service
    await FirebaseMessagingService().initialize();
    print('✓ Firebase messaging service initialized successfully');
  } catch (e) {
    print('✗ Error initializing Firebase messaging service: $e');
  }

  try {
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message.data);
      LocalNotificationService.createanddisplaynotification(message);
    });
    print('✓ Message listener set up successfully');
  } catch (e) {
    print('✗ Error setting up message listener: $e');
  }

  try {
    // Initialize language controller
    Get.put(LanguageController()); 
    print('✓ Language controller initialized');
  } catch (e) {
    print('✗ Error initializing language controller: $e');
  }

  // Ensure language is loaded before app starts
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String savedLanguage = prefs.getString('selected_language') ?? 'en_US';

  // Set initial locale
  Locale initialLocale;
  switch (savedLanguage) {
    case 'hi_IN':
      initialLocale = Locale('hi', 'IN');
      break;
    case 'bho_IN':
      initialLocale = Locale('bho', 'IN');
      break;
    default:
      initialLocale = Locale('en', 'US');
  }

  print('✓ Starting app with locale: $initialLocale');
  runApp(MyApp(initialLocale: initialLocale));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;

  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: Locale('en', 'US'),
      initialBinding: InitialBindings(),
      title: 'Shree Balaji Store',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: bgColor,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: bgColor),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: bgColor,
          selectedItemColor: Color(0xffFFD700),
          unselectedItemColor: Colors.white.withValues(alpha: 0.7),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
        ),
      ),
      home: SplashScreen(),
      routes: {
        'register': (context) => MyRegister(),
        'login': (context) => MyLogin(),
      },
    );
  }
}

createNotificationChannel() async {
  try {
    var notificationChannel = FlutterNotificationChannel();
    var result = await notificationChannel.registerNotificationChannel(
      description: 'For Message Notification',
      id: packageName,
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: projectName,
    );
    print('Notification channel created: $result');
  } catch (e) {
    print('Error creating notification channel: $e');
  }
}

Future<void> setFirebase() async {
  try {
    var initializationSettingsAndroid = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    var initializationSettingsIOS = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onSelect(response.payload);
      },
    );

    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    if (a.Platform.isIOS) {
      _firebaseMessaging.subscribeToTopic('ios');
    } else {
      _firebaseMessaging.subscribeToTopic('android');
    }
    if (!a.Platform.isIOS) {
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message.data);
    });
    await _firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      provisional: false,
    );

    _firebaseMessaging.getToken().then((String? token) {
      print("Push Messaging token: $token");
    });
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

Future<void> showNotification(Map<String, dynamic> message) async {
  var data;
  if (a.Platform.isIOS) {
    data = message['notification'] ?? message;
  } else {
    data = message['data'] ?? message;
  }
  print(data);
  String title = "", body = "", sound = "", language = "", voice = "";
  double volume = 1, pitch = 1, srate = 0.7;
  int msgId = 0;
  if (a.Platform.isAndroid) {
    title = data["title"];
    body = data["body"];
    sound = data["music"];
    msgId = int.tryParse(data["msgId"].toString()) ?? 0;
  } else if (a.Platform.isIOS) {
    title = data['aps']['alert']["title"];
    body = data['aps']['alert']["body"];
    sound = data["aps"]['sound'];
    msgId = int.tryParse(data["gcm.notification.msgId"].toString()) ?? 0;
  }

  if (sound == "tts") {
    volume = double.parse(data["volume"]);
    pitch = double.parse(data["pitch"]);
    srate = double.parse(data["srate"]);
    language = data["language"];
    voice = data["voice"];
    flutterTts.setVolume(volume);
    flutterTts.setSpeechRate(srate);
    flutterTts.setPitch(pitch);
    flutterTts.setLanguage(language);
    if (voice.isNotEmpty) {
      flutterTts.setVoice({"name": voice, "locale": language});
    }
    await flutterTts.speak(body);
  }

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    msgId.toString(),
    'VisionDgTech',
    channelDescription: 'VisionDgTech',
    color: Colors.blue.shade800,
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound(sound),
    styleInformation: const BigTextStyleInformation(""),
    priority: Priority.high,
    ticker: 'ticker',
  );
  var iOSPlatformChannelSpecifics = DarwinNotificationDetails(
    sound: sound == "notification" || sound == "tts" || sound == "tts2"
        ? '$sound.mp3'
        : sound,
  );
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );
  flutterLocalNotificationsPlugin.show(
    msgId,
    title,
    body,
    platformChannelSpecifics,
    payload: body,
  );
  return Future<void>.value();
}

Future onSelect(String? data) async {
  print("onSelectNotification $data");
}

@pragma('vm:entry-point')
Future<void> myBackgroundMessageHandler(RemoteMessage rMessage) async {
  Map<String, dynamic> message = rMessage.data;
  print(message);
  var data = message['data'] ?? message;
  String title = "", body = "", sound = "", language = "", voice = "";
  double volume = 1, pitch = 1, srate = 0.7;
  int msgId = 0;
  print("Background function triggered");
  if (a.Platform.isAndroid) {
    title = data["title"];
    body = data["body"];
    sound = data["music"];
    msgId = int.tryParse(data["msgId"].toString()) ?? 0;
  } else if (a.Platform.isIOS) {
    title = data['aps']['alert']["title"];
    body = data['aps']['alert']["body"];
    sound = data["aps"]['sound'];
    msgId = int.tryParse(data["gcm.notification.msgId"].toString()) ?? 0;
  }
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    msgId.toString(),
    'VisionDGTech',
    channelDescription: 'VisionDGTech',
    importance: Importance.max,
    priority: Priority.high,
    enableVibration: true,
    playSound: true,
    sound: RawResourceAndroidNotificationSound(sound),
    styleInformation: const BigTextStyleInformation(""),
    enableLights: true,
    ticker: 'ticker',
  );

  var iOSPlatformChannelSpecifics = DarwinNotificationDetails(
    sound: sound == "notification" || sound == "tts" || sound == "tts2"
        ? '$sound.mp3'
        : sound,
  );

  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    msgId,
    title,
    body,
    platformChannelSpecifics,
    payload: body,
  );

  if (sound == "tts") {
    volume = double.parse(data["volume"]);
    pitch = double.parse(data["pitch"]);
    srate = double.parse(data["srate"]);
    language = data["language"];
    voice = data["voice"];
    flutterTts.setVolume(volume);
    flutterTts.setSpeechRate(srate);
    flutterTts.setPitch(pitch);
    flutterTts.setLanguage(language);
    if (voice.isNotEmpty) {
      flutterTts.setVoice({"name": voice, "locale": language});
    }
    await flutterTts.speak(body);
  }
}
