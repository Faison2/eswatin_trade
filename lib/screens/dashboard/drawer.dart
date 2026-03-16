import 'dart:ui';
import 'package:flutter/material.dart';

// ─── ESE Color Palette (mirrored) ─────────────────────────────────────────────
class _C {
  static const bg        = Color(0xFF060C1A);
  static const surface   = Color(0xFF0D1728);
  static const card      = Color(0xFF111F35);
  static const border    = Color(0xFF1E2E45);
  static const gold      = Color(0xFFD4A030);
  static const goldLight = Color(0xFFF5D98B);
  static const blue      = Color(0xFF1565C0);
  static const teal      = Color(0xFF26A69A);
  static const red       = Color(0xFFEF5350);
  static const textPrim  = Color(0xFFEEF2FF);
  static const textSub   = Color(0xFF7A8BA8);
  static const textMuted = Color(0xFF3D5470);
}

// ─── Drawer Items Model ───────────────────────────────────────────────────────
class _DrawerItem {
  final IconData icon;
  final String label;
  final String? badge;
  final Color? badgeColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.badge,
    this.badgeColor,
  });
}

// ─── App Drawer ───────────────────────────────────────────────────────────────
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  late AnimationController _entranceCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _itemsFade;

  final List<_DrawerItem> _mainItems = const [
    _DrawerItem(icon: Icons.dashboard_rounded,       label: 'Dashboard'),
    _DrawerItem(icon: Icons.pie_chart_rounded,        label: 'Portfolio'),
    _DrawerItem(icon: Icons.candlestick_chart_rounded,label: 'Trade'),
    _DrawerItem(icon: Icons.bar_chart_rounded,        label: 'Market Watch'),
    _DrawerItem(
      icon: Icons.receipt_long_rounded,
      label: 'Orders',
      badge: '7',
      badgeColor: _C.gold,
    ),
    _DrawerItem(
      icon: Icons.swap_horiz_rounded,
      label: 'Transactions',
      badge: 'New',
      badgeColor: _C.teal,
    ),
    _DrawerItem(icon: Icons.account_balance_wallet_outlined, label: 'Deposit'),
    _DrawerItem(icon: Icons.money_rounded,            label: 'Withdrawal'),
  ];

  final List<_DrawerItem> _secondaryItems = const [
    _DrawerItem(icon: Icons.person_outline_rounded,   label: 'Profile'),
    _DrawerItem(icon: Icons.shield_outlined,          label: 'Security'),
    _DrawerItem(icon: Icons.help_outline_rounded,     label: 'Support'),
    _DrawerItem(icon: Icons.settings_outlined,        label: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _headerFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _headerSlide = Tween(begin: const Offset(-0.1, 0), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ));
    _itemsFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF080F1E), Color(0xFF0A1525)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                right: BorderSide(color: Color(0xFF1E2E45), width: 1),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: _DrawerHeader(),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Main Nav ──
                  FadeTransition(
                    opacity: _itemsFade,
                    child: _SectionLabel(label: 'MAIN MENU'),
                  ),
                  const SizedBox(height: 4),

                  Expanded(
                    child: FadeTransition(
                      opacity: _itemsFade,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          ..._mainItems.asMap().entries.map((e) =>
                              _DrawerNavItem(
                                item: e.value,
                                index: e.key,
                                selected: _selectedIndex == e.key,
                                onTap: () =>
                                    setState(() => _selectedIndex = e.key),
                              )),

                          const SizedBox(height: 16),
                          _SectionLabel(label: 'ACCOUNT'),
                          const SizedBox(height: 4),

                          ..._secondaryItems.asMap().entries.map((e) {
                            final idx = _mainItems.length + e.key;
                            return _DrawerNavItem(
                              item: e.value,
                              index: idx,
                              selected: _selectedIndex == idx,
                              onTap: () =>
                                  setState(() => _selectedIndex = idx),
                            );
                          }),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // ── Footer / Logout ──
                  FadeTransition(
                    opacity: _itemsFade,
                    child: _DrawerFooter(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Drawer Header ────────────────────────────────────────────────────────────
class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1E3A), Color(0xFF0A1628)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _C.gold.withOpacity(0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _C.gold.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: _C.gold.withOpacity(0.40),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _C.gold.withOpacity(0.20),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text('JD',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5)),
            ),
          ),
          const SizedBox(width: 12),

          // Name & account info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('John Doe',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _C.textPrim,
                        letterSpacing: 0.2)),
                const SizedBox(height: 3),
                Text('john.doe@ese.et',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10,
                        color: _C.textSub)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _C.teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _C.teal.withOpacity(0.28), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5, height: 5,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: _C.teal),
                      ),
                      const SizedBox(width: 4),
                      const Text('Verified Account',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _C.teal)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: _C.textMuted,
            letterSpacing: 1.4),
      ),
    );
  }
}

// ─── Drawer Nav Item ──────────────────────────────────────────────────────────
class _DrawerNavItem extends StatefulWidget {
  final _DrawerItem item;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.item,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_DrawerNavItem> createState() => _DrawerNavItemState();
}

class _DrawerNavItemState extends State<_DrawerNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
          Navigator.pop(context);
        },
        onTapCancel: () => _ctrl.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: widget.selected
                ? _C.gold.withOpacity(0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.selected
                  ? _C.gold.withOpacity(0.22)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? _C.gold.withOpacity(0.15)
                      : _C.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.selected
                        ? _C.gold.withOpacity(0.28)
                        : _C.border,
                    width: 1,
                  ),
                ),
                child: Icon(
                  widget.item.icon,
                  size: 15,
                  color: widget.selected ? _C.gold : _C.textSub,
                ),
              ),

              const SizedBox(width: 12),

              // Label
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color:
                    widget.selected ? _C.textPrim : _C.textSub,
                    letterSpacing: 0.2,
                  ),
                  child: Text(widget.item.label),
                ),
              ),

              // Badge
              if (widget.item.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (widget.item.badgeColor ?? _C.gold)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (widget.item.badgeColor ?? _C.gold)
                          .withOpacity(0.30),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.item.badge!,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: widget.item.badgeColor ?? _C.gold),
                  ),
                ),

              // Selected indicator arrow
              if (widget.selected) ...[
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded,
                    color: _C.gold, size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Drawer Footer ────────────────────────────────────────────────────────────
class _DrawerFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _C.border.withOpacity(0.6), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            // TODO: hook up actual logout logic
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _C.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: _C.red.withOpacity(0.18), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: _C.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _C.red.withOpacity(0.25), width: 1),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: _C.red, size: 15),
                ),
                const SizedBox(width: 12),
                const Text('Log Out',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.red,
                        letterSpacing: 0.2)),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: _C.red.withOpacity(0.50), size: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}