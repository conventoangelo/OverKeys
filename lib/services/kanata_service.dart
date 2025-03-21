import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:overkeys/services/config_service.dart';
import 'package:overkeys/utils/keyboard_layouts.dart';

typedef LayerChangeCallback = void Function(
    KeyboardLayout layout, bool isDefaultUserLayout);

class KanataService {
  final ConfigService _configService = ConfigService();
  Socket? _kanataSocket;
  bool _isConnected = false;
  Timer? _kanataTimer;
  String _host = '127.0.0.1';
  int _port = 4039;
  LayerChangeCallback? onLayerChange;
  bool _reconnectEnabled = true;
  List<KeyboardLayout> _userLayouts = [];
  String _defaultUserLayout = 'QWERTY';

  bool get isConnected => _isConnected;

  Future<void> initializeIfEnabled() async {
    final config = await _configService.loadConfig();
    _host = config.kanataHost;
    _port = config.kanataPort;
    _userLayouts = config.userLayouts;
    _defaultUserLayout = config.defaultUserLayout;

    connect();
  }

  Future<void> connect() async {
    if (_isConnected) {
      return;
    }

    _kanataTimer?.cancel();
    _reconnectEnabled = true;

    try {
      final config = await _configService.loadConfig();
      _host = config.kanataHost;
      _port = config.kanataPort;
      _userLayouts = config.userLayouts;
      _defaultUserLayout = config.defaultUserLayout;

      if (kDebugMode) {
        print(
            'Connecting to Kanata at $_host:$_port with ${_userLayouts.length} layers. Default layer: $_defaultUserLayout');
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
            KeyboardLayout? newLayout = _userLayouts.firstWhere(
              (layout) => layout.name.toUpperCase() == layoutName,
              orElse: () => availableLayouts.firstWhere(
                (layout) => layout.name.toUpperCase() == layoutName,
                orElse: () => throw Exception(
                    'Layout not found in Kanata layers or available layouts'),
              ),
            );

            bool isDefaultUserLayout =
                newLayout.name.toUpperCase() == _defaultUserLayout.toUpperCase();

            onLayerChange!(newLayout, isDefaultUserLayout);

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

  void updateSettings(String host, int port, List<KeyboardLayout> layers) {
    bool shouldReconnect = _isConnected;

    disconnect();
    _host = host;
    _port = port;
    _userLayouts = layers;

    if (shouldReconnect) {
      _reconnectEnabled = true;
      connect();
    }
  }

  void dispose() {
    disconnect();
  }
}
