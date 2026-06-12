import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';
import '../data/profile_provider.dart';
import '../data/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(authSessionProvider);
    final session = sessionAsync.valueOrNull;

    final profileAsync = ref.watch(profileProvider);
    final settings = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          if (session != null)
            Container(
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Row(
                children: [
                  profileAsync.when(
                    data: (profile) => CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      backgroundImage: profile?.avatar != null ? NetworkImage(profile!.avatar!) : null,
                      child: profile?.avatar == null ? Icon(Icons.person, size: 36, color: Theme.of(context).primaryColor) : null,
                    ),
                    loading: () => const CircleAvatar(radius: 32, backgroundColor: Colors.white, child: CircularProgressIndicator()),
                    error: (err, stack) => CircleAvatar(radius: 32, backgroundColor: Colors.white, child: Icon(Icons.person, size: 36, color: Theme.of(context).primaryColor)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        profileAsync.when(
                          data: (profile) => Text(profile?.displayName ?? session.handle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          loading: () => Text(session.handle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          error: (err, stack) => Text(session.handle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        const SizedBox(height: 4),
                        Text(session.handle, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Appearance', style: TextStyle(color: Color(0xFF128C7E), fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) settingsNotifier.setThemeMode(newValue);
              },
              items: ThemeMode.values.map<DropdownMenuItem<ThemeMode>>((ThemeMode mode) {
                return DropdownMenuItem<ThemeMode>(
                  value: mode,
                  child: Text(mode.name.toUpperCase()),
                );
              }).toList(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.font_download),
            title: const Text('Font'),
            trailing: DropdownButton<String>(
              value: settings.fontFamily,
              onChanged: (String? newValue) {
                if (newValue != null) settingsNotifier.setFontFamily(newValue);
              },
              items: <String>['Default', 'Roboto', 'monospace', 'serif'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.format_size),
            title: const Text('Text Size'),
            subtitle: Slider(
              value: settings.textScale,
              min: 0.8,
              max: 1.5,
              divisions: 7,
              label: settings.textScale.toStringAsFixed(1),
              onChanged: (double value) {
                settingsNotifier.setTextScale(value);
              },
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Account', style: TextStyle(color: Color(0xFF128C7E), fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Log out?'),
                  content: const Text('Are you sure you want to log out of BARC?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF128C7E))),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Log out', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await ref.read(authRepositoryProvider).logout();
                ref.invalidate(authSessionProvider);
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
