import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

/// Brief branded startup screen that preserves the existing Firebase session.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _startupTimer;

  @override
  void initState() {
    super.initState();
    _continueStartup();
  }

  void _continueStartup() {
    _startupTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      // Firebase may be unavailable in a widget test or a partially configured
      // build. In that case, continue safely to the existing welcome screen.
      final hasSession =
          Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null;
      Navigator.pushReplacementNamed(
        context,
        hasSession ? AppRoutes.home : AppRoutes.welcome,
      );
    });
  }

  @override
  void dispose() {
    _startupTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.all_inclusive_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'SkillLoop',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Teach. Learn. Grow together.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
