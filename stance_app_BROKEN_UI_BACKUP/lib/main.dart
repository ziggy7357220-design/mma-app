// ============================================================
// Stance — martial arts training app.
// Entry point. Builds the AppState, applies the dark theme,
// and mounts the AppShell.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_shell.dart';
import 'state.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  final state = AppState();
  runApp(StanceApp(state: state));
}

class StanceApp extends StatelessWidget {
  final AppState state;
  const StanceApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        // Synchronize the static AppTheme mode with the AppState
        AppTheme.currentMode = state.themeMode;
        return MaterialApp(
          title: 'Stance',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: state.themeMode,
          home: AppShell(state: state),
        );
      },
    );
  }
}
