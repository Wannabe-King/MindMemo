import 'package:flutter_test/flutter_test.dart';
import 'package:learning/services/auth/auth_exceptions.dart';
import 'package:learning/services/auth/auth_provider.dart';
import 'package:learning/services/auth/auth_user.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized in the begining',
        () => expect(provider.isInitialize, false));

    test(
        'Cannot logout if not initialized',
        () => {
              expect(provider.logOut(),
                  throwsA(const TypeMatcher<NotInitializedException>()))
            });

    test('Should be able to initialize in less than 2 sec', () async {
      await provider.initialize();
      expect(provider.isInitialize, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('User should be empty after initialization',
        () => expect(provider.currentUser, null));

    test('Create user should delegate to logIn function', () async {
      final badEmailUser = provider.createUser(
        email: "priyanshu21100@gmail.com",
        password: "P13?r!12",
      );
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));


      final badPasswordUser = provider.createUser(
        email: "someone@gmail.com",
        password: "P12?r!12",
      );
      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));


      final user=await provider.createUser(email: "foo", password: 'bar');
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });


    test('Logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user=provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to logOut and logIn again', () async {
      await provider.logOut();
      await provider.logIn(email: 'priyanshu21100@', password: '?r!12');
      final user=provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialize => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!_isInitialized) throw NotInitializedException();
    if (email == "priyanshu21100@gmail.com") throw UserNotFoundAuthException();
    if (password == "P12?r!12") throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!_isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!_isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
