import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../market_watch/market_watch.dart';
import '../market_watch/market_watch_screengraph.dart';
import '../profile/profile.dart';
import '../trade/trade.dart';
import '../transactions/recent_transactions.dart';
import 'drawer.dart';

// ─── ESE Color Palette ────────────────────────────────────────────────────────
class _C {
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

  // ── SharedPreferences profile data ───────────────────────────────────────
  String _forenames  = '';
  String _cdsNumber  = '';
  String _initials   = '';

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

  @override
  void initState() {
    super.initState();
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

  Future<void> _loadProfile() async {
    final p = await SharedPreferences.getInstance();
    final forenames = p.getString('forenames') ?? '';
    final surname   = p.getString('surname')   ?? '';
    setState(() {
      _forenames = forenames;
      _cdsNumber = p.getString('cds_number') ?? '—';
      _initials  = '${forenames.isNotEmpty ? forenames[0] : ''}'
          '${surname.isNotEmpty   ? surname[0]   : ''}'
          .toUpperCase();
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
    super.dispose();
  }

  void _onNavTap(int i) {
    if (i == 4) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => const ProfileScreen(),
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _C.bg,
      extendBody: true,
      drawer: AppDrawer(
        initials:  _initials,
        cdsNumber: _cdsNumber,
      ),
      body: Stack(
        children: [
          Positioned(top: -60, right: -40,
              child: _GlowOrb(size: 220, color: _C.gold, opacity: 0.07)),
          Positioned(top: 200, left: -60,
              child: _GlowOrb(size: 180, color: _C.blue, opacity: 0.08)),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: _TopBar(
                      shimmer:    _shimmer,
                      forenames:  _forenames,
                      initials:   _initials,
                      cdsNumber:  _cdsNumber,
                      onMenuTap:  () => _scaffoldKey.currentState?.openDrawer(),
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
                            child: _PortfolioHeroCard(pulse: _pulse),
                          ),
                        ),

                        const SizedBox(height: 14),

                        FadeTransition(
                          opacity: _cardFade,
                          child: const _QuickActions(),
                        ),

                        const SizedBox(height: 20),

                        FadeTransition(
                          opacity: _contentFade,
                          child: const _StatsRow(),
                        ),

                        const SizedBox(height: 22),

                        FadeTransition(
                          opacity: _contentFade,
                          child: const MarketWatch(),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
      floatingActionButton: const _FAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final Animation<double> shimmer;
  final String  forenames;
  final String  initials;
  final String  cdsNumber;
  final VoidCallback onMenuTap;

  const _TopBar({
    required this.shimmer,
    required this.forenames,
    required this.initials,
    required this.cdsNumber,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    // Greeting based on time of day
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning'
        : hour < 17 ? 'Good afternoon'
        : 'Good evening';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // ── Avatar / Menu button ───────────────────────────────────────
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
                border: Border.all(
                    color: _C.gold.withOpacity(0.45), width: 1.5),
                boxShadow: [
                  BoxShadow(color: _C.gold.withOpacity(0.28),
                      blurRadius: 14, offset: const Offset(0, 3)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(1.5),
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
                    child: Text(
                      initials,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: _C.goldLight,
                          letterSpacing: 1),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ── Greeting + CDS ─────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$greeting, ${forenames.isNotEmpty ? forenames.split(' ').first : 'Investor'}',
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700,
                          color: _C.textPrim),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                // ── CDS Number pill ──────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _C.gold.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: _C.gold.withOpacity(0.22), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.credit_card_rounded,
                              color: _C.gold.withOpacity(0.75), size: 9),
                          const SizedBox(width: 4),
                          Text(
                            cdsNumber,
                            style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: _C.gold.withOpacity(0.90),
                                letterSpacing: 0.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Notification bell ──────────────────────────────────────────
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _C.border, width: 1),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.notifications_outlined,
                    color: _C.textSub, size: 19),
                Positioned(
                  top: 7, right: 7,
                  child: Container(
                    width: 7, height: 7,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: _C.gold),
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

// ─── Portfolio Hero Card ──────────────────────────────────────────────────────
class _PortfolioHeroCard extends StatelessWidget {
  final Animation<double> pulse;
  const _PortfolioHeroCard({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1E3A), Color(0xFF0A1628), Color(0xFF081320)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _C.gold.withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(color: _C.gold.withOpacity(0.10),
              blurRadius: 30, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withOpacity(0.40),
              blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CustomPaint(painter: _CardBgPainter()),
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
                        style: TextStyle(
                            fontSize: 11.5, color: _C.textSub,
                            letterSpacing: 0.4)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _C.teal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _C.teal.withOpacity(0.30), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.arrow_upward_rounded,
                              color: _C.teal, size: 11),
                          SizedBox(width: 3),
                          Text('+3.2% today',
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w700,
                                  color: _C.teal)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                      colors: [_C.textPrim, Color(0xFFCCD6F0)]).createShader(b),
                  child: const Text('E 4,230.00',
                      style: TextStyle(
                          fontSize: 36, fontWeight: FontWeight.w900,
                          color: Colors.white, letterSpacing: -1, height: 1)),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.trending_up_rounded,
                        color: _C.teal, size: 13),
                    const SizedBox(width: 4),
                    Text('+E 820 this month',
                        style: TextStyle(
                            fontSize: 11,
                            color: _C.teal.withOpacity(0.85),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: _C.border.withOpacity(0.6)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _SubStat(label: 'Day P&L',
                        value: '+E 148', positive: true),
                    _SubStatDivider(),
                    _SubStat(label: 'Cash Balance',
                        value: 'E 12,480', positive: null),
                    _SubStatDivider(),
                    _SubStat(label: 'Returns',
                        value: '+14.6%', positive: true),
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

class _SubStat extends StatelessWidget {
  final String label, value;
  final bool? positive;
  const _SubStat({required this.label, required this.value, this.positive});

  @override
  Widget build(BuildContext context) {
    final color = positive == null
        ? _C.textPrim
        : positive! ? _C.teal : _C.red;
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w800,
                  color: color, letterSpacing: 0.2)),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 9, color: _C.textSub, letterSpacing: 0.8)),
        ],
      ),
    );
  }
}

class _SubStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: _C.border.withOpacity(0.6));
}

// ─── Quick Actions ────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _TradeButton(
        onTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, a, __) => const TradeScreen(),
            transitionsBuilder: (_, a, __, child) => SlideTransition(
              position: Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: a,
                  curve: Curves.easeOutCubic)),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 380),
          ),
        ),
      ),
    );
  }
}

