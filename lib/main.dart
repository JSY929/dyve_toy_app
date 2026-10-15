import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens/home_screen.dart';
import 'screens/liked_screen.dart';
import 'screens/my_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/search_screen.dart';
import 'screens/ticket_screen.dart';
import 'screens/venue_screen.dart';
import 'widgets/common.dart';

void main() => runApp(const DyveApp());

class DyveApp extends StatefulWidget {
  const DyveApp({super.key});

  @override
  State<DyveApp> createState() => _DyveAppState();
}

class _DyveAppState extends State<DyveApp> {
  final _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: kCoral, brightness: Brightness.dark).copyWith(
      primary: kCoral,
      onPrimary: Colors.black,
      surface: kBg,
      surfaceContainer: kSurface,
      surfaceContainerHigh: kSurface,
      surfaceContainerLow: kSurface,
    );
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'DYVE',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: scheme,
          scaffoldBackgroundColor: kBg,
          appBarTheme: const AppBarTheme(
            backgroundColor: kBg,
            surfaceTintColor: Colors.transparent,
            centerTitle: false,
          ),
          dividerTheme: const DividerThemeData(color: kLine),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: kSurface,
            indicatorColor: kCoral.withValues(alpha: 0.2),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: kSurface,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        home: const RootShell(),
      ),
    );
  }
}

/// 하단 탭 4개 + 상단 바(로고, 검색, 찜, 알림).
class RootShell extends StatelessWidget {
  const RootShell({super.key});

  Future<void> _openWithLogin(BuildContext context, Widget screen) async {
    if (!await ensureLoggedIn(context) || !context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final unread = state.loggedIn && state.notifications.any((n) => !n.read);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DYVE',
          style: TextStyle(color: kCoral, fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: 3),
        ),
        actions: [
          IconButton(
            tooltip: '검색',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SearchScreen())),
          ),
          IconButton(
            tooltip: '찜',
            icon: const Icon(Icons.favorite_border),
            onPressed: () => _openWithLogin(context, const LikedScreen()),
          ),
          IconButton(
            tooltip: '알림',
            icon: Badge(isLabelVisible: unread, child: const Icon(Icons.notifications_none)),
            onPressed: () => _openWithLogin(context, const NotificationsScreen()),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(index: state.tab, children: const [HomeScreen(), TicketScreen(), VenueScreen(), MyScreen()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.tab,
        onDestinationSelected: state.setTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: kCoral),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number, color: kCoral),
            label: '티켓',
          ),
          NavigationDestination(
            icon: Icon(Icons.place_outlined),
            selectedIcon: Icon(Icons.place, color: kCoral),
            label: '베뉴',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: kCoral),
            label: '마이',
          ),
        ],
      ),
    );
  }
}
