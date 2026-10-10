import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ClassicCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ClassicCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      splashColor: AppTheme.subtleHover,
      highlightColor: AppTheme.subtleHover,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          width: 19,
          height: 19,
          decoration: BoxDecoration(
            color: value ? AppTheme.inkPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: value ? AppTheme.inkPrimary : AppTheme.inkSecondary,
              width: 1.3,
            ),
          ),
          alignment: Alignment.center,
          child: value
              ? const Icon(
                  Icons.check,
                  size: 13,
                  color: AppTheme.paperBackground,
                )
              : null,
        ),
      ),
    );
  }
}
