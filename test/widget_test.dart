import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daynote/data/repositories/day_note_repository_impl.dart';
import 'package:daynote/data/services/mock_auth_service.dart';
import 'package:daynote/main.dart';
import 'package:daynote/ui/screens/home_screen.dart';
import 'package:daynote/viewmodels/auth_viewmodel.dart';
import 'package:daynote/viewmodels/day_note_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AuthScreen displays login and switches to Forgot Password and Sign Up', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockAuth = MockAuthService();
    final authViewModel = AuthViewModel(authService: mockAuth);
    final repository = DayNoteRepositoryImpl();
    final dayNoteViewModel = DayNoteViewModel(repository: repository);
    await dayNoteViewModel.init();

    await tester.pumpWidget(
      DayNoteApp(
        dayNoteViewModel: dayNoteViewModel,
        authViewModel: authViewModel,
      ),
    );
    await tester.pumpAndSettle();

    // Verify Auth Screen header
    expect(find.text('DAYNOTE'), findsOneWidget);
    expect(find.text('Sign In to Your Journal'), findsOneWidget);

    // Switch to Forgot Password
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);

    // Back to Sign In
    await tester.tap(find.text('← Back to Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Sign In to Your Journal'), findsOneWidget);

    // Switch to Sign Up
    await tester.tap(find.text('Create one'));
    await tester.pumpAndSettle();
    expect(find.text('Create Your Account'), findsOneWidget);
    expect(find.text('CONFIRM PASSWORD'), findsOneWidget);
  });

  testWidgets('HomeScreen loads and displays calendar, selected date, and month selector', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final repository = DayNoteRepositoryImpl();
    final viewModel = DayNoteViewModel(repository: repository);
    await viewModel.init();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(viewModel: viewModel),
      ),
    );
    await tester.pumpAndSettle();

    // Dismiss onboarding popup if present
    if (find.text('Start with Blank Journal').evaluate().isNotEmpty) {
      await tester.tap(find.text('Start with Blank Journal'));
      await tester.pumpAndSettle();
    }

    // Verify DaynoteAppBar brand title
    expect(find.text('DAYNOTE'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);

    // Verify calendar and empty state message
    expect(find.text('Nothing planned for this day.'), findsOneWidget);
    expect(find.text('+ Add Todo'), findsOneWidget);
    expect(find.text('+ Add Note'), findsOneWidget);

    // Tap dropdown arrow to open month/year selector
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();

    // Verify Month & Year navigation sheet is visible
    expect(find.text('NAVIGATE CALENDAR'), findsOneWidget);
    expect(find.text('December'), findsOneWidget);

    // Tap December
    await tester.tap(find.text('December'));
    await tester.pumpAndSettle();

    // Verify sheet closed and calendar updated to December
    expect(find.text('NAVIGATE CALENDAR'), findsNothing);
    expect(viewModel.currentMonth.month, equals(12));
  });

  testWidgets('TodoSection renders and allows adding todo with priority badge', (WidgetTester tester) async {
    final repository = DayNoteRepositoryImpl();
    final viewModel = DayNoteViewModel(repository: repository);
    await viewModel.init();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreen(viewModel: viewModel),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Dismiss onboarding popup
    if (find.text('Start with Blank Journal').evaluate().isNotEmpty) {
      await tester.tap(find.text('Start with Blank Journal'));
      await tester.pumpAndSettle();
    }

    // Click + Add Todo from empty state
    await tester.tap(find.text('+ Add Todo'));
    await tester.pumpAndSettle();

    // Enter todo text
    await tester.enterText(find.byType(TextField).first, 'Urgent client meeting');

    // Cycle priority from None -> High
    await tester.tap(find.text('None'));
    await tester.pumpAndSettle();
    expect(find.text('High'), findsOneWidget);

    // Tap Finished adding button
    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    // Verify todo with High badge exists
    expect(find.text('Urgent client meeting'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);

    // Tap High badge to cycle to Med
    await tester.tap(find.text('High'));
    await tester.pumpAndSettle();
    expect(find.text('Med'), findsOneWidget);

    // Tap delete button to open confirmation dialog
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Verify confirmation dialog appears
    expect(find.text('Delete item?'), findsOneWidget);
    expect(find.text('Are you sure you want to delete "Urgent client meeting"?'), findsOneWidget);

    // Tap Cancel -> todo remains
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Urgent client meeting'), findsOneWidget);

    // Tap delete again and confirm Delete -> todo is deleted
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Urgent client meeting'), findsNothing);
  });

  testWidgets('Onboarding walkthrough popup displays and loads sample data on request', (WidgetTester tester) async {
    final repository = DayNoteRepositoryImpl();
    final viewModel = DayNoteViewModel(repository: repository);
    await viewModel.init();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(viewModel: viewModel),
      ),
    );
    await tester.pumpAndSettle();

    // Verify onboarding popup appears
    expect(find.text('WELCOME TO DAYNOTE'), findsOneWidget);
    expect(find.text('The Daily Calendar'), findsOneWidget);
    expect(find.text('Explore with Sample Entries'), findsOneWidget);

    // Tap Explore with Sample Entries
    await tester.tap(find.text('Explore with Sample Entries'));
    await tester.pumpAndSettle();

    // Verify onboarding dismissed and sample todos/notes displayed
    expect(find.text('WELCOME TO DAYNOTE'), findsNothing);
    expect(find.text('Explore the month & year calendar navigation'), findsOneWidget);
    expect(find.textContaining('Welcome to your Daynote journal'), findsOneWidget);
  });

  testWidgets('TodoSection automatically capitalizes the first letter of submitted task sentences', (WidgetTester tester) async {
    final repository = DayNoteRepositoryImpl();
    final viewModel = DayNoteViewModel(repository: repository);
    await viewModel.init();
    await viewModel.dismissOnboarding(loadSampleData: false);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(viewModel: viewModel),
      ),
    );
    await tester.pumpAndSettle();

    // Click + Add Todo from empty state
    await tester.tap(find.text('+ Add Todo'));
    await tester.pumpAndSettle();

    // Type in all lowercase sentence
    await tester.enterText(find.byType(TextField).first, 'write quarterly performance reviews');
    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    // Verify it was capitalized to start with capital 'W'
    expect(find.text('Write quarterly performance reviews'), findsOneWidget);
  });
}



