import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AddStreamScreen extends StatefulWidget {
  final Function(String, String) onAddStream;

  const AddStreamScreen({super.key, required this.onAddStream});

  @override
  AddStreamScreenState createState() => AddStreamScreenState();
}

class AddStreamScreenState extends State<AddStreamScreen> {
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
      //title: const Text(addStreamLabel),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(addStreamLabel,
                style: TextStyle(fontSize: 20)), // Title included here
            const SizedBox(height: 20), // Space after title
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
            const SizedBox(height: 20), // Add some space before the buttons
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
                  child: const Text(addButtonLabel),
                  onPressed: () {
                    final url = _urlController.text;
                    final title = _titleController.text;
                    if (url.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(emptyStreamAddressError)),
                      );
                      return;
                    }

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(emptyTitleError)),
                      );
                      return;
                    }

                    widget.onAddStream(url, title);
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
