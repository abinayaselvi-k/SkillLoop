import 'package:flutter/material.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/welcome_screen.dart';
import '../../screens/exchanges/exchange_requests_screen.dart';
import '../../screens/explore/explore_screen.dart';
import '../../screens/main_navigation_wrapper.dart';
import '../../screens/matches/explore_matches_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String home = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String explore = '/explore';
  static const String matches = '/matches';
  static const String exchangeRequests = '/exchange-requests';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    home: (_) => const MainNavigationWrapper(),
    welcome: (_) => const WelcomeScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    explore: (_) => const ExploreScreen(),
    matches: (_) => const ExploreMatchesScreen(),
    exchangeRequests: (_) => const ExchangeRequestsScreen(),
    notifications: (_) => const NotificationsScreen(),
  };
}
