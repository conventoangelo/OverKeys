import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:logging/logging.dart';
import 'package:overkeys/utils/logger.dart';

class DebugViewer extends StatefulWidget {
  const DebugViewer({super.key});

  @override
  State<DebugViewer> createState() => _DebugViewerState();
}

class _DebugViewerState extends State<DebugViewer> {
  final LogCapture _logCapture = LogCapture();
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;
  Timer? _refreshTimer;
  int _lastLogCount = 0;

  @override
  void initState() {
    super.initState();

    // Refresh log display every 100ms to capture new logs
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        final currentLogCount = _logCapture.logCount;
        if (currentLogCount != _lastLogCount) {
          _lastLogCount = currentLogCount;
          setState(() {});

          if (_autoScroll && _scrollController.hasClients) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _copyAllLogsToClipboard() {
    final logs = _logCapture.logs.map((log) => log.formattedMessage).join('\n');

    Clipboard.setData(ClipboardData(text: logs));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearLogs() {
    setState(() {
      _logCapture.clear();
    });
  }

  Color _getColorForLevel(Level level, ColorScheme colorScheme) {
    if (level == Level.FINE) {
      return colorScheme.onSurface.withAlpha(153);
    } else if (level == Level.INFO) {
      return Colors.blue;
    } else if (level == Level.WARNING) {
      return Colors.orange;
    } else if (level == Level.SEVERE) {
      return Colors.red;
    }
    return colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final logs = _logCapture.logs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with controls
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.terminal, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Debug Logs',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                // Auto-scroll toggle
                Tooltip(
                  message: 'Auto-scroll to bottom',
                  child: IconButton(
                    icon: Icon(
                      _autoScroll
                          ? LucideIcons.arrowDown
                          : LucideIcons.arrowDownToLine,
                      size: 20,
                    ),
                    color: _autoScroll
                        ? colorScheme.primary
                        : colorScheme.onSurface.withAlpha(153),
                    onPressed: () {
                      setState(() {
                        _autoScroll = !_autoScroll;
                        if (_autoScroll && _scrollController.hasClients) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    },
                  ),
                ),
                // Copy button
                Tooltip(
                  message: 'Copy logs to clipboard',
                  child: IconButton(
                    icon: const Icon(LucideIcons.copy, size: 20),
                    color: colorScheme.onSurface.withAlpha(153),
                    onPressed: _copyAllLogsToClipboard,
                  ),
                ),
                // Clear button
                Tooltip(
                  message: 'Clear logs',
                  child: IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 20),
                    color: colorScheme.onSurface.withAlpha(153),
                    onPressed: _clearLogs,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Log display area
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline.withAlpha(64)),
            ),
            child: logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.inbox,
                          size: 48,
                          color: colorScheme.onSurface.withAlpha(77),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No logs to display',
                          style: TextStyle(
                            color: colorScheme.onSurface.withAlpha(153),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: SelectableText(
                          log.formattedMessage,
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 14,
                            color: _getColorForLevel(log.level, colorScheme),
                            height: 1.4,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
