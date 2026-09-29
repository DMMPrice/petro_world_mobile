import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import '../services/logger_service.dart';

const _googleWebClientId =
    '521094424048-65p6soaovklg8t8kkpg53400mj5r32sg.apps.googleusercontent.com';
final _googleSignIn = GoogleSignIn.instance;

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
    await _googleSignIn.initialize(serverClientId: _googleWebClientId);
    await ApiService.instance.init();
    if (ApiService.instance.isLoggedIn) {
      final user = await ApiService.instance.refreshUser();
      if (user != null) {
        return AuthState(status: AuthStatus.authenticated, user: user);
      }
    }
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> googleLogin() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      late final GoogleSignInAccount account;
      try {
        account = await _googleSignIn.authenticate();
      } on GoogleSignInException catch (error, stackTrace) {
        LoggerService.error('Google sign-in failed', error, stackTrace);
        final detail = error.description?.trim();
        final message = switch (error.code) {
          GoogleSignInExceptionCode.canceled => 'Google sign-in was cancelled',
          GoogleSignInExceptionCode.clientConfigurationError =>
            'Google sign-in is not configured for this Android app${detail == null || detail.isEmpty ? '' : ': $detail'}',
          GoogleSignInExceptionCode.providerConfigurationError =>
            'Google sign-in provider configuration error${detail == null || detail.isEmpty ? '' : ': $detail'}',
          _ => detail == null || detail.isEmpty
              ? 'Google sign-in failed (${error.code.name})'
              : 'Google sign-in failed: $detail',
        };
        throw ApiException(message, 400);
      }
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const ApiException('Google did not return an ID token', 401);
      }
      final user = await ApiService.instance.googleLogin(idToken);
      return AuthState(status: AuthStatus.authenticated, user: user);
    });
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
