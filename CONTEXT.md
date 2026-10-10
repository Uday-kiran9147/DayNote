# Daynote — Complete Project Context & Architecture

> **"My entire life, organized one day at a time."**

Daynote is a minimal, classic Flutter app designed as a digital diary and daily planner. It provides a personal, calm, and distraction-free experience centered around a monthly calendar and daily entries (todos & notes) on a single scrollable page.

---

## 1. Product Philosophy & Design Principles

- **Core Experience**:
  $$\text{See Calendar} \longrightarrow \text{Select Date} \longrightarrow \text{Immediately view entries} \longrightarrow \text{Add Todos / Notes}$$
- **Aesthetic**:
  - Classic editorial look inspired by premium paper diaries and desk planners.
  - Warm ivory paper background (`#FBF9F4`), deep charcoal ink (`#22201E`), muted leather brown accent (`#7A5C43`), and soft beige hairline separators (`#E8E1D5`).
  - Unified, crisp sans-serif typography (*Inter*) across all UI elements for clean readability without visual noise.
- **Single-Screen Focus**:
  - The calendar is the primary navigation. Tapping any date instantly updates the content below without navigating away or opening separate pages.
  - No complex dashboards, excessive cards, nested folders, or intrusive productivity overhead.

---

## 2. Architecture: Flutter MVVM

