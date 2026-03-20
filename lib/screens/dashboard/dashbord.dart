import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../market_watch/market_watch.dart';
import '../market_watch/market_watch_screengraph.dart';
import '../profile/profile.dart';
import '../trade/trade.dart';
import 'drawer.dart';

// ─── Dark tokens ──────────────────────────────────────────────────────────────
class _Dark {
  static const bg        = Color(0xFF060C1A);
  static const surface   = Color(0xFF0D1728);
  static const card      = Color(0xFF111F35);
  static const border    = Color(0xFF1E2E45);
  static const gold      = Color(0xFFD4A030);
  static const goldLight = Color(0xFFF5D98B);
  static const navy      = Color(0xFF0A1628);
  static const blue      = Color(0xFF1565C0);
  static const teal      = Color(0xFF26A69A);
  static const red       = Color(0xFFEF5350);
  static const textPrim  = Color(0xFFEEF2FF);
  static const textSub   = Color(0xFF7A8BA8);
  static const textMuted = Color(0xFF3D5470);

  // Hero card gradients
  static const heroGrad = [Color(0xFF0D1E3A), Color(0xFF0A1628), Color(0xFF081320)];
  static const orderGrad = [Color(0xFF0A1F2E), Color(0xFF0D2A3A), Color(0xFF0A1F2E)];

  // Bottom nav
  static const navBg = Color(0xFF0D1728);
}

// ─── Light tokens ─────────────────────────────────────────────────────────────
class _Light {
  static const bg        = Color(0xFFF0F4FB);
  static const surface   = Color(0xFFFFFFFF);
  static const card      = Color(0xFFFFFFFF);
  static const border    = Color(0xFFDDE3EF);
  static const gold      = Color(0xFFC49020);
  static const goldLight = Color(0xFF8B6010);
  static const navy      = Color(0xFF1A3A6B);
  static const blue      = Color(0xFF1565C0);
  static const teal      = Color(0xFF1A8A80);
  static const red       = Color(0xFFD43F3C);
  static const textPrim  = Color(0xFF0D1728);
  static const textSub   = Color(0xFF64748B);
  static const textMuted = Color(0xFFADB5C7);

  // Hero card gradients
  static const heroGrad = [Color(0xFFEDF4FF), Color(0xFFE4EEF9), Color(0xFFD8E8F5)];
  static const orderGrad = [Color(0xFFF5FAFF), Color(0xFFEBF4FF), Color(0xFFF5FAFF)];

  // Bottom nav
  static const navBg = Color(0xFFFFFFFF);
}

