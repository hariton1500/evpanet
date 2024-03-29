import 'dart:convert';
import 'dart:io';

import 'package:evpanet/Models/app.dart';
import 'package:evpanet/Pages/startpage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/StartScreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('[Handling a background message]');
  print(message.data);
  SharedPreferences preferences = await SharedPreferences.getInstance();
  List<String> messagesJSON = [];
  messagesJSON.addAll(preferences.getStringList('messages') ?? []);
  print('loaded ${messagesJSON.length} messages');
  messagesJSON.add(jsonEncode(message.data));
  preferences.setStringList('messages', messagesJSON);
  print('stored ${messagesJSON.length} messages');
  //print(messagesJSON);
}

/// Create a AndroidNotificationChannel for heads up notifications
AndroidNotificationChannel? channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

//String _token = '';
AppData appData = AppData();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print('[main] Firebase initialized');
  HttpOverrides.global = new MyHttpOverrides();
  appData.token = await FirebaseMessaging.instance.getToken() ?? '';
  print('[getToken] token = ${appData.token}');
  /*
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString('deviceId', _token);
  */
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((event) async {
    print('onMessage: $event');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> messagesJSON = [];
    messagesJSON.addAll(preferences.getStringList('messages') ?? []);
    messagesJSON.add(jsonEncode(event.data));
    preferences.setStringList('messages', messagesJSON);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((event) {
    print('onMessageOpenedApp: $event');
  });
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel!);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  //runApp(MyApp());
  runApp(NewApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Мой EvpaNet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartScreen(token: appData.token),
    );
  }
}

class NewApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Мой EvpaNet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartPage(appData: appData),
    );
  }
}
