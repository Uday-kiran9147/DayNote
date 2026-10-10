import '../models/day_entry.dart';
import '../models/todo_item.dart';

abstract class DayNoteRepository {
  Future<void> initialize();
  void setUserId(String? userId);
  Future<DayEntry> getDayEntry(DateTime date);
  Future<void> saveDayEntry(DayEntry entry);
  Future<Set<String>> getDatesWithContent();
  Future<DayEntry> addTodo(DateTime date, String text, {TodoPriority priority = TodoPriority.none});
  Future<DayEntry> toggleTodo(DateTime date, String todoId);
  Future<DayEntry> updateTodoText(DateTime date, String todoId, String newText);
  Future<DayEntry> updateTodoPriority(DateTime date, String todoId, TodoPriority priority);
  Future<DayEntry> deleteTodo(DateTime date, String todoId);
  Future<DayEntry> reorderTodos(DateTime date, int oldIndex, int newIndex);
  Future<DayEntry> updateNote(DateTime date, String noteText);
}

