import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/todo_item.dart';
import '../theme/app_theme.dart';
import 'classic_checkbox.dart';

class TodoSection extends StatefulWidget {
  final List<TodoItem> todos;
  final bool isAddingInitial;
  final void Function(String text, TodoPriority priority) onAddTodo;
  final ValueChanged<String> onToggleTodo;
  final Function(String id, String newText) onUpdateTodo;
  final Function(String id, TodoPriority priority)? onUpdatePriority;
  final ValueChanged<String> onDeleteTodo;
  final VoidCallback? onCancelAdd;

  const TodoSection({
    super.key,
    required this.todos,
    this.isAddingInitial = false,
    required this.onAddTodo,
    required this.onToggleTodo,
    required this.onUpdateTodo,
    this.onUpdatePriority,
    required this.onDeleteTodo,
    this.onCancelAdd,
  });

  @override
  State<TodoSection> createState() => _TodoSectionState();
}

class _TodoSectionState extends State<TodoSection> {
  final TextEditingController _addController = TextEditingController();
  final FocusNode _addFocusNode = FocusNode();
  final GlobalKey _addInputKey = GlobalKey();
  TodoPriority _selectedPriority = TodoPriority.none;
  bool _isInputActive = false;

  String? _editingTodoId;
  TodoPriority _editingPriority = TodoPriority.none;
  final TextEditingController _editController = TextEditingController();
  final FocusNode _editFocusNode = FocusNode();
  final GlobalKey _editInputKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _addFocusNode.addListener(_onAddFocusChanged);
    _editFocusNode.addListener(_onEditFocusChanged);

