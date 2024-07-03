import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ip_camera_streaming_app/utils/constants.dart';
import 'package:media_kit/media_kit.dart';
import 'screens/video_grid_screen.dart';
import 'services/mqtt_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  showNotification(message.notification?.title, message.notification?.body);
  if (kDebugMode) {
    print('Handling a background message: ${message.messageId}');
  }
}

void showNotification(String? title, String? body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MediaKit.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  final mqttService = MqttService(mqttServer,
      mqttClientId); // Testing MQTT server IP address: '192.168.1.15', 'flutter_client'
  try {
    await mqttService.connect();
    mqttService.subscribe(mqttTopic); //topic for testing: test/topic
    runApp(MyApp(mqttService: mqttService));
  } catch (e) {
    if (kDebugMode) {
      print('Failed to connect to MQTT server: $e');
    }
    runApp(const MyApp(mqttService: null)); // Pass null if the connection fails
  }
}

class MyApp extends StatelessWidget {
  final MqttService? mqttService;

  const MyApp({super.key, required this.mqttService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Security Camera',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: VideoGridScreen(mqttService: mqttService),
    );
  }
}
