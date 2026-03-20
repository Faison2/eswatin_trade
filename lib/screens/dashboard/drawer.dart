import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../settings /settings.dart';

// ─── Dark tokens ──────────────────────────────────────────────────────────────
class _Dark {
  static const drawerBg1 = Color(0xFF080F1E);
  static const drawerBg2 = Color(0xFF0A1525);
  static const drawerBdr = Color(0xFF1E2E45);
  static const surface   = Color(0xFF0D1728);
  static const card      = Color(0xFF111F35);
  static const headerBg1 = Color(0xFF0D1E3A);
  static const headerBg2 = Color(0xFF0A1628);
  static const avatarBg1 = Color(0xFF0D1A33);
  static const avatarBg2 = Color(0xFF142444);
  static const border    = Color(0xFF1E2E45);
  static const gold      = Color(0xFFD4A030);
  static const goldLight = Color(0xFFF5D98B);
  static const teal      = Color(0xFF26A69A);
  static const red       = Color(0xFFEF5350);
  static const textPrim  = Color(0xFFEEF2FF);
  static const textSub   = Color(0xFF7A8BA8);
  static const textMuted = Color(0xFF3D5470);
}

// ─── Light tokens ─────────────────────────────────────────────────────────────
class _Light {
  static const drawerBg1 = Color(0xFFFFFFFF);
  static const drawerBg2 = Color(0xFFF8FAFD);
  static const drawerBdr = Color(0xFFDDE3EF);
  static const surface   = Color(0xFFEEF3FB);
  static const card      = Color(0xFFFFFFFF);
  static const headerBg1 = Color(0xFFF0F6FF);
  static const headerBg2 = Color(0xFFE8F0FC);
  static const avatarBg1 = Color(0xFFFFF8EE);
  static const avatarBg2 = Color(0xFFFFF3DC);
  static const border    = Color(0xFFDDE3EF);
  static const gold      = Color(0xFFC49020);
  static const goldLight = Color(0xFF8B6010);
  static const teal      = Color(0xFF1A8A80);
  static const red       = Color(0xFFD43F3C);
  static const textPrim  = Color(0xFF0D1728);
  static const textSub   = Color(0xFF64748B);
  static const textMuted = Color(0xFFADB5C7);
}

// ─── Drawer Items Model ───────────────────────────────────────────────────────
class _DrawerItem {
  final IconData icon;
  final String   label;
  final String?  badge;
  final Color?   badgeColor;
  const _DrawerItem({
    required this.icon,
    required this.label,
    this.badge,
    this.badgeColor,
  });
}

// ─── App Drawer ───────────────────────────────────────────────────────────────
class AppDrawer extends StatefulWidget {
  final String           initials;
  final String           cdsNumber;
  final AppThemeNotifier themeNotifier;

