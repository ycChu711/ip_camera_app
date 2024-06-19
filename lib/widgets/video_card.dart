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
    Key? key,
    required this.title,
    required this.url,
    required this.index,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VlcPlayerController _controller;
  bool _isFile = false;

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
        print('Error playing video: ${_controller.value.errorDescription}');
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
                          return Center(
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 32,
                            ),
                          );
                        }
                        return value.isPlaying
                            ? SizedBox.shrink()
                            : ElevatedButton(
                                onPressed: () {
                                  if (_controller.value.isInitialized) {
                                    setState(() {
                                      _controller.play();
                                      print(
                                          'Play button pressed, video playing');
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
                            print('Video paused');
                          } else {
                            _controller.play();
                            print('Video playing');
                          }
                        });
                      } else {
                        print('Controller not initialized');
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
