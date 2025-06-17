import 'dart:async';
import 'dart:io' as a;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get.dart';
import 'package:loginuicolors/screens/auth/login.dart';
import 'package:loginuicolors/screens/base/splash_screens.dart';
import 'package:loginuicolors/screens/register.dart';
import 'package:loginuicolors/widgets/local_notidicationserviecs.dart';
import 'package:loginuicolors/widgets/notification_services.dart';
import 'package:loginuicolors/config/translations.dart';
import 'package:loginuicolors/controllers/language_controller.dart';
import 'package:loginuicolors/config/bindings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constant/APP_INFO.dart';

var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
FlutterTts flutterTts = FlutterTts();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(GetMaterialApp(

// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize notifications
  await createNotificationChannel();
  setFirebase();
  LocalNotificationService.initialize();

  // Initialize Firebase messaging service
  await FirebaseMessagingService().initialize();

  // Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showNotification(message.data);
    LocalNotificationService.createanddisplaynotification(message);
  });

  // Initialize language controller
  final languageController = Get.put(LanguageController());

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

  runApp(MyApp(initialLocale: initialLocale));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;

  const MyApp({Key key, this.initialLocale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: Locale('en', 'US'),
      initialBinding: InitialBindings(),
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: bgColor,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(color: bgColor),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: bgColor,
          selectedItemColor: Color(0xffFFD700),
          unselectedItemColor: Colors.white.withOpacity(0.7),
        ),
        textTheme: TextTheme(
          bodyText1: TextStyle(color: textColor),
          bodyText2: TextStyle(color: textColor),
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
    var result = await FlutterNotificationChannel.registerNotificationChannel(
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

void setFirebase() async {
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('app_icon');

  var initializationSettingsIOS = const IOSInitializationSettings();

  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: onSelect,
  );

  final Completer<Map<String, dynamic>> completer =
      Completer<Map<String, dynamic>>();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  if (a.Platform.isIOS) {
    _firebaseMessaging.subscribeToTopic('ios');
  } else {
    _firebaseMessaging.subscribeToTopic('android');
  }
  FirebaseMessaging.onBackgroundMessage(
      a.Platform.isIOS ? null : myBackgroundMessageHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showNotification(message.data);
  });
  await _firebaseMessaging.requestPermission(
      sound: true, badge: true, alert: true, provisional: false);

  _firebaseMessaging.getToken().then((String token) {
    print("Push Messaging token: $token");
  });
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
    flutterTts.setVoice(voice);
    await flutterTts.speak(body);
  }

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    msgId.toString(),
    'VisionDgTech',
    color: Colors.blue.shade800,
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound(sound),
    styleInformation: const BigTextStyleInformation(""),
    priority: Priority.high,
    ticker: 'ticker',
  );
  var iOSPlatformChannelSpecifics = IOSNotificationDetails(sound: sound);
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  flutterLocalNotificationsPlugin
      .show(msgId, title, body, platformChannelSpecifics, payload: body);
  return Future<void>.value();
}

Future onSelect(String data) async {
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
      AndroidNotificationDetails(msgId.toString(), 'VisionDGTech',
          channelDescription: 'VisionDGTech',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(sound),
          styleInformation: const BigTextStyleInformation(""),
          enableLights: true,
          ticker: 'ticker');

  var iOSPlatformChannelSpecifics = IOSNotificationDetails(sound: sound);

  NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin
      .show(msgId, title, body, platformChannelSpecifics, payload: body);

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
    flutterTts.setVoice(voice);
    await flutterTts.speak(body);
  }
}