The project strictly follows the official [Flutter App Architecture Guide (MVVM Pattern)](https://docs.flutter.dev/app-architecture/guide).

```
┌─────────────────────────────────────────────────────────┐
│                        UI LAYER                         │
│  AuthGate, HomeScreen, AuthScreen, Modular Widgets      │
└────────────────────────────┬────────────────────────────┘
                             │ Listens to state
┌────────────────────────────▼────────────────────────────┐
│                    VIEWMODEL LAYER                      │
│   DayNoteViewModel, AuthViewModel (ChangeNotifier)     │
└────────────────────────────┬────────────────────────────┘
                             │ Calls repository / services
┌────────────────────────────▼────────────────────────────┐
│                       DATA LAYER                        │
│   DayNoteRepository ──► LocalStorageService (Cache)     │
│                     ──► FirestoreService (Cloud DB)     │
│   AuthService       ──► FirebaseAuthService             │
│   Models            ──► DayEntry, TodoItem              │
└─────────────────────────────────────────────────────────┘
```

### Layer Breakdown

1. **Data Layer (`lib/data/`)**:
   - **Models**:
     - `TodoPriority`: Enum (`none`, `low`, `medium`, `high`) with serialization, label helpers, and custom color accents.
     - `TodoItem`: Represents a checklist item (`id`, `text`, `isDone`, `order`, `priority`, `createdAt`). Standardized with `maxTextLength = 120` to keep daily planner tasks focused and concise.
     - `DayEntry`: Represents a daily journal entry (`dateKey` in `YYYY-MM-DD`, `todos`, `note`, `updatedAt`).
   - **Services**:
     - `LocalStorageService`: Persists entries in `SharedPreferences` for offline-first access and fast indicator dot queries.
     - `FirestoreService`: Manages remote Cloud Firestore documents under `users/{userId}/entries/{dateKey}`.
     - `AuthService` / `FirebaseAuthService`: Handles Firebase Authentication (Email/Password, Registration, Password Reset, Sign Out).
     - `MockAuthService`: Provides hermetic in-memory authentication for automated testing and offline fallback.
   - **Repositories**:
     - `DayNoteRepository` (interface) & `DayNoteRepositoryImpl` (concrete): Hybrid repository providing offline-first caching combined with real-time remote cloud synchronization, including priority updates.

2. **ViewModel Layer (`lib/viewmodels/`)**:
   - `DayNoteViewModel`: Manages selected date, calendar month view, current entry, dot indicators, and CRUD actions on todos (with priority levels) and notes. Implements debounced background persistence to prevent UI stutter during typing.
   - `AuthViewModel`: Manages authentication state, user credentials, input validation, loading states, and error message localization.

3. **UI Layer (`lib/ui/`)**:
   - `screens/auth_gate.dart`: Routes authenticated users to `HomeScreen` and unauthenticated users to `AuthScreen`.
   - `screens/home_screen.dart`: Assembles the unified single-screen scrollable experience.
   - `screens/auth_screen.dart`: Full-width sign-in, account creation, and password reset views.
   - `theme/app_theme.dart`: Central palette (paper surfaces, terracotta high-priority, ochre medium-priority, sage low-priority) and unified Inter typography definitions.
   - `widgets/`:
     - `daynote_app_bar.dart`: Top bar with brand mark, "Today" quick shortcut, and user avatar.
     - `calendar_widget.dart`: Monthly grid, content indicator dots (`•`), and segmented month steppers (`‹ | ›`).
     - `month_year_picker_sheet.dart`: 25-year picker and 12-month navigation modal.
     - `selected_date_header.dart`: Prominent date display and section separator.
     - `todo_section.dart`: Daily checklist with custom checkboxes, priority cycle badges (High/Med/Low), inline priority selector, delete confirmation safeguards, and editing.
     - `note_section.dart`: Paper writing surface with auto-save and focus auto-scrolling.
     - `onboarding_dialog.dart`: Walkthrough carousel modal explaining calendar navigation, priorities, and notes, with sample journal loading.
     - `empty_day_view.dart`: Clean empty state with "+ Add Todo" and "+ Add Note" shortcuts.
     - `account_sheet.dart`: Account details, replay walkthrough option, and one-tap sign-out modal.
     - `classic_checkbox.dart`: Custom antique minimal checkbox.

---

## 3. Project File Tree

```
daynote/
├── android/
│   ├── app/
│   │   ├── build.gradle.kts           # Configured with google-services & minSdk 23
│   │   ├── google-services.json       # Firebase project credentials
│   │   └── src/main/AndroidManifest.xml
│   ├── build.gradle.kts
│   └── settings.gradle.kts            # Configured with com.google.gms.google-services plugin
├── assets/
│   └── daynote-icon.png               # Source app launcher icon
├── lib/
│   ├── data/
│   │   ├── models/
│   │   │   ├── day_entry.dart
│   │   │   └── todo_item.dart
│   │   ├── repositories/
│   │   │   ├── day_note_repository.dart
│   │   │   └── day_note_repository_impl.dart
│   │   └── services/
│   │       ├── auth_service.dart
│   │       ├── firestore_service.dart
│   │       ├── local_storage_service.dart
│   │       └── mock_auth_service.dart
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── auth_gate.dart
│   │   │   ├── auth_screen.dart
│   │   │   └── home_screen.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── widgets/
│   │       ├── account_sheet.dart
│   │       ├── calendar_widget.dart
│   │       ├── classic_checkbox.dart
│   │       ├── daynote_app_bar.dart
│   │       ├── empty_day_view.dart
│   │       ├── month_year_picker_sheet.dart
│   │       ├── note_section.dart
│   │       ├── onboarding_dialog.dart
│   │       ├── selected_date_header.dart
│   │       └── todo_section.dart
│   ├── viewmodels/
│   │   ├── auth_viewmodel.dart
│   │   └── day_note_viewmodel.dart
│   ├── firebase_options.dart          # Multiplatform Firebase configuration
│   └── main.dart                      # App entry point
├── test/
│   ├── auth_viewmodel_test.dart       # Unit tests for authentication
│   ├── day_note_viewmodel_test.dart   # Unit tests for calendar and daily entries
│   └── widget_test.dart               # Integration widget tests for UI flows
├── .gitignore                         # Comprehensive Flutter, Android, iOS, & secrets exclusions
├── CONTEXT.md                         # This documentation file
└── pubspec.yaml                       # Dependencies and launcher icon config
```

---

## 4. Key Dependencies

- `firebase_core: ^4.15.0`: Firebase initialization.
- `firebase_auth: ^6.7.0`: Email & password authentication and user management.
- `cloud_firestore: ^6.10.0`: Remote database synchronization.
- `shared_preferences: ^2.5.6`: Local fast key-value storage.
- `google_fonts: ^9.0.0`: *Inter* typography.
- `intl: ^0.20.3`: Date formatting (`EEEE, MMMM d`, `MMMM yyyy`).
- `flutter_launcher_icons: ^0.14.3`: Automated app icon generation.

---

## 5. Technical Highlights & Performance Optimizations

1. **Zero-Stutter Typing (Buffered Note Editing)**:
   - `DayNoteViewModel.onNoteChanged` buffers note text in memory and debounces repository writes (`600ms`) without triggering `notifyListeners()` on every keypress.
   - `NoteSection` maintains an independent text controller keyed by `entry.dateKey`, preventing cursor fighting and layout flickering.

2. **Smooth Keyboard, Tap-Outside Dismissal, & Auto-Scrolling**:
   - `CustomScrollView` uses `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` and `BouncingScrollPhysics`.
   - `HomeScreen`, `AuthScreen`, `TodoSection`, and `NoteSection` implement comprehensive tap-outside dismissal via `GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => FocusScope.of(context).unfocus())` and `TextField.onTapOutside`.
   - Automated focus-aware scroll positioning using `Scrollable.ensureVisible` and generous `scrollPadding: const EdgeInsets.only(top: 24, bottom: 120)` smoothly brings active fields into view above the soft keyboard.

3. **Multiplatform Firebase Resilience**:
   - `main.dart` safely attempts `Firebase.initializeApp()` with fallback to `MockAuthService` when running offline or in environments without native services.

4. **Optimistic UI Updates with Declarative Error Rollback**:
   - All todo mutations (`addTodo`, `toggleTodo`, `updateTodoText`, `updateTodoPriority`, `deleteTodo`, `reorderTodos`) update in-memory state and notify listeners synchronously (0ms perceived latency).
   - A snapshot of previous state is captured prior to mutations. If storage persistence or remote sync fails, the viewmodel automatically reverts to the previous snapshot, restores the calendar indicator dots, surfaces an error message, and declarative listeners immediately restore the UI.

---

## 6. Development & Verification Commands

- **Run all tests**:
  ```bash
  flutter test
  ```
- **Code analyzer**:
  ```bash
  flutter analyze
  ```
- **Generate launcher icons**:
  ```bash
  dart run flutter_launcher_icons
  ```
- **Run the application**:
  ```bash
  flutter run
  ```
