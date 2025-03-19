import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:overkeys/services/config_service.dart';
import 'package:overkeys/utils/keyboard_layouts.dart';

typedef LayerChangeCallback = void Function(KeyboardLayout layout);

class KanataService {
  final ConfigService _configService = ConfigService();
  Socket? _kanataSocket;
  bool _isConnected = false;
  Timer? _kanataTimer;
  String _host = '127.0.0.1';
  int _port = 4039;
  LayerChangeCallback? onLayerChange;
  bool _reconnectEnabled = true;

  bool get isConnected => _isConnected;

  Future<void> initializeIfEnabled() async {
    final kanataConfig = await _configService.getKanataConfig();

    if (kanataConfig != null) {
      _host = kanataConfig['host'];
      _port = kanataConfig['port'];

      connect();
    }
  }

  Future<void> connect() async {
    if (_isConnected) {
      return;
    }

    _kanataTimer?.cancel();
    _reconnectEnabled = true;

    try {
      final kanataConfig = await _configService.getKanataConfig();
      if (kanataConfig != null) {
        _host = kanataConfig['host'];
        _port = kanataConfig['port'];
      }
      if (kDebugMode) {
        print(kanataConfig);
      }

      _kanataSocket = await Socket.connect(_host, _port);
      if (kDebugMode) {
        print('Connected to Kanata server at $_host:$_port');
      }

      _isConnected = true;

      _kanataSocket!.listen(
        (data) {
          String message = String.fromCharCodes(data).trim();
          _handleKanataMessage(message);
        },
        onDone: _onDisconnected,
        onError: (error) {
          if (kDebugMode) {
            print('Socket error: $error');
          }
          _onDisconnected();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to connect to Kanata server: $e');
      }
      _scheduleReconnect();
    }
  }

  void _onDisconnected() {
    _isConnected = false;
    _kanataSocket = null;

    if (kDebugMode) {
      print('Disconnected from Kanata server');
    }

    if (_reconnectEnabled) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!_reconnectEnabled) return;

    _kanataTimer?.cancel();
    _kanataTimer = Timer(const Duration(seconds: 5), connect);
  }

  void _handleKanataMessage(String message) {
    try {
      Map<String, dynamic> jsonData = jsonDecode(message);

      if (jsonData.containsKey('LayerChange')) {
        String layoutName =
            jsonData['LayerChange']['new']?.toString().trim().toUpperCase() ??
                '';

        if (layoutName.isNotEmpty && onLayerChange != null) {
          try {
            KeyboardLayout newLayout = availableLayouts.firstWhere(
                (layout) => layout.name.toUpperCase() == layoutName,
                orElse: () => throw Exception('Layout not found'));

            onLayerChange!(newLayout);

            if (kDebugMode) {
              print('Switched to layout: ${newLayout.name}');
            }
          } catch (e) {
            if (kDebugMode) {
              print('Unknown layout: $layoutName');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to parse Kanata message: $e');
      }
    }
  }

  void disconnect() {
    _reconnectEnabled = false;
    _kanataTimer?.cancel();
    _kanataSocket?.destroy();
    _isConnected = false;
  }

  void updateSettings(String host, int port) {
    bool shouldReconnect = _isConnected;

    disconnect();
    _host = host;
    _port = port;

    if (shouldReconnect) {
      _reconnectEnabled = true;
      connect();
    }
  }

  void dispose() {
    disconnect();
  }
}
