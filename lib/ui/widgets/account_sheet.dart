import 'package:flutter/material.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../theme/app_theme.dart';

class AccountSheet extends StatelessWidget {
  final AuthViewModel authViewModel;
  final VoidCallback? onOpenWalkthrough;

  const AccountSheet({
    super.key,
    required this.authViewModel,
    this.onOpenWalkthrough,
  });

  static Future<void> show(
    BuildContext context, {
    required AuthViewModel authViewModel,
    VoidCallback? onOpenWalkthrough,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.paperBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AccountSheet(
        authViewModel: authViewModel,
        onOpenWalkthrough: onOpenWalkthrough,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authViewModel.currentUser;
    final email = user?.email ?? 'Journalist';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
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
            const SizedBox(height: 16),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YOUR JOURNAL ACCOUNT',
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

            const SizedBox(height: 14),

            // User Info Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppTheme.paperHighlight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.separatorBeige),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: AppTheme.inkPrimary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      email.isNotEmpty ? email[0].toUpperCase() : 'D',
                      style: AppTheme.serifHeading.copyWith(
                        color: AppTheme.paperBackground,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Signed in as',
                          style: AppTheme.sansCaption.copyWith(
                            fontSize: 11,
                            color: AppTheme.inkTertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: AppTheme.sansBody.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (onOpenWalkthrough != null) ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.inkPrimary,
                  side: const BorderSide(color: AppTheme.separatorBeige, width: 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.help_outline, size: 18, color: AppTheme.accentBrown),
                label: Text(
                  'How to Use Daynote',
                  style: AppTheme.sansButton.copyWith(
                    color: AppTheme.inkPrimary,
                    fontSize: 13.5,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onOpenWalkthrough?.call();
                },
              ),
              const SizedBox(height: 10),
            ],

            // Sign Out Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF9E3821),
                side: const BorderSide(color: Color(0xFFD98A72), width: 1.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.logout, size: 18),
              label: Text(
                'Sign Out',
                style: AppTheme.sansButton.copyWith(
                  color: const Color(0xFF9E3821),
                  fontSize: 13.5,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await authViewModel.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
