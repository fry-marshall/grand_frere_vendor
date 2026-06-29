import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/pages/orders_screen.dart';
import '../../../vendor/presentation/cubit/vendor_cubit.dart';
import '../../../vendor/presentation/cubit/vendor_state.dart';
import '../../../vendor/presentation/pages/account_screen.dart';
import '../../../vendor/presentation/pages/home_screen.dart';
import '../../../vendor/presentation/pages/menu_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _tabs = [
    HomeScreen(),
    OrdersScreen(),
    MenuScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vs = context.read<VendorCubit>().state;
      if (vs is VendorLoaded) {
        getIt<OrdersCubit>().load(vs.vendor.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return BlocProvider.value(
      value: getIt<OrdersCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: IndexedStack(index: _index, children: _tabs),
        floatingActionButton: _EncaisserFab(
          onTap: () => context.push(Routes.cashin),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: _BottomBar(
          index: _index,
          bottomPad: bottomPad,
          onTab: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}

// ── FAB Encaisser ─────────────────────────────────────────────────────────────

class _EncaisserFab extends StatelessWidget {
  const _EncaisserFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gold, AppColors.goldDeep],
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4C5B1E0F),
              blurRadius: 26,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Color(0x2EE8B54A),
              blurRadius: 0,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_scanner_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Encaisser',
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom nav bar ────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.index,
    required this.bottomPad,
    required this.onTab,
  });

  final int index;
  final double bottomPad;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(0, 8, 0, 8 + bottomPad),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TabItem(
            label: 'Accueil',
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            active: index == 0,
            onTap: () => onTab(0),
          ),
          _TabItem(
            label: 'Commandes',
            icon: Icons.shopping_bag_outlined,
            activeIcon: Icons.shopping_bag_rounded,
            active: index == 1,
            onTap: () => onTab(1),
          ),
          _TabItem(
            label: 'Menu',
            icon: Icons.restaurant_menu_outlined,
            activeIcon: Icons.restaurant_menu_rounded,
            active: index == 2,
            onTap: () => onTab(2),
          ),
          _TabItem(
            label: 'Compte',
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            active: index == 3,
            onTap: () => onTab(3),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.maroon : AppColors.mute;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: color,
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