// ─── Dashboard Screen ─────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _navIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _forenames = '';
  String _cdsNumber = '';
  String _initials  = '';


  late AnimationController _entranceCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _tickerCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset>  _headerSlide;
  late Animation<double> _cardFade;
  late Animation<Offset>  _cardSlide;
  late Animation<double> _contentFade;
  late Animation<double> _pulse;
  late Animation<double> _shimmer;

  // ── Theme helpers ────────────────────────────────────────────────────────
  bool   get _isLight  => appThemeNotifier.isLight;
  Color  get _bg       => _isLight ? _Light.bg       : _Dark.bg;
  Color  get _surface  => _isLight ? _Light.surface  : _Dark.surface;
  Color  get _card     => _isLight ? _Light.card     : _Dark.card;
  Color  get _border   => _isLight ? _Light.border   : _Dark.border;
  Color  get _gold     => _isLight ? _Light.gold     : _Dark.gold;
  Color  get _goldL    => _isLight ? _Light.goldLight: _Dark.goldLight;
  Color  get _teal     => _isLight ? _Light.teal     : _Dark.teal;
  Color  get _red      => _isLight ? _Light.red      : _Dark.red;
  Color  get _textPrim => _isLight ? _Light.textPrim : _Dark.textPrim;
  Color  get _textSub  => _isLight ? _Light.textSub  : _Dark.textSub;
  Color  get _textMut  => _isLight ? _Light.textMuted: _Dark.textMuted;

  @override
  void initState() {
    super.initState();
    appThemeNotifier.addListener(_rebuild);

    _entranceCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1400));
    _pulseCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2600))..repeat(reverse: true);
    _shimmerCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2200))..repeat();
    _tickerCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 18))..repeat();

    _headerFade  = CurvedAnimation(parent: _entranceCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut));
    _headerSlide = Tween(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)));
    _cardFade    = CurvedAnimation(parent: _entranceCtrl,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOut));
    _cardSlide   = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl,
        curve: const Interval(0.15, 0.60, curve: Curves.easeOutCubic)));
    _contentFade = CurvedAnimation(parent: _entranceCtrl,
        curve: const Interval(0.40, 0.90, curve: Curves.easeOut));
    _pulse       = Tween(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _shimmer     = Tween(begin: -1.5, end: 2.5).animate(
        CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));

    _loadProfile();
  }

  void _rebuild() => setState(() {});

  Future<void> _loadProfile() async {
    final p         = await SharedPreferences.getInstance();
    final forenames = p.getString('forenames') ?? '';
    final surname   = p.getString('surname')   ?? '';
    setState(() {
      _forenames = forenames;
      _cdsNumber = p.getString('cds_number') ?? '—';
      _initials  = '${forenames.isNotEmpty ? forenames[0] : ''}'
          '${surname.isNotEmpty ? surname[0] : ''}'.toUpperCase();
      if (_initials.isEmpty) _initials = 'U';
    });
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    _tickerCtrl.dispose();
    appThemeNotifier.removeListener(_rebuild);
    super.dispose();
  }

  void _onNavTap(int i) {
    if (i == 4) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => ProfileScreen(themeNotifier: appThemeNotifier),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 280),
        ),
      );
      return;
    }
    setState(() => _navIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
      _isLight ? Brightness.dark : Brightness.light,
    ));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: _bg,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        extendBody: true,
        drawer: AppDrawer(
          initials:      _initials,
          cdsNumber:     _cdsNumber,
          themeNotifier: appThemeNotifier,
        ),
        body: Stack(children: [
          // Ambient glow orbs
          Positioned(top: -60, right: -40,
              child: _GlowOrb(size: 220, color: _gold, opacity: 0.07)),
          Positioned(top: 200, left: -60,
              child: _GlowOrb(size: 180,
                  color: _isLight ? _Light.blue : _Dark.blue,
                  opacity: _isLight ? 0.05 : 0.08)),

          SafeArea(
            bottom: false,
            child: Column(children: [
              FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: _TopBar(
                    shimmer:       _shimmer,
                    forenames:     _forenames,
                    initials:      _initials,
                    cdsNumber:     _cdsNumber,
                    isLight:       _isLight,
                    gold:          _gold,
                    goldLight:     _goldL,
                    surface:       _surface,
                    border:        _border,
                    textPrim:      _textPrim,
                    textSub:       _textSub,
                    onMenuTap:     () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      FadeTransition(
                        opacity: _cardFade,
                        child: SlideTransition(
                          position: _cardSlide,
                          child: _PortfolioHeroCard(
                            pulse:    _pulse,
                            isLight:  _isLight,
                            gold:     _gold,
                            teal:     _teal,
                            border:   _border,
                            textSub:  _textSub,
                            textPrim: _textPrim,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      FadeTransition(
                        opacity: _cardFade,
                        child: _PlaceOrderButton(
                          isLight: _isLight,
                          gold:    _gold,
                          teal:    _teal,
                          red:     _red,
                          border:  _border,
                          textPrim: _textPrim,
                        ),
                      ),

                      const SizedBox(height: 12),

                      FadeTransition(
                        opacity: _cardFade,
                        child: _ActionButtons(
                          isLight:  _isLight,
                          card:     _card,
                          border:   _border,
                          gold:     _gold,
                          teal:     _teal,
                          red:      _red,
                          textSub:  _textSub,
                        ),
                      ),

                      const SizedBox(height: 22),

                      FadeTransition(
                        opacity: _contentFade,
                        child: MarketWatch(themeNotifier: appThemeNotifier),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ]),

        bottomNavigationBar: _BottomNav(
          currentIndex: _navIndex,
          onTap:        _onNavTap,
          isLight:      _isLight,
          gold:         _gold,
          border:       _border,
          textMuted:    _textMut,
          navBg:        _isLight ? _Light.navBg : _Dark.navBg,
        ),
        floatingActionButton: _FAB(
          isLight: _isLight,
          gold:    _gold,
          bg:      _bg,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final Animation<double> shimmer;
  final String     forenames, initials, cdsNumber;
  final bool       isLight;
  final Color      gold, goldLight, surface, border, textPrim, textSub;
  final VoidCallback onMenuTap;

  const _TopBar({
    required this.shimmer,
    required this.forenames,
    required this.initials,
    required this.cdsNumber,
    required this.isLight,
    required this.gold,
    required this.goldLight,
    required this.surface,
    required this.border,
    required this.textPrim,
    required this.textSub,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final hour     = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning'
        : hour < 17 ? 'Good afternoon'
        : 'Good evening';

    final avatarInner1 = isLight ? const Color(0xFFFFF8EE) : const Color(0xFF0D1A33);
    final avatarInner2 = isLight ? const Color(0xFFFFF3DC) : const Color(0xFF142444);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        // Avatar / menu
        GestureDetector(
          onTap: onMenuTap,
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [Color(0xFFD4A030), Color(0xFF8B5E10)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              border: Border.all(color: gold.withOpacity(0.45), width: 1.5),
              boxShadow: [BoxShadow(color: gold.withOpacity(0.28),
                  blurRadius: 14, offset: const Offset(0, 3))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.5),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [avatarInner1, avatarInner2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(initials,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
                          color: gold, letterSpacing: 1)),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Greeting + CDS pill
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(
                  '$greeting, ${forenames.isNotEmpty ? forenames.split(' ').first : 'Investor'}',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700,
                      color: textPrim),
                ),
                const SizedBox(width: 4),
                const Text('👋', style: TextStyle(fontSize: 12)),
              ]),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: gold.withOpacity(0.22), width: 1),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.credit_card_rounded,
                      color: gold.withOpacity(0.75), size: 9),
                  const SizedBox(width: 4),
                  Text(cdsNumber,
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700,
                          color: gold.withOpacity(0.90), letterSpacing: 0.4)),
                ]),
              ),
            ],
          ),
        ),

        // Notification bell
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: border, width: 1),
            boxShadow: isLight
                ? [BoxShadow(color: Colors.black.withOpacity(0.06),
                blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          child: Stack(alignment: Alignment.center, children: [
            Icon(Icons.notifications_outlined, color: textSub, size: 19),
            Positioned(
              top: 7, right: 7,
              child: Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: gold),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─── Portfolio Hero Card ──────────────────────────────────────────────────────
class _PortfolioHeroCard extends StatelessWidget {
  final Animation<double> pulse;
  final bool  isLight;
  final Color gold, teal, border, textSub, textPrim;

  const _PortfolioHeroCard({
    required this.pulse,
    required this.isLight,
    required this.gold,
    required this.teal,
    required this.border,
    required this.textSub,
    required this.textPrim,
  });

  @override
  Widget build(BuildContext context) {
    final gradColors = isLight ? _Light.heroGrad : _Dark.heroGrad;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: gradColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: gold.withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(
              color: isLight
                  ? Colors.black.withOpacity(0.08)
                  : gold.withOpacity(0.10),
              blurRadius: 30, offset: const Offset(0, 8)),
          BoxShadow(
              color: Colors.black.withOpacity(isLight ? 0.06 : 0.40),
              blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: CustomPaint(painter: _CardBgPainter(gold: gold)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Portfolio Value',
                      style: TextStyle(fontSize: 11.5, color: textSub,
                          letterSpacing: 0.4)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: teal.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: teal.withOpacity(0.30), width: 1),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.arrow_upward_rounded, color: teal, size: 11),
                      const SizedBox(width: 3),
                      Text('+3.2% today',
                          style: TextStyle(fontSize: 10,
                              fontWeight: FontWeight.w700, color: teal)),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ShaderMask(
                shaderCallback: (b) => LinearGradient(
                    colors: isLight
                        ? [_Light.textPrim, const Color(0xFF1E3A6B)]
                        : [_Dark.textPrim, const Color(0xFFCCD6F0)])
                    .createShader(b),
                child: const Text('E 4,230.00',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900,
                        color: Colors.white, letterSpacing: -1, height: 1)),
              ),
              const SizedBox(height: 5),
              Row(children: [
                Icon(Icons.trending_up_rounded, color: teal, size: 13),
                const SizedBox(width: 4),
                Text('+E 820 this month',
                    style: TextStyle(fontSize: 11,
                        color: teal.withOpacity(0.85),
                        fontWeight: FontWeight.w500)),
              ]),
              const SizedBox(height: 16),
              Container(height: 1, color: border.withOpacity(0.6)),
              const SizedBox(height: 14),
              Row(children: [
                _SubStat(label: 'Day P&L',
                    value: '+E 148', positive: true, teal: teal,
                    red: isLight ? _Light.red : _Dark.red,
                    textPrim: textPrim, textSub: textSub),
                _SubStatDivider(border: border),
                _SubStat(label: 'Cash Balance',
                    value: 'E 12,480', positive: null, teal: teal,
                    red: isLight ? _Light.red : _Dark.red,
                    textPrim: textPrim, textSub: textSub),
                _SubStatDivider(border: border),
                _SubStat(label: 'Returns',
                    value: '+14.6%', positive: true, teal: teal,
                    red: isLight ? _Light.red : _Dark.red,
                    textPrim: textPrim, textSub: textSub),
              ]),
            ],
          ),
        ),
      ]),
    );
  }
}

