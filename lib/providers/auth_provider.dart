import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// ─── Auth state ───────────────────────────────────────────────────────────────
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final ApiUser? user;
  const AuthState({required this.status, this.user});
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // Restore persisted session on startup
    await ApiService.instance.init();
    if (ApiService.instance.isLoggedIn) {
      final user = await ApiService.instance.refreshUser();
      if (user != null) {
        return AuthState(status: AuthStatus.authenticated, user: user);
      }
    }
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ApiService.instance.login(email, password);
      return AuthState(status: AuthStatus.authenticated, user: user);
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    String lastName = '',
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ApiService.instance.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      return AuthState(status: AuthStatus.authenticated, user: user);
    });
  }

  Future<void> logout() async {
    await ApiService.instance.logout();
    state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

/// Simple bool provider – true when the user is logged in.
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).value?.status == AuthStatus.authenticated;
});

/// Current user provider.
final currentUserProvider = Provider<ApiUser?>((ref) {
  return ref.watch(authProvider).value?.user;
});
