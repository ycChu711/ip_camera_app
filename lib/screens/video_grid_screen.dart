import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/video_card.dart';
import '../services/video_service.dart';
import 'add_stream_screen.dart';
import 'download_stream_screen.dart';
import '../utils/constants.dart';

class VideoGridScreen extends StatefulWidget {
  const VideoGridScreen({super.key});

  @override
  VideoGridScreenState createState() => VideoGridScreenState();
}

class VideoGridScreenState extends State<VideoGridScreen> {
  final List<Map<String, String>> videoData = [
    {
      'url':
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      'title': 'Camera 1'
    },
    {
      'url': 'https://media.w3.org/2010/05/sintel/trailer.mp4',
      'title': 'Camera 2'
    },
    {
      'url':
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      'title': 'Camera 3'
    },
    {
      'url': 'https://media.w3.org/2010/05/sintel/trailer.mp4',
      'title': 'Camera 4'
    },
    {
      'url':
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      'title': 'Camera 5'
    },
  ];

  final TextEditingController _editTitleController = TextEditingController();

  void _addNewStream(String url, String title) {
    setState(() {
      videoData.add({'url': url, 'title': title});
    });
  }

  Future<void> _downloadStream(String url, String title) async {
    try {
      final filePath = await downloadVideo(url);
      if (!mounted) return; // <-- Added mounted check
      setState(() {
        videoData.add({'url': filePath, 'title': title});
      });
    } catch (e) {
      if (!mounted) return; // <-- Added mounted check
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
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddStreamDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AddStreamScreen(onAddStream: _addNewStream);
      },
    );
  }

  Future<void> _showDownloadStreamDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DownloadStreamScreen(onDownloadStream: _downloadStream);
      },
    );
  }

  Future<void> _showEditTitleDialog(int index) async {
    _editTitleController.text = videoData[index]['title']!;
    return showDialog<void>(
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
          actions: <Widget>[
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
                crossAxisCount: 2, // Number of columns in the grid
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
