import 'package:flutter/material.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/day_note_viewmodel.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class AuthGate extends StatefulWidget {
  final AuthViewModel authViewModel;
  final DayNoteViewModel dayNoteViewModel;

  const AuthGate({
    super.key,
    required this.authViewModel,
    required this.dayNoteViewModel,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    _syncUser();
    widget.authViewModel.addListener(_handleAuthChange);
  }

  @override
  void dispose() {
    widget.authViewModel.removeListener(_handleAuthChange);
    super.dispose();
  }

  void _handleAuthChange() {
    _syncUser();
  }

  void _syncUser() {
    final currentUid = widget.authViewModel.currentUser?.uid;
    if (currentUid != _lastUserId) {
      _lastUserId = currentUid;
      widget.dayNoteViewModel.updateUserContext(currentUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authViewModel,
      builder: (context, _) {
        if (widget.authViewModel.isAuthenticated) {
          return HomeScreen(
            viewModel: widget.dayNoteViewModel,
            authViewModel: widget.authViewModel,
          );
        }

        return AuthScreen(authViewModel: widget.authViewModel);
      },
    );
  }
}