class _SubStat extends StatelessWidget {
  final String label, value;
  final bool?  positive;
  final Color  teal, red, textPrim, textSub;

  const _SubStat({
    required this.label, required this.value, required this.positive,
    required this.teal, required this.red,
    required this.textPrim, required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    final color = positive == null ? textPrim : positive! ? teal : red;
    return Expanded(
      child: Column(children: [
        Text(value,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800,
                color: color, letterSpacing: 0.2)),
        const SizedBox(height: 3),
        Text(label,
            style: TextStyle(fontSize: 9, color: textSub, letterSpacing: 0.8)),
      ]),
    );
  }
}

class _SubStatDivider extends StatelessWidget {
  final Color border;
  const _SubStatDivider({required this.border});

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: border.withOpacity(0.6));
}

// ─── Place Order Button ───────────────────────────────────────────────────────
class _PlaceOrderButton extends StatefulWidget {
  final bool  isLight;
  final Color gold, teal, red, border, textPrim;

  const _PlaceOrderButton({
    required this.isLight,
    required this.gold,
    required this.teal,
    required this.red,
    required this.border,
    required this.textPrim,
  });

  @override
  State<_PlaceOrderButton> createState() => _PlaceOrderButtonState();
}

class _PlaceOrderButtonState extends State<_PlaceOrderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final gradColors = widget.isLight ? _Light.orderGrad : _Dark.orderGrad;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown: (_) => _ctrl.forward(),
          onTapUp: (_) {
            _ctrl.reverse();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, a, __) => TradeScreen(themeNotifier: appThemeNotifier),
                transitionsBuilder: (_, a, __, child) => SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                  child: child,
                ),
                transitionDuration: const Duration(milliseconds: 380),
              ),
            );
          },
          onTapCancel: () => _ctrl.reverse(),
          child: Container(
            width: double.infinity,
            height: 62,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: widget.gold.withOpacity(0.28), width: 1.2),
              boxShadow: [
                BoxShadow(
                    color: widget.isLight
                        ? Colors.black.withOpacity(0.07)
                        : widget.gold.withOpacity(0.10),
                    blurRadius: 20, offset: const Offset(0, 6)),
                BoxShadow(
                    color: Colors.black.withOpacity(widget.isLight ? 0.06 : 0.35),
                    blurRadius: 12, offset: const Offset(0, 3)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.gold.withOpacity(0.12),
                    border: Border.all(
                        color: widget.gold.withOpacity(0.30), width: 1),
                  ),
                  child: Icon(Icons.candlestick_chart_rounded,
                      color: widget.gold, size: 17),
                ),
                const SizedBox(width: 12),
                Text('Place Order',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900,
                        color: widget.textPrim, letterSpacing: 0.4)),
                const SizedBox(width: 14),
                Container(width: 1, height: 28,
                    color: widget.border.withOpacity(0.6)),
                const SizedBox(width: 14),

                // Buy pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: widget.teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: widget.teal.withOpacity(0.28), width: 1),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.arrow_upward_rounded,
                        color: widget.teal, size: 10),
                    const SizedBox(width: 3),
                    Text('Buy', style: TextStyle(fontSize: 10,
                        fontWeight: FontWeight.w800, color: widget.teal)),
                  ]),
                ),
                const SizedBox(width: 8),

                // Sell pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: widget.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: widget.red.withOpacity(0.28), width: 1),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.arrow_downward_rounded,
                        color: widget.red, size: 10),
                    const SizedBox(width: 3),
                    Text('Sell', style: TextStyle(fontSize: 10,
                        fontWeight: FontWeight.w800, color: widget.red)),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final bool  isLight;
  final Color card, border, gold, teal, red, textSub;

  const _ActionButtons({
    required this.isLight,
    required this.card,
    required this.border,
    required this.gold,
    required this.teal,
    required this.red,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        _ActionBtn(icon: Icons.receipt_long_rounded, label: 'My Orders',
            color: gold, card: card, textSub: textSub, isLight: isLight,
            onTap: () {}),
        const SizedBox(width: 10),
        _ActionBtn(icon: Icons.account_balance_wallet_outlined, label: 'Deposit',
            color: teal, card: card, textSub: textSub, isLight: isLight,
            onTap: () {}),
        const SizedBox(width: 10),
        _ActionBtn(icon: Icons.money_rounded, label: 'Withdrawal',
            color: isLight ? _Light.blue : _Dark.blue,
            card: card, textSub: textSub, isLight: isLight,
            onTap: () {}),
        const SizedBox(width: 10),
        _ActionBtn(icon: Icons.swap_horiz_rounded, label: 'Settlements',
            color: const Color(0xFF9C6ADE),
            card: card, textSub: textSub, isLight: isLight,
            onTap: () {}),
      ]),
    );
  }
}

