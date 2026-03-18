import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── ESE Color Palette ────────────────────────────────────────────────────────
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
  /// Pre-loaded from SharedPreferences by DashboardScreen
  final String initials;
  final String cdsNumber;

  const AppDrawer({
    super.key,
    required this.initials,
    required this.cdsNumber,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  // ── All profile fields loaded locally ────────────────────────────────────
  String _fullName  = '';
  String _email     = '';
  String _cdsNumber = '';
  String _initials  = '';

  late AnimationController _entranceCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset>  _headerSlide;
  late Animation<double> _itemsFade;

  final List<_DrawerItem> _mainItems = const [
    _DrawerItem(icon: Icons.dashboard_rounded,        label: 'Dashboard'),
    _DrawerItem(icon: Icons.pie_chart_rounded,         label: 'Portfolio'),
    _DrawerItem(icon: Icons.candlestick_chart_rounded, label: 'Trade'),
    _DrawerItem(icon: Icons.bar_chart_rounded,         label: 'Market Watch'),
    _DrawerItem(icon: Icons.receipt_long_rounded,      label: 'Orders',
        badge: '7', badgeColor: _C.gold),
    _DrawerItem(icon: Icons.swap_horiz_rounded,        label: 'Transactions',
        badge: 'New', badgeColor: _C.teal),
    _DrawerItem(icon: Icons.account_balance_wallet_outlined, label: 'Deposit'),
    _DrawerItem(icon: Icons.money_rounded,             label: 'Withdrawal'),
  ];

  final List<_DrawerItem> _secondaryItems = const [
    _DrawerItem(icon: Icons.person_outline_rounded, label: 'Profile'),
    _DrawerItem(icon: Icons.shield_outlined,        label: 'Security'),
    _DrawerItem(icon: Icons.help_outline_rounded,   label: 'Support'),
    _DrawerItem(icon: Icons.settings_outlined,      label: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();

    _headerFade  = CurvedAnimation(parent: _entranceCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
    _headerSlide = Tween(begin: const Offset(-0.1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)));
    _itemsFade   = CurvedAnimation(parent: _entranceCtrl,
        curve: const Interval(0.25, 1.0, curve: Curves.easeOut));

    // Use the values passed from Dashboard, then also load the rest
    _initials  = widget.initials;
    _cdsNumber = widget.cdsNumber;
    _loadRemainingProfile();
  }

  Future<void> _loadRemainingProfile() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _fullName  = p.getString('full_name') ?? 'ESE Member';
      _email     = p.getString('email')     ?? '—';
      // Refresh in case widget props were empty on first render
      if (_cdsNumber.isEmpty || _cdsNumber == '—') {
        _cdsNumber = p.getString('cds_number') ?? '—';
      }
      if (_initials.isEmpty || _initials == 'U') {
        final f = p.getString('forenames') ?? '';
        final s = p.getString('surname')   ?? '';
        _initials = '${f.isNotEmpty ? f[0] : ''}${s.isNotEmpty ? s[0] : ''}'
            .toUpperCase();
        if (_initials.isEmpty) _initials = 'U';
      }
    });
  }

  Future<void> _handleLogout() async {
    Navigator.pop(context); // close drawer first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _LogoutDialog(),
    );
    if (confirmed == true && mounted) {
      final p = await SharedPreferences.getInstance();
      await p.clear();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      }
    }
  }

  @override
  void dispose() { _entranceCtrl.dispose(); super.dispose(); }

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
                  right: BorderSide(color: Color(0xFF1E2E45), width: 1)),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ─────────────────────────────────────────────
                  FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: _DrawerHeader(
                        initials:  _initials,
                        fullName:  _fullName,
                        email:     _email,
                        cdsNumber: _cdsNumber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Main menu ──────────────────────────────────────────
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
                                item: e.value, index: e.key,
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
                              item: e.value, index: idx,
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

                  // ── Footer logout ──────────────────────────────────────
                  FadeTransition(
                    opacity: _itemsFade,
                    child: _DrawerFooter(onLogout: _handleLogout),
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
  final String initials, fullName, email, cdsNumber;
  const _DrawerHeader({
    required this.initials,
    required this.fullName,
    required this.email,
    required this.cdsNumber,
  });

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
        border: Border.all(color: _C.gold.withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(color: _C.gold.withOpacity(0.08),
              blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // ── Gold-ring avatar ──────────────────────────────────────
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4A030), Color(0xFF8B5E10)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: _C.gold.withOpacity(0.30),
                        blurRadius: 14, offset: const Offset(0, 3)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D1A33), Color(0xFF142444)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(initials,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: _C.goldLight,
                              letterSpacing: 0.5)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ── Name + email ──────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: _C.textPrim, letterSpacing: 0.2)),
                    const SizedBox(height: 3),
                    Text(email,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 10, color: _C.textSub)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── CDS Number pill ───────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _C.gold.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.gold.withOpacity(0.20), width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.credit_card_rounded,
                    color: _C.gold.withOpacity(0.70), size: 13),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CDS NUMBER',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: _C.textSub,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 2),
                    Text(cdsNumber,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _C.goldLight,
                            letterSpacing: 0.6)),
                  ],
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
      child: Text(label,
          style: const TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700,
              color: _C.textMuted, letterSpacing: 1.4)),
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
    required this.item, required this.index,
    required this.selected, required this.onTap,
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
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 80));
    _scale = Tween(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
                ? _C.gold.withOpacity(0.10) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.selected
                  ? _C.gold.withOpacity(0.22) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? _C.gold.withOpacity(0.15) : _C.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.selected
                        ? _C.gold.withOpacity(0.28) : _C.border,
                    width: 1,
                  ),
                ),
                child: Icon(widget.item.icon, size: 15,
                    color: widget.selected ? _C.gold : _C.textSub),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.selected
                        ? FontWeight.w700 : FontWeight.w500,
                    color: widget.selected ? _C.textPrim : _C.textSub,
                    letterSpacing: 0.2,
                  ),
                  child: Text(widget.item.label),
                ),
              ),
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
                  child: Text(widget.item.badge!,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                          color: widget.item.badgeColor ?? _C.gold)),
                ),
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
  final VoidCallback onLogout;
  const _DrawerFooter({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: _C.border.withOpacity(0.6), width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: GestureDetector(
          onTap: onLogout,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _C.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.red.withOpacity(0.18), width: 1),
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
                    style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700, color: _C.red,
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

// ─── Logout Confirmation Dialog ───────────────────────────────────────────────
class _LogoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1728),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF1E2E45), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.55),
                blurRadius: 48, offset: const Offset(0, 20)),
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: _C.red.withOpacity(0.09), shape: BoxShape.circle,
              border: Border.all(color: _C.red.withOpacity(0.22), width: 1.5),
            ),
            child: const Icon(Icons.logout_rounded, color: _C.red, size: 22),
          ),
          const SizedBox(height: 16),
          const Text('Log Out?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                  color: _C.textPrim)),
          const SizedBox(height: 8),
          Text('You will be returned to the login screen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: _C.textSub.withOpacity(0.75))),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                height: 44,
                decoration: BoxDecoration(color: _C.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border)),
                child: const Center(child: Text('Cancel',
                    style: TextStyle(fontSize: 13.5,
                        fontWeight: FontWeight.w600, color: _C.textSub))),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context, true),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: _C.red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _C.red.withOpacity(0.32), width: 1),
                ),
                child: const Center(child: Text('Log Out',
                    style: TextStyle(fontSize: 13.5,
                        fontWeight: FontWeight.w700, color: _C.red))),
              ),
            )),
          ]),
        ]),
      ),
    );
  }
}