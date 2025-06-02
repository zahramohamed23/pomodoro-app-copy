import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  final bool isDarkMode;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool notificationsEnabled;
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;

  Settings({
    required this.isDarkMode,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.notificationsEnabled,
    required this.workDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
  });

  // Getters
  bool get isSoundEnabled => soundEnabled;
  bool get areNotificationsEnabled => notificationsEnabled;

  Settings copyWith({
    bool? isDarkMode,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? notificationsEnabled,
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
  }) {
    return Settings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
    );
  }
}

class SettingsNotifier extends StateNotifier<Settings> {
  final SharedPreferences prefs;

  SettingsNotifier(this.prefs)
      : super(
    Settings(
      isDarkMode: prefs.getBool('isDarkMode') ?? false,
      soundEnabled: prefs.getBool('soundEnabled') ?? true,
      vibrationEnabled: prefs.getBool('vibrationEnabled') ?? true,
      notificationsEnabled: prefs.getBool('notificationsEnabled') ?? true,
      workDuration: prefs.getInt('workDuration') ?? 25,
      shortBreakDuration: prefs.getInt('shortBreakDuration') ?? 5,
      longBreakDuration: prefs.getInt('longBreakDuration') ?? 15,
    ),
  );

  void toggleDarkMode() {
    final newValue = !state.isDarkMode;
    prefs.setBool('isDarkMode', newValue);
    state = state.copyWith(isDarkMode: newValue);
  }

  void toggleSound() {
    final newValue = !state.soundEnabled;
    prefs.setBool('soundEnabled', newValue);
    state = state.copyWith(soundEnabled: newValue);
  }

  void toggleNotifications() {
    final newValue = !state.notificationsEnabled;
    prefs.setBool('notificationsEnabled', newValue);
    state = state.copyWith(notificationsEnabled: newValue);
  }

  void toggleVibration() {
    final newValue = !state.vibrationEnabled;
    prefs.setBool('vibrationEnabled', newValue);
    state = state.copyWith(vibrationEnabled: newValue);
  }

  void updateWorkDuration(int minutes) {
    prefs.setInt('workDuration', minutes);
    state = state.copyWith(workDuration: minutes);
  }

  void updateShortBreakDuration(int minutes) {
    prefs.setInt('shortBreakDuration', minutes);
    state = state.copyWith(shortBreakDuration: minutes);
  }

  void updateLongBreakDuration(int minutes) {
    prefs.setInt('longBreakDuration', minutes);
    state = state.copyWith(longBreakDuration: minutes);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});