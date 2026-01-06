import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkerCredentialsDialog extends StatelessWidget {
  final String workerName;
  final String email;
  final String password;
  final String? phone;

  const WorkerCredentialsDialog({
    super.key,
    required this.workerName,
    required this.email,
    required this.password,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          const Text('Worker Account Created!'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Login credentials for $workerName:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCredentialField(context, 'Email', email),
            const SizedBox(height: 12),
            _buildCredentialField(context, 'Password', password),
            const SizedBox(height: 20),
            const Text(
              'Send these credentials to the worker:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        if (phone != null)
          TextButton.icon(
            onPressed: () => _sendViaSMS(context),
            icon: const Icon(Icons.sms),
            label: const Text('Send SMS'),
          ),
        TextButton.icon(
          onPressed: () => _copyToClipboard(context),
          icon: const Icon(Icons.copy),
          label: const Text('Copy'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _buildCredentialField(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _sendViaSMS(BuildContext context) {
    if (phone == null) return;

    final message = Uri.encodeComponent(
      'Welcome to Cofiz!\n\n'
      'Email: $email\n'
      'Password: $password\n\n'
      'Download the app and login to start tracking your sales.',
    );

    final smsUri = 'sms:$phone?body=$message';
    
    launchUrl(Uri.parse(smsUri)).then((success) {
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open SMS app')),
        );
      }
    });
  }

  void _copyToClipboard(BuildContext context) {
    final credentials = '''
Cofiz Login Credentials

Worker: $workerName
Email: $email
Password: $password
''';

    Clipboard.setData(ClipboardData(text: credentials));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Credentials copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
