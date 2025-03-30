import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:overkeys/widgets/options/options.dart';

class AboutTab extends StatelessWidget {
  final String appVersion;

  const AboutTab({super.key, required this.appVersion});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SectionTitle(title: 'About'),
          const SizedBox(height: 20),
          Image.asset('assets/images/app_icon.png', width: 120),
          const SizedBox(height: 20),
          Text('OverKeys',
              style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          Text('Version: $appVersion',
              style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text('© 2024 Angelo Convento',
              style: TextStyle(
                  color: colorScheme.onSurface.withAlpha(153),
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await launchUrl(
                  Uri.parse('https://github.com/conventoangelo/overkeys'),
                  mode: LaunchMode.externalApplication);
            },
            icon: ImageIcon(
              AssetImage('assets/images/github-mark.png'),
              size: 20,
            ),
            label: Text(
              'View on GitHub',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
