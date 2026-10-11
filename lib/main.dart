import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/repositories/day_note_repository_impl.dart';
import 'data/services/auth_service.dart';
import 'data/services/firestore_service.dart';
import 'data/services/mock_auth_service.dart';
import 'firebase_options.dart';
import 'ui/screens/auth_gate.dart';
import 'ui/theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/day_note_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set classic editorial system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.paperBackground,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  AuthService authService;
  FirestoreService? firestoreService;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    authService = FirebaseAuthService();
    firestoreService = FirestoreService();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
    authService = MockAuthService();
  }

  final authViewModel = AuthViewModel(authService: authService);
  final repository = DayNoteRepositoryImpl(
    firestoreService: firestoreService,
    userId: authService.currentUser?.uid,
  );
  final dayNoteViewModel = DayNoteViewModel(repository: repository);
  await dayNoteViewModel.init();

  runApp(
    DayNoteApp(
      dayNoteViewModel: dayNoteViewModel,
      authViewModel: authViewModel,
    ),
  );
}

class DayNoteApp extends StatelessWidget {
  final DayNoteViewModel dayNoteViewModel;
  final AuthViewModel authViewModel;

  const DayNoteApp({
    super.key,
    required this.dayNoteViewModel,
    required this.authViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DayNote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: AuthGate(
        authViewModel: authViewModel,
        dayNoteViewModel: dayNoteViewModel,
      ),
    );
  }
}
