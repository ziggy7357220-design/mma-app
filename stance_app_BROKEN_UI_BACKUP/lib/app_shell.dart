// ============================================================
// App shell — 5-tab bottom navigation with state-aware routing.
// ============================================================

import 'package:flutter/material.dart';

import 'data/content.dart';
import 'home_screen.dart';
import 'learn_screen.dart';
import 'models/models.dart';
import 'splash_screen.dart';
import 'intro_screen.dart';
import 'onboarding.dart';
import 'workout_details_screen.dart';
import 'plan_screen.dart';
import 'profile_screen.dart';
import 'state.dart';
import 'train_screen.dart';

class AppShell extends StatefulWidget {
  final AppState state;
  const AppShell({super.key, required this.state});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;
  bool _loading = true;
  bool _showIntro = true;
  bool _initialized = false;
  bool _splashFinished = false;

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_handleStateChange);
    _init();
  }

  @override
  void dispose() {
    widget.state.removeListener(_handleStateChange);
    super.dispose();
  }

  void _handleStateChange() {
    print('[STANCE DEBUG] APP SHELL REBUILD');
    if (mounted) setState(() {});
  }

  Future<void> _init() async {
    await widget.state.load();
    if (!mounted) return;
    setState(() {
      _initialized = true;
      if (_splashFinished) {
        _loading = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SplashScreen(
        onFinished: () {
          setState(() {
            _splashFinished = true;
            if (_initialized) {
              _loading = false;
            }
          });
        },
      );
    }

    if (!widget.state.onboarded) {
      if (_showIntro) {
        return IntroScreen(
          onGetStarted: () => setState(() => _showIntro = false),
        );
      }
      return OnboardingScreen(
        onCompleted: (profile, schedule) {
          widget.state.completeOnboarding(profile, schedule);
        },
      );
    }

    return PopScope(
      canPop: _tab == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_tab != 0) {
          setState(() => _tab = 0);
        }
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildBody(),
        ),
        bottomNavigationBar: _buildNav(),
      ),
    );
  }

  Widget _buildBody() {
    // Use AnimatedSwitcher-friendly key for tab transitions
    final key = ValueKey(_tab);
    switch (_tab) {
      case 0:
        return HomeScreen(
          key: key,
          state: widget.state,
          onStartWorkout: () => _startTodayWorkout(),
          onNavigatePlan: () => setState(() => _tab = 1),
        );
      case 1:
        return PlanScreen(key: key, state: widget.state);
      case 2:
        return TrainScreen(key: key, state: widget.state);
      case 3:
        return LearnScreen(key: key, state: widget.state);
      case 4:
        return ProfileScreen(key: key, state: widget.state);
    }
    return const SizedBox();
  }

  void _startTodayWorkout() {
    final now = DateTime.now();
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final todayKey = days[now.weekday - 1];
    ScheduledDay? day;
    for (final d in widget.state.schedule) {
      if (d.day == todayKey) {
        day = d;
        break;
      }
    }
    final workout = day?.workout;
    if (workout == null) {
      // Pick the first training day as fallback
      for (final d in widget.state.schedule) {
        if (d.workout != null) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => WorkoutDetailsScreen(
              workout: d.workout!,
              state: widget.state,
            ),
          ));
          return;
        }
      }
      // Last resort — first available workout
      final all = ContentLibrary.workouts.first;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => WorkoutDetailsScreen(
          workout: all,
          state: widget.state,
        ),
      ));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => WorkoutDetailsScreen(
        workout: workout,
        state: widget.state,
      ),
    ));
  }

  Widget _buildNav() {
    return BottomNavigationBar(
      currentIndex: _tab,
      onTap: (i) => setState(() => _tab = i),
      items: const [
        BottomNavigationBarItem(icon: Text('🏠', style: TextStyle(fontSize: 22)), label: 'Home'),
        BottomNavigationBarItem(icon: Text('📅', style: TextStyle(fontSize: 22)), label: 'Plan'),
        BottomNavigationBarItem(icon: Text('🥊', style: TextStyle(fontSize: 22)), label: 'Train'),
        BottomNavigationBarItem(icon: Text('📚', style: TextStyle(fontSize: 22)), label: 'Learn'),
        BottomNavigationBarItem(icon: Text('👤', style: TextStyle(fontSize: 22)), label: 'Profile'),
      ],
    );
  }
}
