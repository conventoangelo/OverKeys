import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class RecordHotKeyDialog extends StatefulWidget {
  const RecordHotKeyDialog({
    super.key,
    required this.onHotKeyRecorded,
    required this.initialHotKey,
  });

  final ValueChanged<HotKey> onHotKeyRecorded;
  final HotKey initialHotKey;

  @override
  State<RecordHotKeyDialog> createState() => _RecordHotKeyDialogState();
}

class _RecordHotKeyDialogState extends State<RecordHotKeyDialog> {
  HotKey? _hotKey;

  @override
  void initState() {
    super.initState();
    _hotKey = widget.initialHotKey;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 10)),
            const Text(
              'Press the key combination you want to use as a shortcut.',
              style: TextStyle(fontSize: 16),
            ),
            Container(
              width: 100,
              height: 60,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  HotKeyRecorder(
                    initalHotKey: _hotKey,
                    onHotKeyRecorded: (hotKey) {
                      setState(() {
                        _hotKey = HotKey(
                          key: hotKey.key,
                          modifiers: hotKey.modifiers,
                          scope: HotKeyScope.system,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            const Text(
              'Note: You cannot set a keybind that is already in use by another shortcut.',
              style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: _hotKey == null
              ? null
              : () {
                  widget.onHotKeyRecorded(_hotKey!);
                  Navigator.of(context).pop();
                },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
