import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import '../main.dart';
import '../widgets/video_card.dart';
import '../services/video_service.dart';
import 'add_stream_screen.dart';
import 'download_stream_screen.dart';
import '../utils/constants.dart';
import '../services/mqtt_service.dart';
import '../widgets/full_screen_alert_dialog.dart';

class VideoGridScreen extends StatefulWidget {
  final MqttService? mqttService;

  const VideoGridScreen({super.key, required this.mqttService});

  @override
  VideoGridScreenState createState() => VideoGridScreenState();
}

class VideoGridScreenState extends State<VideoGridScreen> {
  final List<Map<String, String>> videoData = [
    {
      'url':
          'rtsp://rtspstream:c04c17ddd4efc34ba69c1e7c03c87a2f@zephyr.rtsp.stream/movie',
      'title': 'RTSP Movie'
    },
    {'url': 'rtsp://192.168.1.250/liveRTSP/av4', 'title': 'RTSP Camera'}
  ];

  final TextEditingController _editTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.mqttService != null) {
      widget.mqttService!.updates!.listen(_onMessage);
      if (kDebugMode) {
        print("MQTT service connected and listening for messages");
      }
    } else {
      if (kDebugMode) {
        print("MQTT service not connected");
      }
    }
    _setupFirebaseMessaging();
    if (kDebugMode) {
      print("Initialized VideoGridScreen with ${videoData.length} videos");
    }
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(notification.title ?? ''),
              content: Text(notification.body ?? ''),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> event) {
    final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
    final pt =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    final parts = pt.split(',');
    final msg = parts[0].trim();

    if (parts.length == 3) {
      // Check if the message has the correct format
      // Current format: "Alert Message, Title: <title>, URL: <url>"
      final title = parts[1].trim();
      final url = parts[2].trim();

      // Validate the URL part
      if (Uri.tryParse(url)?.isAbsolute == true) {
        _showFullScreenAlert(msg,
            'New Video Received\nTitle: $title\nThe video is being downloaded.');
        // Automatically start downloading the video
        _downloadStream(url, title);
      } else {
        _showFullScreenAlert(msg, null);
      }
    } else {
      _showFullScreenAlert(msg, null);
    }
    showNotification('Alert', msg);
  }

  void _showFullScreenAlert(String msg, String? additionalMessage) async {
// Variable to control the vibration loop
    bool isAlertOpen = true; // Start the vibration loop
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (await Vibrate.canVibrate && isAlertOpen) {
        Vibrate.vibrate();
      } else {
        timer.cancel();
      }
    });

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenAlertDialog(
            message: msg,
            additionalMessage: additionalMessage,
          ),
        ),
      ).then((_) {
        // Stop the vibration loop when the alert is closed
        isAlertOpen = false;
      });
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

  void _addNewStream(String url, String title) {
    setState(() {
      videoData.add({'url': url, 'title': title});
      if (kDebugMode) {
        print("Added new stream: $title");
      }
    });
  }

  Future _downloadStream(String url, String title) async {
    try {
      final filePath = await downloadVideo(url);
      if (!mounted) return;
      setState(() {
        videoData.add({'url': filePath, 'title': title});
        if (kDebugMode) {
          print("Downloaded stream: $title");
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$failedDownloadError $e')),
      );
    }
  }

  void _deleteStream(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(confirmDeleteLabel),
          content: const Text(confirmDeleteMessage),
          actions: [
            TextButton(
              child: const Text(cancelButtonLabel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(deleteButtonLabel),
              onPressed: () {
                setState(() {
                  videoData.removeAt(index);
                  if (kDebugMode) {
                    print("Deleted stream at index: $index");
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future _showAddStreamDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddStreamScreen(onAddStream: _addNewStream);
      },
    );
  }

  Future _showDownloadStreamDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DownloadStreamScreen(onDownloadStream: _downloadStream);
      },
    );
  }

  Future _showEditTitleDialog(int index) async {
    _editTitleController.text = videoData[index]['title']!;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(editStreamTitleLabel),
          content: TextField(
            controller: _editTitleController,
            decoration: const InputDecoration(
              labelText: titleLabel,
            ),
          ),
          actions: [
            TextButton(
              child: const Text(cancelButtonLabel),
              onPressed: () {
                _editTitleController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(saveButtonLabel),
              onPressed: () {
                final newTitle = _editTitleController.text;
                if (newTitle.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(emptyTitleError)),
                  );
                  return;
                }
                setState(() {
                  videoData[index]['title'] = newTitle;
                  if (kDebugMode) {
                    print("Edited stream title to: $newTitle");
                  }
                });
                _editTitleController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("Building VideoGridScreen with ${videoData.length} videos");
    }
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: const Center(
          child:
              Text('flutter_vlc_player is only supported on Android and iOS'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(paddingSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _showAddStreamDialog,
                  child: const Text(addStreamLabel),
                ),
                const SizedBox(width: paddingSmall),
                ElevatedButton(
                  onPressed: _showDownloadStreamDialog,
                  child: const Text(downloadStreamLabel),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // Number of columns in the grid
                crossAxisSpacing: paddingSmall,
                mainAxisSpacing: paddingSmall,
              ),
              itemCount: videoData.length,
              itemBuilder: (context, index) {
                final video = videoData[index];
                return VideoCard(
                  key: ValueKey(
                      video['url']), // Ensure unique key for each VideoCard
                  title: video['title']!,
                  url: video['url']!,
                  index: index,
                  onDelete: _deleteStream,
                  onEdit: _showEditTitleDialog,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
