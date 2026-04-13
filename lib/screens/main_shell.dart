import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'market_screen.dart';
import 'chat_screen.dart';
import 'mapping_screen.dart';
import 'loan_screen.dart';
import 'news_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    HomeScreen(onAITap: () => setState(() => _currentIndex = 2)),
    const MarketScreen(),
    const ChatScreen(),
    const MappingScreen(),
    const LoanScreen(),
  ];

  final _items = [
    _NavItemData(Icons.home_rounded, Icons.home_outlined, 'Home'),
    _NavItemData(Icons.trending_up_rounded, Icons.trending_up_outlined, 'Market'),
    _NavItemData(Icons.smart_toy_rounded, Icons.smart_toy_outlined, 'AI Chat'),
    _NavItemData(Icons.layers_rounded, Icons.layers_outlined, 'Field'),
    _NavItemData(Icons.payments_rounded, Icons.payments_outlined, 'Loans'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.outlineVariant.withOpacity(0.25),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (i) => _NavItem(
                data: _items[i],
                selected: _currentIndex == i,
                isCenter: i == 2,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _currentIndex = i);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData iconOutlined;
  final String label;
  const _NavItemData(this.icon, this.iconOutlined, this.label);
}

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool selected;
  final bool isCenter;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.selected,
    required this.isCenter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Special center AI chat button
    if (isCenter) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: selected
                      ? [AppTheme.primaryContainer, AppTheme.primary]
                      : [AppTheme.surfaceContainerHigh, AppTheme.surfaceContainerHighest],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                data.icon,
                color: selected ? Colors.white : AppTheme.onSurfaceVariant,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              data.label,
              style: TextStyle(
                color: selected ? AppTheme.primary : AppTheme.onSurfaceVariant,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? data.icon : data.iconOutlined,
              size: 22,
              color: selected ? AppTheme.primary : AppTheme.onSurfaceVariant,
            ),
            const SizedBox(height: 3),
            Text(
              data.label,
              style: TextStyle(
                color: selected ? AppTheme.primary : AppTheme.onSurfaceVariant,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}