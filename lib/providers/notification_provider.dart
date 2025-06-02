import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notificationServices//notification_service.dart';


final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationState {
  final bool isInitialized;
  final bool hasPermission;

  NotificationState({
    this.isInitialized = false,
    this.hasPermission = false,
  });

  NotificationState copyWith({
    bool? isInitialized,
    bool? hasPermission,
  }) {
    return NotificationState(
      isInitialized: isInitialized ?? this.isInitialized,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }
}

class NotificationStateNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService;

  NotificationStateNotifier(this._notificationService)
      : super(NotificationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _notificationService.initialize();
      state = state.copyWith(isInitialized: true);
    } catch (e) {
      // Handle initialization error
      print('Failed to initialize notifications: $e');
    }
  }

  Future<void> showTimerComplete({
    required bool isWorkMode,
    required int nextDuration,
  }) async {
    if (!state.isInitialized) return;

    await _notificationService.showTimerCompleteNotification(
      isWorkMode: isWorkMode,
      nextDuration: nextDuration,
    );
  }

  Future<void> scheduleNotification({
    required DateTime scheduledDate,
    required bool isWorkMode,
    required int nextDuration,
  }) async {
    if (!state.isInitialized) return;

    await _notificationService.scheduleTimerNotification(
      scheduledDate: scheduledDate,
      isWorkMode: isWorkMode,
      nextDuration: nextDuration,
    );
  }

  Future<void> cancelNotifications() async {
    if (!state.isInitialized) return;
    await _notificationService.cancelAllNotifications();
  }
}

final notificationStateProvider =
StateNotifierProvider<NotificationStateNotifier, NotificationState>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationStateNotifier(notificationService);
});