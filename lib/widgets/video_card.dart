import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
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
  late VlcPlayerController _controller;
  bool _isFile = false;
  double _sliderValue = 0.0;
  double _maxValue = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeController(widget.url);
  }

  void _initializeController(String url) {
    setState(() {
      _isFile = File(url).existsSync();
    });

    _controller = _isFile
        ? VlcPlayerController.file(
            File(url),
            hwAcc: HwAcc.full,
            autoPlay: false,
            options: VlcPlayerOptions(
              advanced: VlcAdvancedOptions([
                VlcAdvancedOptions.networkCaching(3000),
              ]),
            ),
          )
        : VlcPlayerController.network(
            url,
            hwAcc: HwAcc.full,
            autoPlay: false,
            options: VlcPlayerOptions(
              advanced: VlcAdvancedOptions([
                VlcAdvancedOptions.networkCaching(3000),
              ]),
            ),
          );

    _controller.addListener(() {
      if (_controller.value.hasError) {
        if (kDebugMode) {
          print('Error playing video: ${_controller.value.errorDescription}');
        }
      } else {
        if (_controller.value.duration.inSeconds > 0) {
          setState(() {
            _sliderValue = _controller.value.position.inSeconds.toDouble();
            _maxValue = _controller.value.duration.inSeconds.toDouble();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _controller.dispose();
      _initializeController(widget.url);
    }
  }

  void _seekTo(double seconds) {
    _controller.seekTo(Duration(seconds: seconds.toInt()));
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
                  VlcPlayer(
                    controller: _controller,
                    aspectRatio: 16 / 9,
                    placeholder: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  Center(
                    child: ValueListenableBuilder<VlcPlayerValue>(
                      valueListenable: _controller,
                      builder: (context, value, child) {
                        if (value.hasError) {
                          return const Center(
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 32,
                            ),
                          );
                        }
                        return value.isPlaying
                            ? const SizedBox.shrink()
                            : ElevatedButton(
                                onPressed: () {
                                  if (_controller.value.isInitialized) {
                                    setState(() {
                                      _controller.play();
                                      if (kDebugMode) {
                                        print(
                                            'Play button pressed, video playing');
                                      }
                                    });
                                  }
                                },
                                child: const Icon(Icons.play_arrow),
                              );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_controller.value.isInitialized) {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                            if (kDebugMode) {
                              print('Video paused');
                            }
                          } else {
                            _controller.play();
                            if (kDebugMode) {
                              print('Video playing');
                            }
                          }
                        });
                      } else {
                        if (kDebugMode) {
                          print('Controller not initialized');
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                height:
                    30, // Adjust this height to make the progress bar smaller
                child: Slider(
                  value: _sliderValue,
                  min: 0.0,
                  max: _maxValue > 0 ? _maxValue : 1.0,
                  onChanged: (value) {
                    setState(() {
                      _sliderValue = value;
                    });
                    _seekTo(value);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
