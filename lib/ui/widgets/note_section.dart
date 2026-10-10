import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NoteSection extends StatefulWidget {
  final String dateKey;
  final String note;
  final bool autoFocus;
  final ValueChanged<String> onNoteChanged;

  const NoteSection({
    super.key,
    required this.dateKey,
    required this.note,
    this.autoFocus = false,
    required this.onNoteChanged,
  });

  @override
  State<NoteSection> createState() => _NoteSectionState();
}

class _NoteSectionState extends State<NoteSection> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _noteContainerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note);
    _focusNode.addListener(_onFocusChanged);
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
          _scrollToNote();
        }
      });
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _scrollToNote();
    }
  }

  void _scrollToNote() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 180), () {
        if (!mounted) return;
        final targetContext = _noteContainerKey.currentContext;
        if (targetContext != null && targetContext.mounted) {
          Scrollable.ensureVisible(
            targetContext,
            alignment: 0.3,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant NoteSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dateKey != widget.dateKey ||
        (!_focusNode.hasFocus && _controller.text != widget.note)) {
      _controller.text = widget.note;
    }
    if (widget.autoFocus && !oldWidget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section Header: NOTES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NOTES',
                style: AppTheme.serifSectionTitle,
              ),
              Text(
                'Auto-saved',
                style: AppTheme.sansCaption.copyWith(
                  fontSize: 11,
                  color: AppTheme.inkDisabled,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Paper writing surface
          Container(
            key: _noteContainerKey,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: AppTheme.paperHighlight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppTheme.separatorBeige,
                width: 1.0,
              ),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              minLines: 4,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              style: AppTheme.sansNoteText,
              cursorColor: AppTheme.inkPrimary,
              scrollPadding: const EdgeInsets.only(top: 24, bottom: 120),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                hintText: 'Record your thoughts, reflections, or notes for the day...',
                hintStyle: AppTheme.sansNoteText.copyWith(
                  color: AppTheme.inkTertiary.withValues(alpha: 0.8),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onNoteChanged,
            ),
          ),
        ],
      ),
    );
  }
}
