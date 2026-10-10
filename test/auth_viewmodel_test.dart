import 'package:flutter_test/flutter_test.dart';
import 'package:daynote/data/services/mock_auth_service.dart';
import 'package:daynote/viewmodels/auth_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService mockAuthService;
  late AuthViewModel authViewModel;

  setUp(() {
    mockAuthService = MockAuthService();
    authViewModel = AuthViewModel(authService: mockAuthService);
  });

  tearDown(() {
    authViewModel.dispose();
    mockAuthService.dispose();
  });

  test('AuthViewModel initial state is unauthenticated', () {
    expect(authViewModel.isAuthenticated, isFalse);
    expect(authViewModel.currentUser, isNull);
    expect(authViewModel.isLoading, isFalse);
    expect(authViewModel.errorMessage, isNull);
  });

  test('AuthViewModel validates empty inputs on sign in', () async {
    final success = await authViewModel.signIn(email: '', password: '');
    expect(success, isFalse);
    expect(authViewModel.errorMessage, isNotNull);
  });

  test('AuthViewModel validates password matching on sign up', () async {
    final success = await authViewModel.signUp(
      email: 'test@example.com',
      password: 'password123',
      confirmPassword: 'password456',
    );
    expect(success, isFalse);
    expect(authViewModel.errorMessage, equals('Passwords do not match.'));
  });

  test('AuthViewModel sends password reset email successfully', () async {
    final success = await authViewModel.sendPasswordReset(email: 'user@example.com');
    expect(success, isTrue);
    expect(authViewModel.successMessage, contains('Password reset link sent'));
  });
}
