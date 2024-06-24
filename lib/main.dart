import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/video_grid_screen.dart';
import 'services/mqtt_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final mqttService = MqttService('192.168.1.15', 'flutter_client');
  try {
    await mqttService.connect();
    mqttService.subscribe('test/topic');
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
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: VideoGridScreen(mqttService: mqttService),
    );
  }
}
