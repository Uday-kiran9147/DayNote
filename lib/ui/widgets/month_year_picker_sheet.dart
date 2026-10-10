import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MonthYearPickerSheet extends StatefulWidget {
  final DateTime initialMonth;
  final Function(int year, int month) onSelected;

  const MonthYearPickerSheet({
    super.key,
    required this.initialMonth,
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime initialMonth,
    required Function(int year, int month) onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.paperBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => MonthYearPickerSheet(
        initialMonth: initialMonth,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<MonthYearPickerSheet> createState() => _MonthYearPickerSheetState();
}

class _MonthYearPickerSheetState extends State<MonthYearPickerSheet> {
  late int _selectedYear;
  late int _selectedMonth;
  bool _isSelectingYearList = false;

  final List<String> _months = const [
    'January', 'February', 'March',
    'April', 'May', 'June',
    'July', 'August', 'September',
    'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialMonth.year;
    _selectedMonth = widget.initialMonth.month;
  }

  void _selectMonth(int month) {
    widget.onSelected(_selectedYear, month);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.separatorBeige,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Top Bar: Title & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NAVIGATE CALENDAR',
                  style: AppTheme.serifSectionTitle.copyWith(
                    fontSize: 15,
                    letterSpacing: 1.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppTheme.inkSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Year selector header bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.paperHighlight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.separatorBeige),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppTheme.inkPrimary),
                    tooltip: 'Previous Year',
                    onPressed: () {
                      setState(() {
                        _selectedYear--;
                      });
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isSelectingYearList = !_isSelectingYearList;
                      });
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_selectedYear',
                            style: AppTheme.serifMonth.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _isSelectingYearList
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            size: 20,
                            color: AppTheme.accentBrown,
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: AppTheme.inkPrimary),
                    tooltip: 'Next Year',
                    onPressed: () {
                      setState(() {
                        _selectedYear++;
                      });
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Year List Grid OR Month Matrix
            if (_isSelectingYearList)
              SizedBox(
                height: 220,
                child: _buildYearsGrid(),
              )
            else
              _buildMonthsGrid(now),

            const SizedBox(height: 16),

            // Footer actions: Jump to Today
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.inkPrimary,
                      side: const BorderSide(color: AppTheme.separatorBeige),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      final today = DateTime.now();
                      widget.onSelected(today.year, today.month);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Jump to Today (${_months[now.month - 1]} ${now.year})',
                      style: AppTheme.sansButton.copyWith(
                        color: AppTheme.accentBrown,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearsGrid() {
    final currentYear = DateTime.now().year;
    final years = List.generate(25, (index) => (currentYear - 12) + index);

    return GridView.builder(
      shrinkWrap: true,
      itemCount: years.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.8,
      ),
      itemBuilder: (context, index) {
        final year = years[index];
        final isSelected = year == _selectedYear;
        final isCurrentYear = year == DateTime.now().year;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedYear = year;
              _isSelectingYearList = false;
            });
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.inkPrimary
                  : (isCurrentYear ? AppTheme.subtleHover : AppTheme.paperHighlight),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected
                    ? AppTheme.inkPrimary
                    : (isCurrentYear ? AppTheme.accentBrownLight : AppTheme.separatorBeige),
              ),
            ),
            child: Text(
              '$year',
              style: AppTheme.sansBody.copyWith(
                color: isSelected ? AppTheme.paperBackground : AppTheme.inkPrimary,
                fontWeight: isSelected || isCurrentYear ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthsGrid(DateTime now) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.1,
      ),
      itemBuilder: (context, index) {
        final monthIndex = index + 1;
        final isSelected =
            _selectedYear == widget.initialMonth.year && monthIndex == _selectedMonth;
        final isCurrentMonth =
            _selectedYear == now.year && monthIndex == now.month;

        return InkWell(
          onTap: () => _selectMonth(monthIndex),
          borderRadius: BorderRadius.circular(6),
          splashColor: AppTheme.subtleHover,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.inkPrimary : AppTheme.paperHighlight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected
                    ? AppTheme.inkPrimary
                    : (isCurrentMonth ? AppTheme.accentBrown : AppTheme.separatorBeige),
                width: isCurrentMonth && !isSelected ? 1.4 : 1.0,
              ),
            ),
            child: Text(
              _months[index],
              style: AppTheme.sansBody.copyWith(
                color: isSelected ? AppTheme.paperBackground : AppTheme.inkPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
