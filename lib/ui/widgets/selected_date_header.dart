import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class SelectedDateHeader extends StatelessWidget {
  final DateTime date;
  final bool isToday;

  const SelectedDateHeader({
    super.key,
    required this.date,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('EEEE, MMMM d');
    final yearFormat = DateFormat('y');

    final formattedDay = dayFormat.format(date);
    final formattedYear = yearFormat.format(date);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      decoration: const BoxDecoration(
        color: AppTheme.paperBackground,
        border: Border(
          top: BorderSide(color: AppTheme.separatorBeige, width: 1.0),
          bottom: BorderSide(color: AppTheme.separatorBeige, width: 1.0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        formattedDay,
                        style: AppTheme.serifSelectedDate,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.subtleHover,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppTheme.accentBrownLight,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'TODAY',
                          style: AppTheme.sansCaption.copyWith(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentBrown,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  formattedYear,
                  style: AppTheme.serifSelectedYear,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
