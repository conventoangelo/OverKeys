import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:overkeys/services/config_service.dart';
import 'package:overkeys/models/keyboard_layouts.dart';

typedef LayerChangeCallback = void Function(
    KeyboardLayout layout, bool isDefaultUserLayout);
typedef DisconnectCallback = void Function();

/// Service for integrating with Kanata keyboard layout manager
class KanataService {
  Socket? _kanataSocket;
  Timer? _kanataTimer;
  String _host = '127.0.0.1';
  int _port = 4039;
  LayerChangeCallback? onLayerChange;
  DisconnectCallback? onDisconnect;
  bool _reconnectEnabled = true;
  List<KeyboardLayout> _userLayouts = [];
  String _defaultUserLayout = 'QWERTY';
  final ConfigService _configService = ConfigService();

  // Constants
  static const Duration _reconnectDelay = Duration(seconds: 5);

  Future<void> connect() async {
    _kanataSocket?.destroy();
    _kanataTimer?.cancel();
    // Always enable reconnection when connect() is explicitly called
    // This ensures that toggling Kanata on will keep trying to connect
    _reconnectEnabled = true;

    try {
      final config = await _configService.loadConfig();
      _host = config.kanataHost ?? '127.0.0.1';
      _port = config.kanataPort ?? 4039;
      _userLayouts = config.userLayouts ?? [];
      _defaultUserLayout = config.defaultUserLayout ?? 'QWERTY';
      _kanataSocket = await Socket.connect(_host, _port);
      if (kDebugMode) {
        print('Connected to Kanata server at $_host:$_port');
      }
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
    if (kDebugMode) {
      print('Disconnected from Kanata server');
    }

    // Notify about disconnection so layout can be restored
    if (onDisconnect != null && _reconnectEnabled) {
      onDisconnect!();
    }

    if (_reconnectEnabled) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!_reconnectEnabled) return;

    _kanataTimer?.cancel();
    _kanataTimer = Timer(_reconnectDelay, connect);
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

            bool isDefaultUserLayout = newLayout.name.toUpperCase() ==
                _defaultUserLayout.toUpperCase();

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
  }

  void dispose() {
    disconnect();
  }
}
