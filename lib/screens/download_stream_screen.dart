import 'package:flutter/material.dart';
import '../utils/constants.dart';

class DownloadStreamScreen extends StatefulWidget {
  final Function(String, String) onDownloadStream;

  const DownloadStreamScreen({Key? key, required this.onDownloadStream})
      : super(key: key);

  @override
  _DownloadStreamScreenState createState() => _DownloadStreamScreenState();
}

class _DownloadStreamScreenState extends State<DownloadStreamScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(downloadStreamLabel,
                style: TextStyle(fontSize: 20)), // Title included here
            SizedBox(height: 20), // Space after title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: titleLabel,
              ),
            ),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: streamUrlLabel,
              ),
            ),
            SizedBox(height: 20), // Space before the buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text(cancelButtonLabel),
                  onPressed: () {
                    _titleController.clear();
                    _urlController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(downloadButtonLabel),
                  onPressed: () {
                    final url = _urlController.text;
                    final title = _titleController.text;
                    if (url.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(emptyStreamAddressError)),
                      );
                      return;
                    }

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(emptyTitleError)),
                      );
                      return;
                    }

                    widget.onDownloadStream(url, title);
                    _titleController.clear();
                    _urlController.clear();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
