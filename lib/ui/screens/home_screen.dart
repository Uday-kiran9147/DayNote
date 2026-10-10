import 'package:flutter/material.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/day_note_viewmodel.dart';
import '../theme/app_theme.dart';
import '../widgets/account_sheet.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/daynote_app_bar.dart';
import '../widgets/empty_day_view.dart';
import '../widgets/note_section.dart';
import '../widgets/selected_date_header.dart';
import '../widgets/todo_section.dart';

class HomeScreen extends StatefulWidget {
  final DayNoteViewModel viewModel;
  final AuthViewModel? authViewModel;

  const HomeScreen({
    super.key,
    required this.viewModel,
    this.authViewModel,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _forceShowTodoInput = false;
  bool _forceFocusNote = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelStateChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelStateChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onViewModelStateChanged() {
    if (widget.viewModel.errorMessage != null && mounted) {
      final msg = widget.viewModel.errorMessage!;
      widget.viewModel.clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: AppTheme.sansBody.copyWith(
              color: AppTheme.paperBackground,
              fontSize: 13,
            ),
          ),
          backgroundColor: AppTheme.inkPrimary,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _scrollToContent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          280.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;

        if (vm.isLoading) {
          return const Scaffold(
            backgroundColor: AppTheme.paperBackground,
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentBrown,
                strokeWidth: 2.0,
              ),
            ),
          );
        }

        final entry = vm.currentEntry;
        final hasTodos = entry.todos.isNotEmpty;
        final hasNotes = entry.note.trim().isNotEmpty;
        final isEmptyDay = !hasTodos && !hasNotes && !_forceShowTodoInput && !_forceFocusNote;

        return Scaffold(
          backgroundColor: AppTheme.paperBackground,
          body: SafeArea(
            child: Column(
              children: [
                // Refined Top App Bar
                DaynoteAppBar(
                  authViewModel: widget.authViewModel,
                  onGoToToday: vm.goToToday,
                  isTodaySelected: vm.isSelectedDateToday,
                ),

                // Main Scrollable Content
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // 1 & 2: Month & Calendar Grid
                      SliverToBoxAdapter(
                        child: CalendarWidget(
                          currentMonth: vm.currentMonth,
                          selectedDate: vm.selectedDate,
                          datesWithContent: vm.datesWithContent,
                          onDateSelected: (date) {
                            setState(() {
                              _forceShowTodoInput = false;
                              _forceFocusNote = false;
                            });
                            vm.selectDate(date);
                          },
                          onPreviousMonth: vm.previousMonth,
                          onNextMonth: vm.nextMonth,
                          onMonthYearChanged: vm.setMonthYear,
                          onGoToToday: vm.goToToday,
                          onOpenAccount: widget.authViewModel != null
                              ? () => AccountSheet.show(
                                    context,
                                    authViewModel: widget.authViewModel!,
                                  )
                              : null,
                        ),
                      ),

                // 3: Selected Date Separator & Prominent Date Header
                SliverToBoxAdapter(
                  child: SelectedDateHeader(
                    date: vm.selectedDate,
                    isToday: vm.isSelectedDateToday,
                  ),
                ),

                // 4: Daily Content (Empty State or Todos & Notes)
                if (isEmptyDay) ...[
                  SliverToBoxAdapter(
                    child: EmptyDayView(
                      onAddTodo: () {
                        setState(() {
                          _forceShowTodoInput = true;
                        });
                        _scrollToContent();
                      },
                      onAddNote: () {
                        setState(() {
                          _forceFocusNote = true;
                        });
                        _scrollToContent();
                      },
                    ),
                  ),
                ] else ...[
                  // TODO Section (Shown if has todos or if user clicked Add Todo)
                  SliverToBoxAdapter(
                    child: TodoSection(
                      todos: entry.todos,
                      isAddingInitial: _forceShowTodoInput,
                      onAddTodo: (text, priority) {
                        vm.addTodo(text, priority: priority);
                        setState(() {
                          _forceShowTodoInput = false;
                        });
                      },
                      onToggleTodo: vm.toggleTodo,
                      onUpdateTodo: vm.updateTodoText,
                      onUpdatePriority: vm.updateTodoPriority,
                      onDeleteTodo: vm.deleteTodo,
                      onCancelAdd: () {
                        setState(() {
                          _forceShowTodoInput = false;
                        });
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Divider(height: 1),
                    ),
                  ),

                  // NOTES Section (Shown always when not empty or when activated)
                  SliverToBoxAdapter(
                    child: NoteSection(
                      key: ValueKey('note_${entry.dateKey}'),
                      dateKey: entry.dateKey,
                      note: entry.note,
                      autoFocus: _forceFocusNote,
                      onNoteChanged: vm.onNoteChanged,
                    ),
                  ),
                ],

                // Extra padding for comfortable keyboard typing & scrolling
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
},
);
  }
}
