import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class PingDialog extends StatefulWidget {
  final String title;
  final String messageLabel;
  final Function(String message) onSend;

  const PingDialog({
    super.key,
    required this.title,
    required this.messageLabel,
    required this.onSend,
  });

  @override
  State<PingDialog> createState() => _PingDialogState();
}

class _PingDialogState extends State<PingDialog> {
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      await widget.onSend(_messageController.text);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorSendingPing(e.toString()))),
        );
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: widget.messageLabel, // Or pass localized string from parent
                border: const OutlineInputBorder(),
                hintText: AppLocalizations.of(context)!.pingMessageHint,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.enterMessage;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _isSending ? null : _handleSend,
          child: _isSending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(AppLocalizations.of(context)!.send),
        ),
      ],
    );
  }
}