class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final String   label;
  final Color    color, card, textSub;
  final bool     isLight;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon, required this.label,
    required this.color, required this.card, required this.textSub,
    required this.isLight, required this.onTap,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 90));
    _scale = Tween(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown:   (_) => _ctrl.forward(),
          onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
          onTapCancel: ()  => _ctrl.reverse(),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: widget.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: widget.color.withOpacity(0.20), width: 1),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(
                        widget.isLight ? 0.06 : 0.22),
                    blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: widget.color.withOpacity(0.22), width: 1),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 16),
                ),
                const SizedBox(height: 5),
                Text(widget.label,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                        color: widget.textSub, letterSpacing: 0.2),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool  isLight;
  final Color gold, border, textMuted, navBg;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.isLight,
    required this.gold,
    required this.border,
    required this.textMuted,
    required this.navBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 14,
          top: 8,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 64,
              decoration: BoxDecoration(
                color: navBg.withOpacity(isLight ? 0.92 : 0.75),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                    color: isLight
                        ? border
                        : gold.withOpacity(0.14),
                    width: 1),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(isLight ? 0.10 : 0.45),
                      blurRadius: 32, offset: const Offset(0, 10)),
                  BoxShadow(
                      color: gold.withOpacity(isLight ? 0.04 : 0.06),
                      blurRadius: 20, offset: const Offset(0, -2)),
                ],
              ),
              child: Row(children: [
                _NavItem(icon: Icons.pie_chart_outline_rounded,
                    activeIcon: Icons.pie_chart_rounded,
                    label: 'Portfolio', index: 0,
                    current: currentIndex, onTap: onTap,
                    gold: gold, textMuted: textMuted),
                _NavItem(icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart_rounded,
                    label: 'Deposit', index: 1,
                    current: currentIndex, onTap: onTap,
                    gold: gold, textMuted: textMuted),
                const Expanded(child: SizedBox()),
                _NavItem(icon: Icons.money_rounded,
                    activeIcon: Icons.money_rounded,
                    label: 'Withdrawal', index: 3,
                    current: currentIndex, onTap: onTap,
                    gold: gold, textMuted: textMuted),
                _NavItem(icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile', index: 4,
                    current: currentIndex, onTap: onTap,
                    gold: gold, textMuted: textMuted),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String   label;
  final int      index, current;
  final Color    gold, textMuted;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon, required this.activeIcon, required this.label,
    required this.index, required this.current, required this.onTap,
    required this.gold, required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child)),
              child: selected
                  ? Container(
                key: const ValueKey('on'),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: gold.withOpacity(0.28), width: 1),
                ),
                child: Icon(activeIcon, size: 17, color: gold),
              )
                  : Padding(
                key: const ValueKey('off'),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 5),
                child: Icon(icon, size: 19, color: textMuted),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? gold : textMuted,
                letterSpacing: 0.3,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── FAB ──────────────────────────────────────────────────────────────────────
