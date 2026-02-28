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
  Set<Level> _selectedLevels = {
    Level.FINE,
    Level.INFO,
    Level.WARNING,
    Level.SEVERE
  };
  bool _autoScroll = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-scroll to bottom on new logs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_autoScroll && _scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    // Refresh log display every 500ms to capture new logs
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {
          // Trigger rebuild to show new logs
        });
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
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _copyAllLogsToClipboard() {
    final logs = _logCapture.logs
        .where((log) => _selectedLevels.contains(log.level))
        .map((log) => log.formattedMessage)
        .join('\n');

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

  void _generateTestLogs() {
    final testLogger = SimplePrintLogger('TestLogger');
    testLogger.debug('Test DEBUG message');
    testLogger.info('Test INFO message');
    testLogger.warning('Test WARNING message');
    testLogger.error('Test ERROR message');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test logs generated'),
        duration: Duration(seconds: 2),
      ),
    );
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
    final filteredLogs = _logCapture.logs
        .where((log) => _selectedLevels.contains(log.level))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withAlpha(128)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                    const SizedBox(width: 8),
                    Text(
                      '(${_logCapture.logs.length} total)',
                      style: TextStyle(
                        color: colorScheme.onSurface.withAlpha(153),
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    // Test button
                    Tooltip(
                      message: 'Generate test logs',
                      child: IconButton(
                        icon: const Icon(LucideIcons.flaskConical, size: 20),
                        color: colorScheme.onSurface.withAlpha(153),
                        onPressed: _generateTestLogs,
                      ),
                    ),
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
                const SizedBox(height: 8),
                // Status indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _logCapture.isInitialized
                        ? Colors.green.withAlpha(26)
                        : Colors.red.withAlpha(26),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _logCapture.isInitialized
                          ? Colors.green.withAlpha(128)
                          : Colors.red.withAlpha(128),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _logCapture.isInitialized
                            ? LucideIcons.checkCircle2
                            : LucideIcons.xCircle,
                        size: 16,
                        color: _logCapture.isInitialized
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _logCapture.isInitialized
                            ? 'Logger initialized • ${_logCapture.logCount} logs captured'
                            : 'Logger not initialized',
                        style: TextStyle(
                          color: _logCapture.isInitialized
                              ? Colors.green
                              : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8,
              children: [
                _buildFilterChip(Level.FINE, 'DEBUG', colorScheme),
                _buildFilterChip(Level.INFO, 'INFO', colorScheme),
                _buildFilterChip(Level.WARNING, 'WARNING', colorScheme),
                _buildFilterChip(Level.SEVERE, 'ERROR', colorScheme),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Log display area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline.withAlpha(64)),
              ),
              child: filteredLogs.isEmpty
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
                          const SizedBox(height: 8),
                          Text(
                            'Click the flask icon above to generate test logs',
                            style: TextStyle(
                              color: colorScheme.onSurface.withAlpha(128),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: SelectableText(
                            log.formattedMessage,
                            style: TextStyle(
                              fontFamily: 'Courier New',
                              fontSize: 12,
                              color: _getColorForLevel(log.level, colorScheme),
                              height: 1.4,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          // Footer with log count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              '${filteredLogs.length} log entries (${_logCapture.logs.length} total)',
              style: TextStyle(
                color: colorScheme.onSurface.withAlpha(128),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(Level level, String label, ColorScheme colorScheme) {
    final isSelected = _selectedLevels.contains(level);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedLevels.add(level);
          } else {
            _selectedLevels.remove(level);
          }
        });
      },
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected
            ? colorScheme.onSecondaryContainer
            : colorScheme.onSurface.withAlpha(153),
      ),
      backgroundColor: colorScheme.surface,
      selectedColor: _getColorForLevel(level, colorScheme).withAlpha(64),
      checkmarkColor: _getColorForLevel(level, colorScheme),
      side: BorderSide(
        color: isSelected
            ? _getColorForLevel(level, colorScheme)
            : colorScheme.outline.withAlpha(128),
      ),
    );
  }
}
