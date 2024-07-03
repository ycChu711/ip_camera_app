import 'package:flutter/material.dart';

const String appTitle = 'Flutter Demo';

// Error Messages
const String emptyStreamAddressError = 'Stream address cannot be empty';
const String emptyTitleError = 'Title cannot be empty';
const String failedDownloadError = 'Failed to download video: ';

// Labels
const String addStreamLabel = 'Add Stream';
const String downloadStreamLabel = 'Download Stream';
const String editStreamTitleLabel = 'Edit Stream Title';
const String rtspUrlLabel = 'RTSP URL';
const String streamUrlLabel = 'Stream URL';
const String titleLabel = 'Title';

// Buttons
const String addButtonLabel = 'Add';
const String downloadButtonLabel = 'Download';
const String saveButtonLabel = 'Save';
const String cancelButtonLabel = 'Cancel';
const String deleteButtonLabel = 'Delete';
const String confirmDeleteLabel = 'Confirm Delete';
const String confirmDeleteMessage =
    'Are you sure you want to delete this stream?';

// Dimensions
const double paddingSmall = 8.0;
const double paddingMedium = 16.0;
const double paddingLarge = 32.0;

// Colors
const Color primaryColor = Colors.blue;
const Color accentColor = Colors.blueAccent;
const Color backgroundColor = Colors.white;
const Color buttonColor = Colors.blue;
const Color buttonTextColor = Colors.white;

// Alert
const String mqttDanger = 'danger';
const String dangerAlert = 'DANGER';
const String appNotificationTitle = 'Alert';
const String appNotificationBody = 'Danger detected';

// MQTT
const String mqttServer = 'vip.panvision.com.tw';
const String mqttClientId = 'flutter_client';
const String mqttTopic = 'server/detection';
