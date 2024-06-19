import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AddStreamScreen extends StatefulWidget {
  final Function(String, String) onAddStream;

  const AddStreamScreen({Key? key, required this.onAddStream})
      : super(key: key);

  @override
  _AddStreamScreenState createState() => _AddStreamScreenState();
}

class _AddStreamScreenState extends State<AddStreamScreen> {
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
      title: const Text(addStreamLabel),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: titleLabel,
              ),
            ),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: rtspUrlLabel,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
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

            widget.onAddStream(url, title);
            _titleController.clear();
            _urlController.clear();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