  const AppDrawer({
    super.key,
    required this.initials,
    required this.cdsNumber,
    required this.themeNotifier,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  String _fullName  = '';
  String _email     = '';
  String _cdsNumber = '';
  String _initials  = '';

  late AnimationController _entranceCtrl;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;
  late Animation<double>   _itemsFade;

  final List<_DrawerItem> _mainItems = const [
    _DrawerItem(icon: Icons.dashboard_rounded,              label: 'Dashboard'),
    _DrawerItem(icon: Icons.pie_chart_rounded,               label: 'Portfolio'),
    _DrawerItem(icon: Icons.candlestick_chart_rounded,       label: 'Trade'),
    _DrawerItem(icon: Icons.bar_chart_rounded,               label: 'Market Watch'),
    _DrawerItem(icon: Icons.receipt_long_rounded,            label: 'Orders',
        badge: '7', badgeColor: _Dark.gold),
    _DrawerItem(icon: Icons.swap_horiz_rounded,              label: 'Transactions',
        badge: 'New', badgeColor: _Dark.teal),
    _DrawerItem(icon: Icons.account_balance_wallet_outlined, label: 'Deposit'),
    _DrawerItem(icon: Icons.money_rounded,                   label: 'Withdrawal'),
  ];

  final List<_DrawerItem> _secondaryItems = const [
    _DrawerItem(icon: Icons.person_outline_rounded, label: 'Profile'),
    _DrawerItem(icon: Icons.shield_outlined,        label: 'Security'),
    _DrawerItem(icon: Icons.help_outline_rounded,   label: 'Support'),
    _DrawerItem(icon: Icons.settings_outlined,      label: 'Settings'),
  ];

  static const int _settingsSecondaryIndex = 3;

  // ── Theme helpers ─────────────────────────────────────────────────────────
  bool   get _isLight  => widget.themeNotifier.isLight;
  Color  get _bg1      => _isLight ? _Light.drawerBg1 : _Dark.drawerBg1;
  Color  get _bg2      => _isLight ? _Light.drawerBg2 : _Dark.drawerBg2;
  Color  get _bdr      => _isLight ? _Light.drawerBdr : _Dark.drawerBdr;
  Color  get _surface  => _isLight ? _Light.surface   : _Dark.surface;
  Color  get _border   => _isLight ? _Light.border    : _Dark.border;
  Color  get _gold     => _isLight ? _Light.gold      : _Dark.gold;
  Color  get _goldL    => _isLight ? _Light.goldLight : _Dark.goldLight;
  Color  get _teal     => _isLight ? _Light.teal      : _Dark.teal;
  Color  get _red      => _isLight ? _Light.red       : _Dark.red;
  Color  get _textPrim => _isLight ? _Light.textPrim  : _Dark.textPrim;
  Color  get _textSub  => _isLight ? _Light.textSub   : _Dark.textSub;
  Color  get _textMut  => _isLight ? _Light.textMuted : _Dark.textMuted;

  void _rebuild() => setState(() {});

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

    _initials  = widget.initials;
    _cdsNumber = widget.cdsNumber;
    widget.themeNotifier.addListener(_rebuild);
    _loadRemainingProfile();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    widget.themeNotifier.removeListener(_rebuild);
    super.dispose();
  }

  Future<void> _loadRemainingProfile() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _fullName  = p.getString('full_name') ?? 'ESE Member';
      _email     = p.getString('email')     ?? '—';
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
    Navigator.pop(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _LogoutDialog(isLight: _isLight),
    );
    if (confirmed == true && mounted) {
      final p = await SharedPreferences.getInstance();
      await p.clear();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      }
    }
  }

  void _openSettings(BuildContext ctx) {
    Navigator.pop(ctx);
    Navigator.push(
      ctx,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) =>
            SettingsScreen(themeNotifier: widget.themeNotifier),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_bg1, _bg2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(right: BorderSide(color: _bdr, width: 1)),
              boxShadow: _isLight
                  ? [BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 24,
                  offset: const Offset(4, 0))]
                  : [],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: _DrawerHeader(
                        initials:  _initials,
                        fullName:  _fullName,
                        email:     _email,
                        cdsNumber: _cdsNumber,
                        isLight:   _isLight,
                        gold:      _gold,
                        goldLight: _goldL,
                        textPrim:  _textPrim,
                        textSub:   _textSub,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  FadeTransition(
                    opacity: _itemsFade,
                    child: _SectionLabel(label: 'MAIN MENU', color: _textMut),
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
                                item:     e.value,
                                index:    e.key,
                                selected: _selectedIndex == e.key,
                                isLight:  _isLight,
                                gold:     _gold,
                                teal:     _teal,
                                surface:  _surface,
                                border:   _border,
                                textPrim: _textPrim,
                                textSub:  _textSub,
                                onTap: () =>
                                    setState(() => _selectedIndex = e.key),
                              )),

                          const SizedBox(height: 16),
                          _SectionLabel(label: 'ACCOUNT', color: _textMut),
                          const SizedBox(height: 4),

                          ..._secondaryItems.asMap().entries.map((e) {
                            final idx        = _mainItems.length + e.key;
                            final isSettings = e.key == _settingsSecondaryIndex;
                            return _DrawerNavItem(
                              item:     e.value,
                              index:    idx,
                              selected: _selectedIndex == idx,
                              isLight:  _isLight,
                              gold:     _gold,
                              teal:     _teal,
                              surface:  _surface,
                              border:   _border,
                              textPrim: _textPrim,
                              textSub:  _textSub,
                              onTap: () {
                                setState(() => _selectedIndex = idx);
                                if (isSettings) {
                                  Future.delayed(
                                    const Duration(milliseconds: 120),
                                        () => _openSettings(context),
                                  );
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                            );
                          }),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  FadeTransition(
                    opacity: _itemsFade,
                    child: _DrawerFooter(
                      onLogout: _handleLogout,
                      red:      _red,
                      border:   _border,
                    ),
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
  final bool   isLight;
  final Color  gold, goldLight, textPrim, textSub;

  const _DrawerHeader({
    required this.initials,
    required this.fullName,
    required this.email,
    required this.cdsNumber,
    required this.isLight,
    required this.gold,
    required this.goldLight,
    required this.textPrim,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    final h1 = isLight ? _Light.headerBg1 : _Dark.headerBg1;
    final h2 = isLight ? _Light.headerBg2 : _Dark.headerBg2;
    final a1 = isLight ? _Light.avatarBg1 : _Dark.avatarBg1;
    final a2 = isLight ? _Light.avatarBg2 : _Dark.avatarBg2;
    final bdr = isLight ? _Light.border   : _Dark.border;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [h1, h2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(
            color: isLight
                ? Colors.black.withOpacity(0.07)
                : gold.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Avatar
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFD4A030), Color(0xFF8B5E10)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [BoxShadow(
                  color: gold.withOpacity(0.30),
                  blurRadius: 14,
                  offset: const Offset(0, 3))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [a1, a2],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: Center(
                  child: Text(initials,
                      style: TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: gold, letterSpacing: 0.5)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + email
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fullName, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                      color: textPrim, letterSpacing: 0.2)),
              const SizedBox(height: 3),
              Text(email, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: textSub)),
            ],
          )),
        ]),

        const SizedBox(height: 12),

        // CDS pill
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: gold.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: gold.withOpacity(0.20), width: 1),
          ),
          child: Row(children: [
            Icon(Icons.credit_card_rounded,
                color: gold.withOpacity(0.70), size: 13),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('CDS NUMBER',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700,
                      color: textSub, letterSpacing: 1.2)),
              const SizedBox(height: 2),
              Text(cdsNumber,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                      color: goldLight, letterSpacing: 0.6)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final Color  color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
      child: Text(label,
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
              color: color, letterSpacing: 1.4)),
    );
  }
}

