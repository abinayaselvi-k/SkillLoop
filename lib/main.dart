export 'core/widgets/bottom_nav_bar.dart';
export 'core/widgets/student_card.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/exchange_provider.dart';
import 'providers/explore_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/main_navigation_wrapper.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safely initialize Firebase if configuration files are available
  await FirebaseService.initialize();

  runApp(const SkillLoopApp());
}

class SkillLoopApp extends StatelessWidget {
  const SkillLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ExploreProvider>(
          create: (_) => ExploreProvider(),
          update: (_, auth, explore) {
            explore?.updateUserId(auth.firebaseUser?.uid);
            return explore ?? ExploreProvider();
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ExchangeProvider>(
          create: (_) => ExchangeProvider(),
          update: (_, auth, exchange) {
            exchange?.updateUserId(auth.currentProfile.id);
            return exchange ?? ExchangeProvider();
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, auth, chat) {
            chat?.updateUserId(auth.currentProfile.id);
            return chat ?? ChatProvider();
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (_) => NotificationProvider(),
          update: (_, auth, notif) {
            notif?.updateUserId(auth.currentProfile.id);
            return notif ?? NotificationProvider();
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SkillLoop',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}

// Retain HomePage as backward-compatible alias to MainNavigationWrapper
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigationWrapper();
  }
}
