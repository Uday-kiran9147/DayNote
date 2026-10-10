import 'package:flutter/material.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../theme/app_theme.dart';

enum AuthMode { signIn, signUp, forgotPassword }

class AuthScreen extends StatefulWidget {
  final AuthViewModel authViewModel;

  const AuthScreen({
    super.key,
    required this.authViewModel,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _mode = AuthMode.signIn;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    widget.authViewModel.clearMessages();
    setState(() {
      _mode = mode;
    });
  }

  Future<void> _handleSubmit() async {
    final vm = widget.authViewModel;
    final email = _emailController.text;
    final password = _passwordController.text;

    if (_mode == AuthMode.signIn) {
      await vm.signIn(email: email, password: password);
    } else if (_mode == AuthMode.signUp) {
      await vm.signUp(
        email: email,
        password: password,
        confirmPassword: _confirmPasswordController.text,
      );
    } else if (_mode == AuthMode.forgotPassword) {
      await vm.sendPasswordReset(email: email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.paperBackground,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              physics: const BouncingScrollPhysics(),
            child: ListenableBuilder(
              listenable: widget.authViewModel,
              builder: (context, _) {
                final vm = widget.authViewModel;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand / Logo Title
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppTheme.inkPrimary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'D',
                                  style: AppTheme.sansButton.copyWith(
                                    color: AppTheme.paperBackground,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'DAYNOTE',
                                style: AppTheme.serifHeading.copyWith(
                                  fontSize: 26,
                                  letterSpacing: 3.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'A digital sanctuary for daily reflections & thoughts',
                            style: AppTheme.sansBody.copyWith(
                              fontSize: 13.5,
                              color: AppTheme.inkSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Full-width form header
                    Text(
                      _mode == AuthMode.signIn
                          ? 'Sign In to Your Journal'
                          : _mode == AuthMode.signUp
                              ? 'Create Your Account'
                              : 'Reset Password',
                      style: AppTheme.serifHeading.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _mode == AuthMode.forgotPassword
                          ? 'Enter your registered email address and we will send you a link to reset your password.'
                          : 'Your private thoughts and daily plans, securely preserved.',
                      style: AppTheme.sansBody.copyWith(
                        fontSize: 13,
                        color: AppTheme.inkSecondary,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Error Message Banner
                    if (vm.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9EAE1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: const Color(0xFFD98A72), width: 0.8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 16, color: Color(0xFF9E3821)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                vm.errorMessage!,
                                style: AppTheme.sansBody.copyWith(
                                  fontSize: 13,
                                  color: const Color(0xFF9E3821),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Success Message Banner
                    if (vm.successMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF3E8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: const Color(0xFF8DB87E), width: 0.8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 16, color: Color(0xFF386826)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                vm.successMessage!,
                                style: AppTheme.sansBody.copyWith(
                                  fontSize: 13,
                                  color: const Color(0xFF386826),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email Field
                    _buildTextField(
                      controller: _emailController,
                      label: 'EMAIL ADDRESS',
                      hint: 'your.name@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline,
                    ),

                    // Password Field (Sign In & Sign Up)
                    if (_mode != AuthMode.forgotPassword) ...[
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'PASSWORD',
                        hint: '••••••••',
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppTheme.inkTertiary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ],

                    // Confirm Password Field (Sign Up only)
                    if (_mode == AuthMode.signUp) ...[
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'CONFIRM PASSWORD',
                        hint: '••••••••',
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppTheme.inkTertiary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ],

                    // Forgot Password link (in Sign In mode)
                    if (_mode == AuthMode.signIn) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () => _switchMode(AuthMode.forgotPassword),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 2.0),
                            child: Text(
                              'Forgot password?',
                              style: AppTheme.sansCaption.copyWith(
                                color: AppTheme.accentBrown,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Full-width Submit Button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.inkPrimary,
                          foregroundColor: AppTheme.paperBackground,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: vm.isLoading ? null : _handleSubmit,
                        child: vm.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.paperBackground,
                                ),
                              )
                            : Text(
                                _mode == AuthMode.signIn
                                    ? 'Sign In'
                                    : _mode == AuthMode.signUp
                                        ? 'Create Account'
                                        : 'Send Reset Link',
                                style: AppTheme.sansButton.copyWith(
                                  color: AppTheme.paperBackground,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Toggle mode footer
                    Center(
                      child: _mode == AuthMode.signIn
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account?",
                                  style: AppTheme.sansBody.copyWith(
                                    fontSize: 13.5,
                                    color: AppTheme.inkSecondary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => _switchMode(AuthMode.signUp),
                                  child: Text(
                                    'Create one',
                                    style: AppTheme.sansButton.copyWith(
                                      fontSize: 13.5,
                                      color: AppTheme.accentBrown,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : InkWell(
                              onTap: () => _switchMode(AuthMode.signIn),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 12.0),
                                child: Text(
                                  '← Back to Sign In',
                                  style: AppTheme.sansButton.copyWith(
                                    fontSize: 13.5,
                                    color: AppTheme.accentBrown,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.sansCaption.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.inkSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.paperHighlight,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppTheme.separatorBeige,
              width: 1.0,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: AppTheme.sansBody,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.sansBody.copyWith(
                color: AppTheme.inkDisabled,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, size: 18, color: AppTheme.inkTertiary)
                  : null,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
