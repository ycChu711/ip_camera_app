import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'dart:io';

class VideoCard extends StatefulWidget {
  final String title;
  final String url;
  final int index;
  final Function(int) onDelete;
  final Function(int) onEdit;

  const VideoCard({
    super.key,
    required this.title,
    required this.url,
    required this.index,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  VideoCardState createState() => VideoCardState();
}

class VideoCardState extends State<VideoCard> {
  late Player _player;
  late VideoController _controller;
  bool _isFile = false;
  //double _sliderValue = 0.0;
  //double _maxValue = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeController(widget.url);
  }

  void _initializeController(String url) {
    _player = Player();
    _controller = VideoController(_player);

    // //Add listeners to update the slider value and max value
    // _player.stream.position.listen((position) {
    //   if (mounted) {
    //     setState(() {
    //       _sliderValue = position.inSeconds.toDouble();
    //     });
    //   }
    // });

    // _player.stream.duration.listen((duration) {
    //   if (mounted) {
    //     setState(() {
    //       _maxValue = duration.inSeconds.toDouble();
    //     });
    //   }
    // });

    _player.stream.error.listen((error) {
      if (kDebugMode) {
        print('Error playing video: $error');
      }
    });

    _isFile = File(url).existsSync();
    _player.open(Media(_isFile ? File(url).path : url));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _player.dispose();
      _initializeController(widget.url);
    }
  }

  void _seekTo(double seconds) {
    _player.seek(Duration(seconds: seconds.toInt()));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (String result) {
                    if (result == 'edit') {
                      widget.onEdit(widget.index);
                    } else if (result == 'delete') {
                      widget.onDelete(widget.index);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Stack(
                children: [
                  Video(
                    controller: _controller,
                    fit: BoxFit.contain,
                  ),
                  Center(
                    child: StreamBuilder<bool>(
                      stream: _player.stream.playing,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data ?? false;
                        return isPlaying
                            ? const SizedBox.shrink()
                            : ElevatedButton(
                                onPressed: () {
                                  _player.play();
                                  if (kDebugMode) {
                                    print('Play button pressed, video playing');
                                  }
                                },
                                child: const Icon(Icons.play_arrow),
                              );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_player.state.playing) {
                        _player.pause();
                        if (kDebugMode) {
                          print('Video paused');
                        }
                      } else {
                        _player.play();
                        if (kDebugMode) {
                          print('Video playing');
                        }
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
            // // Uncomment the following code to add a slider to seek the video
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 8.0),
            //   child: SizedBox(
            //     height: 30,
            //     child: Slider(
            //       value: _sliderValue,
            //       min: 0.0,
            //       max: _maxValue > 0 ? _maxValue : 1.0,
            //       onChanged: (value) {
            //         setState(() {
            //           _sliderValue = value;
            //         });
            //         _seekTo(value);
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