class _FAB extends StatefulWidget {
  final bool  isLight;
  final Color gold, bg;
  const _FAB({required this.isLight, required this.gold, required this.bg});

  @override
  State<_FAB> createState() => _FABState();
}

class _FABState extends State<_FAB> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.90)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad + 46),
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown: (_) => _ctrl.forward(),
          onTapUp: (_) {
            _ctrl.reverse();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, a, __) => MarketWatchScreen(themeNotifier: appThemeNotifier),
                transitionsBuilder: (_, a, __, child) =>
                    FadeTransition(opacity: a, child: child),
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          onTapCancel: () => _ctrl.reverse(),
          child: Container(
            width: 58, height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFD4A030), Color(0xFFB8860B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: widget.gold.withOpacity(0.50),
                    blurRadius: 22, offset: const Offset(0, 6),
                    spreadRadius: -2),
                BoxShadow(color: Colors.black.withOpacity(0.40),
                    blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(Icons.candlestick_chart_rounded,
                color: widget.bg, size: 24),
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _GlowOrb extends StatelessWidget {
  final double size, opacity;
  final Color  color;
  const _GlowOrb(
      {required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
            colors: [color.withOpacity(opacity), Colors.transparent]),
      ),
    );
  }
}

class _CardBgPainter extends CustomPainter {
  final Color gold;
  const _CardBgPainter({required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width * 1.1, size.height * 0.5),
          radius: size.width * 0.7),
      math.pi * 0.6, math.pi * 0.6, false,
      Paint()
        ..color = gold.withOpacity(0.06)
        ..strokeWidth = 60
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.1), 80,
      Paint()
        ..shader = RadialGradient(colors: [
          gold.withOpacity(0.10),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(
            center: Offset(size.width * 0.9, size.height * 0.1),
            radius: 80)),
    );
  }

  @override
  bool shouldRepaint(_CardBgPainter old) => old.gold != gold;
}