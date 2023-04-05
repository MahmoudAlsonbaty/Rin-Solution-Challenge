import 'auth_user.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });
  Future<void> anonymousLogIn();

  Future<void> initialize();
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();

  Future<bool> setPassword({required String password});

  Future<bool> sendPasswordReset(String email);
}
