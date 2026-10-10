import 'package:flutter/material.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../theme/app_theme.dart';
import 'account_sheet.dart';

class DaynoteAppBar extends StatelessWidget {
  final AuthViewModel? authViewModel;
  final VoidCallback onGoToToday;
  final bool isTodaySelected;

  const DaynoteAppBar({
    super.key,
    this.authViewModel,
    required this.onGoToToday,
    this.isTodaySelected = true,
  });

  @override
  Widget build(BuildContext context) {
    final user = authViewModel?.currentUser;
    final email = user?.email ?? '';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : 'D';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: AppTheme.paperBackground,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.separatorBeige,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Brand Logo & Title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.inkPrimary,
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: Text(
                  'D',
                  style: AppTheme.sansButton.copyWith(
                    color: AppTheme.paperBackground,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Text(
                'DAYNOTE',
                style: AppTheme.sansBody.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 2.0,
                  color: AppTheme.inkPrimary,
                ),
              ),
            ],
          ),

          // Right: Today Shortcut & Account
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Jump to Today Pill Button (highlighted when not on today)
              InkWell(
                onTap: onGoToToday,
                borderRadius: BorderRadius.circular(6),
                splashColor: AppTheme.subtleHover,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isTodaySelected
                        ? AppTheme.paperHighlight
                        : AppTheme.subtleHover,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isTodaySelected
                          ? AppTheme.separatorBeige
                          : AppTheme.accentBrownLight,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.today_outlined,
                        size: 14,
                        color: isTodaySelected
                            ? AppTheme.inkSecondary
                            : AppTheme.accentBrown,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Today',
                        style: AppTheme.sansCaption.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isTodaySelected
                              ? AppTheme.inkPrimary
                              : AppTheme.accentBrown,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Account Avatar Button
              if (authViewModel != null) ...[
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => AccountSheet.show(
                    context,
                    authViewModel: authViewModel!,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  splashColor: AppTheme.subtleHover,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppTheme.paperHighlight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.separatorBeige,
                        width: 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: AppTheme.sansBody.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.inkPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
