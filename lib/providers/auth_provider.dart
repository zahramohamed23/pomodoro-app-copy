import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebaseServices//firebase_service.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signInAnonymously() async {
    try {
      state = const AsyncValue.loading();
      final service = _ref.read(firebaseServiceProvider);
      final credential = await service.signInAnonymously();
      state = AsyncValue.data(credential.user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      final service = _ref.read(firebaseServiceProvider);
      await service.resetPassword(email);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      state = const AsyncValue.loading();
      final service = _ref.read(firebaseServiceProvider);
      await service.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final service = _ref.read(firebaseServiceProvider);
      final credential = await service.signUp(email, password);
      state = AsyncValue.data(credential.user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final service = _ref.read(firebaseServiceProvider);
      final credential = await service.signIn(email, password);
      state = AsyncValue.data(credential.user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    // Firebase Auth example:
    final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    state = AsyncData(credential.user);
  }


}
