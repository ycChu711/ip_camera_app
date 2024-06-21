import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:async';

class MqttService {
  final String server;
  final String clientId;
  MqttServerClient? _client;
  Stream<List<MqttReceivedMessage<MqttMessage>>>? updates;

  MqttService(this.server, this.clientId) {
    _client = MqttServerClient(server, clientId);
    _client!.logging(on: true);
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client!.connectionMessage = connMessage;
  }

  Future<void> connect() async {
    try {
      await _client!.connect();
    } catch (e) {
      _client!.disconnect();
      throw Exception('Failed to connect to MQTT server');
    }

    updates = _client!.updates;
  }

  void subscribe(String topic) {
    _client!.subscribe(topic, MqttQos.atMostOnce);
  }

  void _onConnected() {
    if (kDebugMode) {
      print('Connected to the MQTT server');
    }
  }

  void _onDisconnected() {
    if (kDebugMode) {
      print('Disconnected from the MQTT server');
    }
  }

  void _onSubscribed(String topic) {
    if (kDebugMode) {
      print('Subscribed to topic: $topic');
    }
  }

  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;
}
