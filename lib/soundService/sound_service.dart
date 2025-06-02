import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomo2_tracker/providers/settings_provider.dart';

class SoundService {
  final AudioPlayer _audioPlayer;
  final SharedPreferences _prefs;
  static const String soundEnabledKey = 'sound_enabled';

  SoundService(this._prefs) : _audioPlayer = AudioPlayer();

  bool get isSoundEnabled => _prefs.getBool(soundEnabledKey) ?? true;
  set isSoundEnabled(bool value) => _prefs.setBool(soundEnabledKey, value);

  Future<void> playWorkCompleteSound() async {
    if (!isSoundEnabled) return;
    await _audioPlayer.play(AssetSource('sounds/kotkotkot.mp3'));
  }

  Future<void> playBreakCompleteSound() async {
    if (!isSoundEnabled) return;
    await _audioPlayer.play(AssetSource('sounds/kotkotkot.mp3'));
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

final soundServiceProvider = Provider<SoundService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SoundService(prefs);
});