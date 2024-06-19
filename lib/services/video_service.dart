import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

Future<String> downloadVideo(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final directory = await getApplicationDocumentsDirectory();
    // Ensure the filename is valid and properly formatted
    final fileName = basename(Uri.parse(url).path)
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final filePath = join(directory.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    print('File downloaded to: $filePath'); // Log file path
    return filePath;
  } else {
    throw Exception('Failed to download video');
  }
}
