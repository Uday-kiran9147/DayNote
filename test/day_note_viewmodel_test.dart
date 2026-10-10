import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daynote/data/models/day_entry.dart';
import 'package:daynote/data/models/todo_item.dart';
import 'package:daynote/data/repositories/day_note_repository_impl.dart';
import 'package:daynote/viewmodels/day_note_viewmodel.dart';



void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('DayNoteViewModel initializes and handles todo/note operations correctly', () async {
    final repository = DayNoteRepositoryImpl();
    final viewModel = DayNoteViewModel(repository: repository);
    await viewModel.init();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.selectedDate, isNotNull);

    // Starts fresh with no seeded data
    expect(viewModel.currentEntry.todos.isEmpty, isTrue);

    // Add todo with priority
    await viewModel.addTodo('Buy fountain pen ink', priority: TodoPriority.high);
    expect(viewModel.currentEntry.todos.length, equals(1));
    expect(viewModel.currentEntry.todos.first.text, equals('Buy fountain pen ink'));
    expect(viewModel.currentEntry.todos.first.isDone, isFalse);
    expect(viewModel.currentEntry.todos.first.priority, equals(TodoPriority.high));

    // Todo text length limiting test
    final overlyLongText = 'A' * 200;
    await viewModel.addTodo(overlyLongText);
    expect(viewModel.currentEntry.todos.last.text.length, equals(TodoItem.maxTextLength));
    expect(viewModel.currentEntry.todos.last.text, equals('A' * TodoItem.maxTextLength));

    // Update todo priority
    final todoId = viewModel.currentEntry.todos.first.id;
    await viewModel.updateTodoPriority(todoId, TodoPriority.medium);
    expect(viewModel.currentEntry.todos.first.priority, equals(TodoPriority.medium));

    // Toggle todo
    await viewModel.toggleTodo(todoId);
    expect(viewModel.currentEntry.todos.first.isDone, isTrue);

    // Update note
    viewModel.onNoteChanged('Writing on ivory paper.');
    expect(viewModel.currentEntry.note, equals('Writing on ivory paper.'));

    // Switch date
    final tomorrow = viewModel.selectedDate.add(const Duration(days: 1));
    await viewModel.selectDate(tomorrow);
    expect(viewModel.selectedDate.day, equals(tomorrow.day));
    expect(viewModel.currentEntry.todos.isEmpty, isTrue);
    expect(viewModel.currentEntry.note.isEmpty, isTrue);
  });

  test('DayNoteViewModel handles month & year navigation and selector correctly', () async {
    final repository = DayNoteRepositoryImpl();
    final viewModel = DayNoteViewModel(repository: repository);
    await viewModel.init();

    final currentYear = viewModel.currentMonth.year;
    final currentMonth = viewModel.currentMonth.month;

    // Previous month
    viewModel.previousMonth();
    if (currentMonth == 1) {
      expect(viewModel.currentMonth.month, equals(12));
      expect(viewModel.currentMonth.year, equals(currentYear - 1));
    } else {
      expect(viewModel.currentMonth.month, equals(currentMonth - 1));
    }

    // Set arbitrary Month and Year (e.g. October 2028)
    viewModel.setMonthYear(2028, 10);
    expect(viewModel.currentMonth.year, equals(2028));
    expect(viewModel.currentMonth.month, equals(10));

    // Return to today
    await viewModel.goToToday();
    final now = DateTime.now();
    expect(viewModel.currentMonth.year, equals(now.year));
    expect(viewModel.currentMonth.month, equals(now.month));
  });

  test('DayNoteViewModel rolls back optimistically when repository throws errors', () async {
    final failingRepo = FailingDayNoteRepository();
    final viewModel = DayNoteViewModel(repository: failingRepo);
    await viewModel.init();

    expect(viewModel.currentEntry.todos.isEmpty, isTrue);

    // 1. Add todo fails and rolls back
    await viewModel.addTodo('Will fail saving');
    expect(viewModel.currentEntry.todos.isEmpty, isTrue);
    expect(viewModel.errorMessage, isNotNull);

    viewModel.clearError();
    expect(viewModel.errorMessage, isNull);
  });
}

class FailingDayNoteRepository extends DayNoteRepositoryImpl {
  @override
  Future<void> initialize() async {}

  @override
  Future<DayEntry> getDayEntry(DateTime date) async {
    return DayEntry.empty(date);
  }

  @override
  Future<Set<String>> getDatesWithContent() async {
    return {};
  }

  @override
  Future<DayEntry> addTodo(DateTime date, String text, {TodoPriority priority = TodoPriority.none}) async {
    throw Exception('Simulated network/disk write failure');
  }

  @override
  Future<DayEntry> toggleTodo(DateTime date, String todoId) async {
    throw Exception('Simulated toggle failure');
  }
}


