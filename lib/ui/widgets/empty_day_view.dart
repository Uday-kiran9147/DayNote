import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmptyDayView extends StatelessWidget {
  final VoidCallback onAddTodo;
  final VoidCallback onAddNote;

  const EmptyDayView({
    super.key,
    required this.onAddTodo,
    required this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Simple, clean empty message
          Text(
            'Nothing planned for this day.',
            style: AppTheme.sansBody.copyWith(
              fontSize: 15,
              color: AppTheme.inkSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                label: '+ Add Todo',
                onTap: onAddTodo,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                label: '+ Add Note',
                onTap: onAddNote,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      splashColor: AppTheme.subtleHover,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: AppTheme.paperHighlight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppTheme.separatorBeige,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.sansButton.copyWith(
            fontSize: 13,
            color: AppTheme.inkPrimary,
          ),
        ),
      ),
    );
  }
}
