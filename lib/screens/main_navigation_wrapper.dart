import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/bottom_nav_bar.dart';
import '../providers/chat_provider.dart';
import '../providers/exchange_provider.dart';
import 'chat/conversations_screen.dart';
import 'explore/explore_screen.dart';
import 'home/home_screen.dart';
import 'profile/my_profile_tab.dart';

class MainNavigationWrapper extends StatefulWidget {
  final int initialTab;

  const MainNavigationWrapper({super.key, this.initialTab = 0});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final exchange = context.watch<ExchangeProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Tab 0: Home
          SafeArea(
            child: HomeScreen(
              onExploreTap: () => _onTabSelected(1),
              onProfileTap: () => _onTabSelected(3),
            ),
          ),

          // Tab 1: Explore
          ExploreScreen(onGoHome: () => _onTabSelected(0)),

          // Tab 2: Chat
          ConversationsScreen(onGoHome: () => _onTabSelected(0)),

          // Tab 3: Profile
          const MyProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        unreadChatsCount: chat.unreadCount,
        pendingRequestsCount: exchange.pendingReceivedCount,
      ),
    );
  }
}
