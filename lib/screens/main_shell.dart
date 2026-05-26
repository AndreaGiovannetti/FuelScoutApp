import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  final _tabs = const [
    _TabItem(icon: Icons.home_rounded, label: 'Home'),
    _TabItem(icon: Icons.map_rounded,  label: 'Mappa'),
    _TabItem(icon: Icons.settings_rounded, label: 'Impostazioni'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Pages
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              HomeScreen(),
              MapScreen(),
              SettingsScreen(),
            ],
          ),

          // Bottom Nav
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BottomNavBar(
              currentIndex: _currentIndex,
              tabs: _tabs,
              onTap: _onTabTap,
              onSearchTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, anim, __) => const SearchScreen(),
                    transitionsBuilder: (_, anim, __, child) =>
                        FadeTransition(
                          opacity: CurvedAnimation(
                            parent: anim,
                            curve: Curves.easeOut,
                          ),
                          child: child,
                        ),
                    transitionDuration: const Duration(milliseconds: 250),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Nav Bar ────────────────────────────────────────────────────────

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_TabItem> tabs;
  final ValueChanged<int> onTap;
  final VoidCallback onSearchTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPad + 8, top: 0),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(top: BorderSide(color: AppTheme.cardBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Tab 0: Home
          _NavTabButton(
            icon: tabs[0].icon,
            label: tabs[0].label,
            selected: currentIndex == 0,
            onTap: () => onTap(0),
          ),

          // Tab 1: Map
          _NavTabButton(
            icon: tabs[1].icon,
            label: tabs[1].label,
            selected: currentIndex == 1,
            onTap: () => onTap(1),
          ),

          // Center: Search FAB
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              width: 56, height: 56,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                gradient: AppTheme.amberGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.amber.withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // Tab 2: Settings
          _NavTabButton(
            icon: tabs[2].icon,
            label: tabs[2].label,
            selected: currentIndex == 2,
            onTap: () => onTap(2),
          ),

          // Favourites quick-access
          _NavTabButton(
            icon: Icons.bookmark_rounded,
            label: 'Salvati',
            selected: false,
            onTap: () {
              // Could push a favourites screen; for now scroll home to favourites
              onTap(0);
            },
          ),
        ],
      ),
    );
  }
}

class _NavTabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selected ? AppTheme.amberGlow : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected ? AppTheme.amber : AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? AppTheme.amber : AppTheme.textMuted,
                fontFamily: selected ? 'Syne' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