// ─── Drawer Nav Item ──────────────────────────────────────────────────────────
class _DrawerNavItem extends StatefulWidget {
  final _DrawerItem  item;
  final int          index;
  final bool         selected;
  final bool         isLight;
  final Color        gold, teal, surface, border, textPrim, textSub;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.item,
    required this.index,
    required this.selected,
    required this.isLight,
    required this.gold,
    required this.teal,
    required this.surface,
    required this.border,
    required this.textPrim,
    required this.textSub,
    required this.onTap,
  });

  @override
  State<_DrawerNavItem> createState() => _DrawerNavItemState();
}

class _DrawerNavItemState extends State<_DrawerNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 80));
    _scale = Tween(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    // Badge color resolves to per-theme teal/gold when no override
    Color badgeColor = widget.item.badgeColor ?? widget.gold;
    // If the original badge color was the dark teal, map to current theme teal
    if (widget.item.badgeColor == _Dark.teal) {
      badgeColor = widget.teal;
    } else if (widget.item.badgeColor == _Dark.gold) {
      badgeColor = widget.gold;
    }

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown:  (_) => _ctrl.forward(),
        onTapUp:    (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: () => _ctrl.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: widget.selected
                ? widget.gold.withOpacity(widget.isLight ? 0.08 : 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.selected
                  ? widget.gold.withOpacity(0.22)
                  : Colors.transparent,
              width: 1,
            ),
            boxShadow: widget.selected && widget.isLight
                ? [BoxShadow(color: widget.gold.withOpacity(0.10),
                blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          child: Row(children: [
            // Icon box
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: widget.selected
                    ? widget.gold.withOpacity(0.15)
                    : widget.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.selected
                      ? widget.gold.withOpacity(0.28)
                      : widget.border,
                  width: 1,
                ),
              ),
              child: Icon(widget.item.icon, size: 15,
                  color: widget.selected ? widget.gold : widget.textSub),
            ),
            const SizedBox(width: 12),

            // Label
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.selected
                      ? FontWeight.w700 : FontWeight.w500,
                  color: widget.selected ? widget.textPrim : widget.textSub,
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
                  color: badgeColor.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: badgeColor.withOpacity(0.30), width: 1),
                ),
                child: Text(widget.item.badge!,
                    style: TextStyle(fontSize: 9,
                        fontWeight: FontWeight.w700, color: badgeColor)),
              ),

            if (widget.selected) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded,
                  color: widget.gold, size: 16),
            ],
          ]),
        ),
      ),
    );
  }
}