    if (widget.isAddingInitial) {
      _isInputActive = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addFocusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant TodoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAddingInitial && !oldWidget.isAddingInitial) {
      setState(() {
        _isInputActive = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _addFocusNode.removeListener(_onAddFocusChanged);
    _editFocusNode.removeListener(_onEditFocusChanged);
    _addController.dispose();
    _addFocusNode.dispose();
    _editController.dispose();
    _editFocusNode.dispose();
    super.dispose();
  }

  void _onAddFocusChanged() {
    if (_addFocusNode.hasFocus) {
      _scrollToKey(_addInputKey);
    }
  }

  void _onEditFocusChanged() {
    if (_editFocusNode.hasFocus) {
      _scrollToKey(_editInputKey);
    }
  }

  void _scrollToKey(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Delay slightly for keyboard animation to settle
      Future.delayed(const Duration(milliseconds: 180), () {
        if (!mounted) return;
        final targetContext = key.currentContext;
        if (targetContext != null && targetContext.mounted) {
          Scrollable.ensureVisible(
            targetContext,
            alignment: 0.5,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      });
    });
  }

  TodoPriority _cyclePriority(TodoPriority current) {
    switch (current) {
      case TodoPriority.none:
        return TodoPriority.high;
      case TodoPriority.high:
        return TodoPriority.medium;
      case TodoPriority.medium:
        return TodoPriority.low;
      case TodoPriority.low:
        return TodoPriority.none;
    }
  }

  void _submitNewTodo() {
    final text = _addController.text.trim();
    if (text.isNotEmpty) {
      widget.onAddTodo(text, _selectedPriority);
      _addController.clear();
      setState(() {
        _selectedPriority = TodoPriority.none;
      });
      // Keep focus to allow typing the next todo effortlessly and keep field visible above keyboard
      _addFocusNode.requestFocus();
      _scrollToKey(_addInputKey);
    }
  }

  void _finishAdding() {
    final text = _addController.text.trim();
    if (text.isNotEmpty) {
      widget.onAddTodo(text, _selectedPriority);
      _addController.clear();
    }
    setState(() {
      _selectedPriority = TodoPriority.none;
      _isInputActive = false;
    });
    widget.onCancelAdd?.call();
  }

  void _startEditing(TodoItem todo) {
    setState(() {
      _editingTodoId = todo.id;
      _editingPriority = todo.priority;
      _editController.text = todo.text;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editFocusNode.requestFocus();
      _scrollToKey(_editInputKey);
    });
  }

  Future<bool> _confirmDeleteTodo(BuildContext context, TodoItem todo) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.paperBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppTheme.separatorBeige),
        ),
        title: Text(
          'Delete item?',
          style: AppTheme.serifHeading.copyWith(fontSize: 17),
        ),
        content: Text(
          'Are you sure you want to delete "${todo.text}"?',
          style: AppTheme.sansBody.copyWith(
            color: AppTheme.inkSecondary,
            fontSize: 14,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTheme.sansButton.copyWith(
                color: AppTheme.inkSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.priorityHigh,
            ),
            child: Text(
              'Delete',
              style: AppTheme.sansButton.copyWith(
                color: AppTheme.priorityHigh,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _submitEditing(String id) async {
    final text = _editController.text.trim();
    if (text.isNotEmpty) {
      widget.onUpdateTodo(id, text);
      if (widget.onUpdatePriority != null && _editingPriority != widget.todos.firstWhere((t) => t.id == id).priority) {
        widget.onUpdatePriority!(id, _editingPriority);
      }
      setState(() {
        _editingTodoId = null;
      });
    } else {
      final todo = widget.todos.firstWhere((t) => t.id == id);
      final confirmed = await _confirmDeleteTodo(context, todo);
      if (confirmed) {
        widget.onDeleteTodo(id);
        setState(() {
          _editingTodoId = null;
        });
      }
    }
  }

  Widget _buildPriorityBadge(TodoPriority priority, {VoidCallback? onTap, bool showNone = false}) {
    if (priority == TodoPriority.none && !showNone) {
      return const SizedBox.shrink();
    }

    Color textColor;
    Color bgColor;
    String label;
    IconData? icon;

    switch (priority) {
      case TodoPriority.high:
        textColor = AppTheme.priorityHigh;
        bgColor = AppTheme.priorityHighBg;
        label = 'High';
        break;
      case TodoPriority.medium:
        textColor = AppTheme.priorityMed;
        bgColor = AppTheme.priorityMedBg;
        label = 'Med';
        break;
      case TodoPriority.low:
        textColor = AppTheme.priorityLow;
        bgColor = AppTheme.priorityLowBg;
        label = 'Low';
        break;
      case TodoPriority.none:
        textColor = AppTheme.inkTertiary;
        bgColor = AppTheme.subtleHover;
        label = 'None';
        icon = Icons.outlined_flag;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: textColor),
                const SizedBox(width: 3),
              ],
              Text(
                label,
                style: AppTheme.sansCaption.copyWith(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section Header: TODO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TODO',
                style: AppTheme.serifSectionTitle,
              ),
              if (!_isInputActive)
                InkWell(
                  onTap: () {
                    setState(() {
                      _isInputActive = true;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _addFocusNode.requestFocus();
                      _scrollToKey(_addInputKey);
                    });
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add,
                          size: 15,
                          color: AppTheme.accentBrown,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Add item',
                          style: AppTheme.sansCaption.copyWith(
                            color: AppTheme.accentBrown,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // List of Todos
          if (widget.todos.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.todos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final todo = widget.todos[index];
                return _buildTodoItemRow(todo);
              },
            ),

          // Inline Add Field
          if (_isInputActive) ...[
            if (widget.todos.isNotEmpty) const SizedBox(height: 6),
            _buildInlineAddInput(),
          ],
        ],
      ),
    );
  }

  Widget _buildTodoItemRow(TodoItem todo) {
    final isEditing = _editingTodoId == todo.id;

    if (isEditing) {
      return Container(
        key: _editInputKey,
        margin: const EdgeInsets.symmetric(vertical: 2.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: AppTheme.paperSurface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.separatorBeige),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _editController,
                focusNode: _editFocusNode,
                style: AppTheme.sansBody,
                textInputAction: TextInputAction.done,
                scrollPadding: const EdgeInsets.only(top: 24, bottom: 120),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(TodoItem.maxTextLength),
                ],
                maxLength: TodoItem.maxTextLength,
                buildCounter: (context, {required currentLength, required isFocused, required maxLength}) => null,
                onSubmitted: (_) => _submitEditing(todo.id),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(width: 4),
            _buildPriorityBadge(
              _editingPriority,
              showNone: true,
              onTap: () {
                setState(() {
                  _editingPriority = _cyclePriority(_editingPriority);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.check, size: 18, color: AppTheme.inkPrimary),
              onPressed: () => _submitEditing(todo.id),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: AppTheme.inkTertiary),
              onPressed: () => setState(() => _editingTodoId = null),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      );
    }

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 12.0),
        decoration: BoxDecoration(
          color: AppTheme.subtleHover,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.delete_outline,
          size: 18,
          color: AppTheme.accentBrown,
        ),
      ),
      confirmDismiss: (_) => _confirmDeleteTodo(context, todo),
      onDismissed: (_) => widget.onDeleteTodo(todo.id),
      child: InkWell(
        onTap: () => widget.onToggleTodo(todo.id),
        onLongPress: () => _startEditing(todo),
        borderRadius: BorderRadius.circular(4),
        splashColor: AppTheme.subtleHover,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClassicCheckbox(
                value: todo.isDone,
                onChanged: (_) => widget.onToggleTodo(todo.id),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        todo.text,
                        style: todo.isDone ? AppTheme.sansBodyDone : AppTheme.sansBody,
                      ),
                    ),
                    if (todo.priority != TodoPriority.none) ...[
                      const SizedBox(width: 8),
                      _buildPriorityBadge(
                        todo.priority,
                        onTap: () {
                          final next = _cyclePriority(todo.priority);
                          widget.onUpdatePriority?.call(todo.id, next);
                        },
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 14,
                  color: AppTheme.inkDisabled,
                ),
                tooltip: 'Delete item',
                splashRadius: 16,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                onPressed: () async {
                  final confirmed = await _confirmDeleteTodo(context, todo);
                  if (confirmed) {
                    widget.onDeleteTodo(todo.id);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInlineAddInput() {
    return Container(
      key: _addInputKey,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppTheme.paperHighlight,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppTheme.separatorBeige,
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(
              Icons.radio_button_unchecked,
              size: 17,
              color: AppTheme.inkDisabled,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _addController,
              focusNode: _addFocusNode,
              style: AppTheme.sansBody,
              textInputAction: TextInputAction.next,
              scrollPadding: const EdgeInsets.only(top: 24, bottom: 120),
              inputFormatters: [
                LengthLimitingTextInputFormatter(TodoItem.maxTextLength),
              ],
              maxLength: TodoItem.maxTextLength,
              buildCounter: (context, {required currentLength, required isFocused, required maxLength}) => null,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                hintText: 'What needs to be done?',
                hintStyle: AppTheme.sansBody.copyWith(
                  color: AppTheme.inkTertiary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                counterText: '',
              ),
              onSubmitted: (_) => _submitNewTodo(),
            ),
          ),
          const SizedBox(width: 4),
          // Priority Selector Pill
          _buildPriorityBadge(
            _selectedPriority,
            showNone: true,
            onTap: () {
              setState(() {
                _selectedPriority = _cyclePriority(_selectedPriority);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward, size: 16, color: AppTheme.accentBrown),
            tooltip: 'Add & Continue',
            visualDensity: VisualDensity.compact,
            onPressed: _submitNewTodo,
          ),
          IconButton(
            icon: const Icon(Icons.done, size: 18, color: AppTheme.inkPrimary),
            tooltip: 'Finished adding',
            visualDensity: VisualDensity.compact,
            onPressed: _finishAdding,
          ),
        ],
      ),
    );
  }
}
