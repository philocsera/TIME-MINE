import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timemine/core/notifiers/app_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _pickDayStart(BuildContext context) async {
    final settings = context.read<AppSettings>();

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.dayStartHour,
        minute: settings.dayStartMinute,
      ),
    );

    if (picked == null) return;

    await settings.setDayStartMinutes(
      picked.hour * 60 + picked.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text('Settings'),
        ),
        body: !settings.loaded
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SettingTile(
                    title: '하루 시작 시각',
                    subtitle:
                        '${settings.dayStartHour.toString().padLeft(2, '0')}:'
                        '${settings.dayStartMinute.toString().padLeft(2, '0')}',
                    onTap: () => _pickDayStart(context),
                  ),
                ],
              ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