class _TradeButton extends StatefulWidget {
  final VoidCallback onTap;
  const _TradeButton({required this.onTap});

  @override
  State<_TradeButton> createState() => _TradeButtonState();
}

class _TradeButtonState extends State<_TradeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 100));
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
        onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0E2A14), Color(0xFF1A3D1E), Color(0xFF0E2A14)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _C.gold.withOpacity(0.30), width: 1.2),
            boxShadow: [
              BoxShadow(color: _C.gold.withOpacity(0.12),
                  blurRadius: 20, offset: const Offset(0, 6)),
              BoxShadow(color: Colors.black.withOpacity(0.30),
                  blurRadius: 12, offset: const Offset(0, 3)),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 40, right: 40, top: 0,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      _C.gold.withOpacity(0.20),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _C.gold.withOpacity(0.12),
                      border: Border.all(
                          color: _C.gold.withOpacity(0.30), width: 1),
                    ),
                    child: const Icon(Icons.candlestick_chart_rounded,
                        color: _C.gold, size: 16),
                  ),
                  const SizedBox(width: 12),
                  const Text('Trade',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                          color: _C.gold, letterSpacing: 0.8)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _C.teal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _C.teal.withOpacity(0.25), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.arrow_upward_rounded,
                            color: _C.teal, size: 9),
                        SizedBox(width: 2),
                        Text('Buy', style: TextStyle(fontSize: 9,
                            fontWeight: FontWeight.w700, color: _C.teal)),
                        SizedBox(width: 6),
                        SizedBox(width: 1, height: 10),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_downward_rounded,
                            color: _C.red, size: 9),
                        SizedBox(width: 2),
                        Text('Sell', style: TextStyle(fontSize: 9,
                            fontWeight: FontWeight.w700, color: _C.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: const [
          _StatCard(
            label: 'Cash Balance', value: 'E 12,480',
            sub: '+E820 today', icon: Icons.account_balance_wallet_outlined,
            accentColor: _C.teal,
          ),
          _StatCard(
            label: 'Pending Settlements', value: 'E 1,560',
            sub: '3 pending', icon: Icons.hourglass_top_rounded,
            accentColor: _C.blue,
          ),
          _StatCard(
            label: 'Open Orders', value: '7',
            sub: '2 expiring today', icon: Icons.receipt_long_outlined,
            accentColor: _C.gold,
          ),
          _StatCard(
            label: 'Matched Orders', value: '3',
            sub: 'This week', icon: Icons.check_circle_outline_rounded,
            accentColor: _C.teal,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color accentColor;

  const _StatCard({
    required this.label, required this.value, required this.sub,
    required this.icon, required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25),
              blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 14),
              ),
              const Spacer(),
              Container(
                width: 5, height: 5,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withOpacity(0.5)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900,
                      color: _C.textPrim, letterSpacing: -0.5, height: 1.1)),
              const SizedBox(height: 3),
              Text(label,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 9, color: _C.textSub, letterSpacing: 0.4)),
              const SizedBox(height: 3),
              Text(sub,
                  style: TextStyle(
                      fontSize: 9.5,
                      color: accentColor.withOpacity(0.85),
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

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
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF0D1728).withOpacity(0.75),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: _C.gold.withOpacity(0.14), width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.45),
                      blurRadius: 32, offset: const Offset(0, 10)),
                  BoxShadow(color: _C.gold.withOpacity(0.06),
                      blurRadius: 20, offset: const Offset(0, -2)),
                ],
              ),
              child: Row(
                children: [
                  _NavItem(icon: Icons.pie_chart_outline_rounded,
                      activeIcon: Icons.pie_chart_rounded,
                      label: 'Portfolio', index: 0,
                      current: currentIndex, onTap: onTap),
                  _NavItem(icon: Icons.bar_chart_outlined,
                      activeIcon: Icons.bar_chart_rounded,
                      label: 'Deposit', index: 1,
                      current: currentIndex, onTap: onTap),
                  const Expanded(child: SizedBox()),
                  _NavItem(icon: Icons.money_rounded,
                      activeIcon: Icons.money_rounded,
                      label: 'Withdrawal', index: 3,
                      current: currentIndex, onTap: onTap),
                  _NavItem(icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile', index: 4,
                      current: currentIndex, onTap: onTap),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon, required this.activeIcon, required this.label,
    required this.index, required this.current, required this.onTap,
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
                  color: _C.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _C.gold.withOpacity(0.28), width: 1),
                ),
                child: Icon(activeIcon, size: 17, color: _C.gold),
              )
                  : Padding(
                key: const ValueKey('off'),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 5),
                child: Icon(icon, size: 19, color: _C.textMuted),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? _C.gold : _C.textMuted,
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
  const _FAB();
  @override
  State<_FAB> createState() => _FABState();
}

class _FABState extends State<_FAB> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

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
                pageBuilder: (_, a, __) => const MarketWatchScreen(),
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
                BoxShadow(color: _C.gold.withOpacity(0.50),
                    blurRadius: 22, offset: const Offset(0, 6),
                    spreadRadius: -2),
                BoxShadow(color: Colors.black.withOpacity(0.40),
                    blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.candlestick_chart_rounded,
                color: Color(0xFF060C1A), size: 24),
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _GlowOrb extends StatelessWidget {
  final double size, opacity;
  final Color color;
  const _GlowOrb({required this.size, required this.color, required this.opacity});

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
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width * 1.1, size.height * 0.5),
          radius: size.width * 0.7),
      math.pi * 0.6, math.pi * 0.6, false,
      Paint()
        ..color = const Color(0xFFD4A030).withOpacity(0.06)
        ..strokeWidth = 60
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.1), 80,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFD4A030).withOpacity(0.10),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(
            center: Offset(size.width * 0.9, size.height * 0.1), radius: 80)),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}