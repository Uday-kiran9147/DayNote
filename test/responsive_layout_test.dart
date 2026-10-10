import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daynote/data/models/todo_item.dart';
import 'package:daynote/data/repositories/day_note_repository_impl.dart';
import 'package:daynote/data/services/mock_auth_service.dart';
import 'package:daynote/ui/screens/auth_screen.dart';
import 'package:daynote/ui/screens/home_screen.dart';
import 'package:daynote/viewmodels/auth_viewmodel.dart';
import 'package:daynote/viewmodels/day_note_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Responsive & Adaptive Layout Tests', () {
    testWidgets('HomeScreen renders without overflow on ultra-narrow 320px phone screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repository = DayNoteRepositoryImpl();
      final viewModel = DayNoteViewModel(repository: repository);
      await viewModel.init();
      // Dismiss onboarding
      await viewModel.dismissOnboarding(loadSampleData: true);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(viewModel: viewModel),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DAYNOTE'), findsOneWidget);
      expect(find.text('TODO'), findsOneWidget);

      // Scroll down on 568px small screen to reveal NOTES section
      await tester.scrollUntilVisible(
        find.text('NOTES'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('NOTES'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HomeScreen renders with centered constraint on tablet & desktop widescreen (1440x900)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repository = DayNoteRepositoryImpl();
      final viewModel = DayNoteViewModel(repository: repository);
      await viewModel.init();
      await viewModel.dismissOnboarding(loadSampleData: true);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(viewModel: viewModel),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DAYNOTE'), findsOneWidget);
      expect(find.text('TODO'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify ConstrainedBox maxWidth is 720
      final constrainedBoxes = tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
      final has720Constraint = constrainedBoxes.any((box) => box.constraints.maxWidth == 720);
      expect(has720Constraint, isTrue);
    });

    testWidgets('HomeScreen and TodoSection render cleanly under high font scaling (1.8x)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repository = DayNoteRepositoryImpl();
      final viewModel = DayNoteViewModel(repository: repository);
      await viewModel.init();
      viewModel.dismissOnboarding(loadSampleData: false);

      // Add long todo with High priority
      await viewModel.addTodo(
        'Review quarterly product roadmap and prioritize engineering sprint backlog items',
        priority: TodoPriority.high,
      );

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.8),
              ),
              child: child!,
            );
          },
          home: HomeScreen(viewModel: viewModel),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('High'), findsOneWidget);
      expect(find.textContaining('Review quarterly product roadmap'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AuthScreen renders centered within 440px constraint and without overflow across screen sizes', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockAuth = MockAuthService();
      final authViewModel = AuthViewModel(authService: mockAuth);

      await tester.pumpWidget(
        MaterialApp(
          home: AuthScreen(authViewModel: authViewModel),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DAYNOTE'), findsOneWidget);
      expect(find.text('Sign In to Your Journal'), findsOneWidget);

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
      final has440Constraint = constrainedBoxes.any((box) => box.constraints.maxWidth == 440);
      expect(has440Constraint, isTrue);
      expect(tester.takeException(), isNull);
    });
  });
}
