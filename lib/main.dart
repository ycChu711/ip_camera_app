import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ip_camera_streaming_app/utils/constants.dart';
import 'package:media_kit/media_kit.dart';
import 'package:uuid/uuid.dart';
import 'screens/video_grid_screen.dart';
import 'services/mqtt_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// firebase messaging background handler
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
    // todo: change channel id, name, description
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
  await Firebase.initializeApp(); // Initialize Firebase
  MediaKit.ensureInitialized(); // Initialize MediaKit

  FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler); // Initialize Firebase Messaging

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // todo: change icon
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
  await flutterLocalNotificationsPlugin.initialize(
      initializationSettings); // Initialize Flutter Local Notifications

  const uuid = Uuid();
  final mqttClientId = uuid.v4(); // Generate a unique clientId

  final mqttService = MqttService(mqttServer,
      mqttClientId); // Initialize MQTT Service with server and client id
  try {
    await mqttService.connect();
    mqttService.subscribe(mqttTopic); // Subscribe to MQTT topic
    runApp(MyApp(
        mqttService:
            mqttService)); // Pass the MQTT service if the connection is successful
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
      title: 'Security Camera', // App title
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: VideoGridScreen(mqttService: mqttService),
    );
  }
}
