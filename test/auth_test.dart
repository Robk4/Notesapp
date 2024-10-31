import 'dart:math';

import 'package:notesapp/services/auth/auth_exceptions.dart';
import 'package:notesapp/services/auth/auth_provider.dart';
import 'package:notesapp/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group("Mock Authentication", () {
    final provider =
        MockAuthProvider(); //For testing provider becomes mock provider.
    test("Should not be initialized at the start", () {
      expect(provider.isInitialized, false);
    });

    test("Cannot log out if not initialized at the start", () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test("Should be able to initialize", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test("User should be null aftet initialization", () {
      expect(provider.currentUser, null);
    });

    test(
      "Should initialize <2 seconds",
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test("Created user should go to logIn function", () async {
      final badEmailUser = provider.createUser(
        email: 'not@found.com',
        password: 'anypassword',
      );

      expect(badEmailUser,
          throwsA(const TypeMatcher<InvalidCredentialsdAuthException>()));

      final badPasswordUser = provider.createUser(
        email: 'some@email.com',
        password: 'notfound',
      );

      expect(badPasswordUser,
          throwsA(const TypeMatcher<InvalidCredentialsdAuthException>()));

      final user = await provider.createUser(
          email: 'random@email.com', password: 'password');

      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
    test("Logged in user should be able to be verified", () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test("Can log out and log in back", () async {
      await provider.logOut();
      await provider.logIn(
        email: 'email',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

//Creation of a MockAuthProvider which we use to communicate with AuthServise but have full control over the changes for testing
class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1)); //Fake waiting
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1)); //Fake waiting
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'not@found.com') throw InvalidCredentialsdAuthException();
    if (password == 'notfound') throw InvalidCredentialsdAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 1)); //Fake waiting
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotLoggedInAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