// ─── Drawer Footer ────────────────────────────────────────────────────────────
class _DrawerFooter extends StatelessWidget {
  final VoidCallback onLogout;
  final Color        red, border;
  const _DrawerFooter({
    required this.onLogout,
    required this.red,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: border.withOpacity(0.6), width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: GestureDetector(
          onTap: onLogout,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: red.withOpacity(0.18), width: 1),
            ),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: red.withOpacity(0.25), width: 1),
                ),
                child: Icon(Icons.logout_rounded, color: red, size: 15),
              ),
              const SizedBox(width: 12),
              Text('Log Out',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: red, letterSpacing: 0.2)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: red.withOpacity(0.50), size: 12),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Logout Confirmation Dialog ───────────────────────────────────────────────
class _LogoutDialog extends StatelessWidget {
  final bool isLight;
  const _LogoutDialog({required this.isLight});

  @override
  Widget build(BuildContext context) {
    final bg      = isLight ? _Light.card      : _Dark.card;
    final bdr     = isLight ? _Light.border    : _Dark.border;
    final tPrim   = isLight ? _Light.textPrim  : _Dark.textPrim;
    final tSub    = isLight ? _Light.textSub   : _Dark.textSub;
    final cancel  = isLight ? const Color(0xFFF0F4FB) : const Color(0xFF0D1728);
    final red     = isLight ? _Light.red       : _Dark.red;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: bdr, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isLight ? 0.12 : 0.55),
              blurRadius: 48,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: red.withOpacity(0.09), shape: BoxShape.circle,
              border: Border.all(color: red.withOpacity(0.22), width: 1.5),
            ),
            child: Icon(Icons.logout_rounded, color: red, size: 22),
          ),
          const SizedBox(height: 16),
          Text('Log Out?', style: TextStyle(fontSize: 17,
              fontWeight: FontWeight.w800, color: tPrim)),
          const SizedBox(height: 8),
          Text('You will be returned to the login screen.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: tSub.withOpacity(0.75))),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                height: 44,
                decoration: BoxDecoration(color: cancel,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: bdr)),
                child: Center(child: Text('Cancel',
                    style: TextStyle(fontSize: 13.5,
                        fontWeight: FontWeight.w600, color: tSub))),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context, true),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: red.withOpacity(0.32), width: 1),
                ),
                child: Center(child: Text('Log Out',
                    style: TextStyle(fontSize: 13.5,
                        fontWeight: FontWeight.w700, color: red))),
              ),
            )),
          ]),
        ]),
      ),
    );
  }
}