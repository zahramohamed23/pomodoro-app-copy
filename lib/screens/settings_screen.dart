import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:numberpicker/numberpicker.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';  //  auth_provider.dart

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final userAsyncValue = ref.watch(authStateProvider);
    final user = userAsyncValue.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Email: ${user.email}'),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: () async {
                        try {
                          await ref.read(authProvider.notifier).signOut();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error signing out: $e')),
                          );
                        }
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timer Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Work Duration'),
                    subtitle: Text('${settings.workDuration} minutes'),
                    trailing: const Icon(Icons.timer),
                    onTap: () => _showDurationPicker(
                      context,
                      ref,
                      'Work Duration',
                      settings.workDuration,
                          (value) =>
                          ref.read(settingsProvider.notifier).updateWorkDuration(value),
                      maxValue: 60,
                    ),
                  ),
                  ListTile(
                    title: const Text('Short Break Duration'),
                    subtitle: Text('${settings.shortBreakDuration} minutes'),
                    trailing: const Icon(Icons.coffee),
                    onTap: () => _showDurationPicker(
                      context,
                      ref,
                      'Short Break Duration',
                      settings.shortBreakDuration,
                          (value) =>
                          ref.read(settingsProvider.notifier).updateShortBreakDuration(value),
                      maxValue: 30,
                    ),
                  ),
                  ListTile(
                    title: const Text('Long Break Duration'),
                    subtitle: Text('${settings.longBreakDuration} minutes'),
                    trailing: const Icon(Icons.weekend),
                    onTap: () => _showDurationPicker(
                      context,
                      ref,
                      'Long Break Duration',
                      settings.longBreakDuration,
                          (value) =>
                          ref.read(settingsProvider.notifier).updateLongBreakDuration(value),
                      maxValue: 45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: settings.isDarkMode,
                    onChanged: (_) => ref.read(settingsProvider.notifier).toggleDarkMode(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    value: settings.areNotificationsEnabled,
                    onChanged: (_) => ref.read(settingsProvider.notifier).toggleNotifications(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sound',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Sound'),
                    value: settings.isSoundEnabled,
                    onChanged: (_) => ref.read(settingsProvider.notifier).toggleSound(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDurationPicker(
      BuildContext context,
      WidgetRef ref,
      String title,
      int currentValue,
      Function(int) onChanged, {
        int maxValue = 60,
      }) async {
    TextEditingController textController = TextEditingController(text: currentValue.toString());

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NumberPicker(
                value: currentValue,
                minValue: 1,
                maxValue: maxValue,
                step: 1,
                onChanged: (value) {
                  setState(() {
                    onChanged(value);
                    textController.text = value.toString();
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter minutes',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final newValue = int.tryParse(value);
                  if (newValue != null && newValue >= 1 && newValue <= maxValue) {
                    setState(() {
                      onChanged(newValue);
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
