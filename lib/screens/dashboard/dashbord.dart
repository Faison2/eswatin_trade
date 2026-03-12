import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _C.bg,
      extendBody: true,
      body: Stack(
        children: [
          // Background glow orbs
          Positioned(top: -60, right: -40,
              child: _GlowOrb(size: 220, color: _C.gold, opacity: 0.07)),
          Positioned(top: 200, left: -60,
              child: _GlowOrb(size: 180, color: _C.blue, opacity: 0.08)),

          // Main scrollable content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: _TopBar(shimmer: _shimmer),
                  ),
                ),

                // ── Live ticker ──────────────────────────────────
                FadeTransition(
                  opacity: _headerFade,
                  child: _TickerStrip(controller: _tickerCtrl),
                ),

                // ── Scrollable body ──────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Portfolio hero card
                        FadeTransition(
                          opacity: _cardFade,
                          child: SlideTransition(
                            position: _cardSlide,
                            child: _PortfolioHeroCard(pulse: _pulse),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Buy / Sell quick actions
                        FadeTransition(
                          opacity: _cardFade,
                          child: const _QuickActions(),
                        ),

                        const SizedBox(height: 22),

                        // Stats row
                        FadeTransition(
                          opacity: _contentFade,
                          child: const _StatsRow(),
                        ),

                        const SizedBox(height: 22),

                        // Recent orders
                        FadeTransition(
                          opacity: _contentFade,
                          child: const _RecentOrders(),
                        ),

                        const SizedBox(height: 22),

                        // Market watch
                        FadeTransition(
                          opacity: _contentFade,
                          child: const _MarketWatch(),
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

      // ── Bottom navigation ─────────────────────────────────────
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),

      floatingActionButton: _FAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final Animation<double> shimmer;
  const _TopBar({required this.shimmer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
              ),
              border: Border.all(
                color: _C.gold.withOpacity(0.35),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Text('JD',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  )),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Good morning, John',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrim,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('👋', style: TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _C.teal,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'ESE Market Open · Wed 4 Mar 2026',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: _C.textSub,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notification bell
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _C.border, width: 1),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.notifications_outlined,
                    color: _C.textSub, size: 20),
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _C.gold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // New order button
          AnimatedBuilder(
            animation: shimmer,
            builder: (_, child) => Container(
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: const [Color(0xFF0A1628), Color(0xFF152240)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: _C.gold.withOpacity(0.30),
                  width: 1,
                ),
              ),
              child: child,
            ),
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded,
                  color: _C.gold, size: 15),
              label: const Text('New Order',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _C.gold,
                    letterSpacing: 0.3,
                  )),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ticker Strip ─────────────────────────────────────────────────────────────
class _TickerStrip extends StatelessWidget {
  final AnimationController controller;
  const _TickerStrip({required this.controller});

  static const _stocks = [
    ('DELTA', '+2.5%', true),  ('ECONET', '-1.4%', false),
    ('CBZH', '+0.9%', true),   ('HIPPO', '+3.9%', true),
    ('NMBZ', '-0.6%', false),  ('SIMBISA', '0.0%', false),
    ('SWSC', '+1.8%', true),   ('FNB', '+0.8%', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: _C.surface,
        border: Border(
          top:    BorderSide(color: _C.border, width: 0.8),
          bottom: BorderSide(color: _C.border, width: 0.8),
        ),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final sw    = MediaQuery.of(context).size.width;
          final total = sw * 3.0;
          final off   = controller.value * total;
          return ClipRect(
            child: OverflowBox(
              maxWidth: double.infinity,
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: Offset(-(off % total), 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (_) => _stocks)
                      .expand((e) => e)
                      .map((s) => Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(s.$1,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: _C.textPrim,
                              letterSpacing: 1.2,
                            )),
                        const SizedBox(width: 5),
                        Text(s.$2,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: s.$3 ? _C.teal : _C.red,
                            )),
                        const SizedBox(width: 5),
                        Icon(
                          s.$3
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: s.$3 ? _C.teal : _C.red,
                          size: 12,
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 1,
                          height: 10,
                          color: _C.border,
                        ),
                      ],
                    ),
                  ))
                      .toList(),
                ),
              ),
            ),
          );
        },
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
          BoxShadow(
            color: _C.gold.withOpacity(0.10),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.40),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative arc
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CustomPaint(painter: _CardBgPainter()),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label + change badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Portfolio Value',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: _C.textSub,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _C.teal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _C.teal.withOpacity(0.30),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_upward_rounded,
                              color: _C.teal, size: 11),
                          const SizedBox(width: 3),
                          const Text('+3.2% today',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _C.teal,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Big value
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [_C.textPrim, Color(0xFFCCD6F0)],
                  ).createShader(b),
                  child: const Text(
                    'E 4,230.00',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                      height: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.trending_up_rounded,
                        color: _C.teal, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '+E 820 this month',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: _C.teal.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Divider
                Container(
                  height: 1,
                  color: _C.border.withOpacity(0.6),
                ),

                const SizedBox(height: 16),

                // Sub-stats row
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
        : positive!
        ? _C.teal
        : _C.red;
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.2,
              )),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                fontSize: 9,
                color: _C.textSub,
                letterSpacing: 0.8,
              )),
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
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Buy',
              icon: Icons.trending_up_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              ),
              borderColor: _C.teal.withOpacity(0.45),
              textColor: _C.teal,
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              label: 'Sell',
              icon: Icons.trending_down_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF7F0000), Color(0xFFC62828)],
              ),
              borderColor: _C.red.withOpacity(0.45),
              textColor: _C.red,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final Color borderColor, textColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: textColor.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
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
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: const [
          _StatCard(
            label: 'Cash Balance',
            value: 'E 12,480',
            sub: '+E820 today',
            icon: Icons.account_balance_wallet_outlined,
            positive: true,
          ),
          _StatCard(
            label: 'Pending Settlements',
            value: 'E 1,560',
            sub: '3 pending',
            icon: Icons.hourglass_top_rounded,
            positive: null,
          ),
          _StatCard(
            label: 'Open Orders',
            value: '7',
            sub: '2 expiring today',
            icon: Icons.receipt_long_outlined,
            positive: null,
            warn: true,
          ),
          _StatCard(
            label: 'Matched Orders',
            value: '3',
            sub: 'This week',
            icon: Icons.check_circle_outline_rounded,
            positive: true,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final bool? positive;
  final bool warn;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    this.positive,
    this.warn = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = warn
        ? _C.gold
        : positive == null
        ? _C.blue
        : positive!
        ? _C.teal
        : _C.red;

    return Container(
      width: 145,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withOpacity(0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 14),
              ),
              const Spacer(),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: _C.textPrim,
                    letterSpacing: -0.5,
                  )),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                    fontSize: 9,
                    color: _C.textSub,
                    letterSpacing: 0.5,
                  )),
              const SizedBox(height: 3),
              Text(sub,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: accentColor.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Recent Orders ────────────────────────────────────────────────────────────
class _RecentOrders extends StatelessWidget {
  const _RecentOrders();

  static const _orders = [
    ('DELTA',   'BUY',  '500',   'E0.82',  'Matched'),
    ('ECONET',  'SELL', '200',   'E1.45',  'Pending'),
    ('CBZH',    'BUY',  '1,000', 'E0.34',  'Pending'),
    ('HIPPO',   'SELL', '150',   'E2.10',  'Matched'),
    ('SIMBISA', 'BUY',  '300',   'E0.57',  'Cancelled'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _C.gold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Recent Orders',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _C.textPrim,
                        letterSpacing: 0.2,
                      )),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text('View all',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: _C.gold,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(width: 3),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: _C.gold, size: 10),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Table header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border.all(color: _C.border, width: 1),
            ),
            child: Row(
              children: [
                _TH('SYMBOL', flex: 3),
                _TH('SIDE', flex: 2),
                _TH('QTY', flex: 2),
                _TH('PRICE', flex: 2),
                _TH('STATUS', flex: 3),
              ],
            ),
          ),

          // Table rows
          Container(
            decoration: BoxDecoration(
              color: _C.card,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              border: Border(
                left:   BorderSide(color: _C.border, width: 1),
                right:  BorderSide(color: _C.border, width: 1),
                bottom: BorderSide(color: _C.border, width: 1),
              ),
            ),
            child: Column(
              children: _orders.asMap().entries.map((e) {
                final i = e.key;
                final o = e.value;
                return _OrderRow(
                  symbol:   o.$1,
                  side:     o.$2,
                  qty:      o.$3,
                  price:    o.$4,
                  status:   o.$5,
                  isLast:   i == _orders.length - 1,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String text;
  final int flex;
  const _TH(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Text(text,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          color: _C.textMuted,
          letterSpacing: 1.2,
        )),
  );
}

class _OrderRow extends StatelessWidget {
  final String symbol, side, qty, price, status;
  final bool isLast;
  const _OrderRow({
    required this.symbol,
    required this.side,
    required this.qty,
    required this.price,
    required this.status,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isBuy     = side == 'BUY';
    final sideColor = isBuy ? _C.teal : _C.red;

    Color statusColor;
    Color statusBg;
    switch (status) {
      case 'Matched':
        statusColor = _C.teal;
        statusBg    = _C.teal.withOpacity(0.12);
        break;
      case 'Pending':
        statusColor = _C.gold;
        statusBg    = _C.gold.withOpacity(0.10);
        break;
      default:
        statusColor = _C.textMuted;
        statusBg    = _C.textMuted.withOpacity(0.08);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: _C.border, width: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(symbol,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrim,
                )),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: sideColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(side,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: sideColor,
                    letterSpacing: 0.8,
                  )),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(qty,
                style: TextStyle(
                  fontSize: 11.5,
                  color: _C.textSub,
                )),
          ),
          Expanded(
            flex: 2,
            child: Text(price,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrim,
                )),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(status,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Market Watch ─────────────────────────────────────────────────────────────
class _MarketWatch extends StatelessWidget {
  const _MarketWatch();

  static const _stocks = [
    ('DELTA',   'Delta Beverages',   'E0.82', 'E0.81', 'E0.83', '1,240,500', '+2.5%',  true),
    ('ECONET',  'Econet Wireless',   'E1.45', 'E1.44', 'E1.46', '845,200',   '-1.4%',  false),
    ('CBZH',    'CBZ Holdings',      'E0.34', 'E0.33', 'E0.35', '3,102,000', '+0.9%',  true),
    ('HIPPO',   'Hippo Valley',      'E2.10', 'E2.08', 'E2.12', '410,300',   '+3.9%',  true),
    ('NMBZ',    'NMB Holdings',      'E0.51', 'E0.50', 'E0.52', '920,700',   '-0.6%',  false),
    ('SIMBISA', 'Simbisa Brands',    'E0.57', 'E0.56', 'E0.58', '670,100',   '0.0%',   false),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3, height: 16,
                    decoration: BoxDecoration(
                      color: _C.teal,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Market Watch — ESE Live',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _C.textPrim,
                        letterSpacing: 0.2,
                      )),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.teal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _C.teal.withOpacity(0.30), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: _C.teal),
                    ),
                    const SizedBox(width: 5),
                    const Text('Market Open',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: _C.teal,
                        )),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Column headers
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border.all(color: _C.border, width: 1),
            ),
            child: Row(
              children: [
                _TH('TICKER',  flex: 3),
                _TH('LAST',    flex: 3),
                _TH('BID',     flex: 2),
                _TH('ASK',     flex: 2),
                _TH('CHANGE',  flex: 3),
                _TH('TREND',   flex: 2),
              ],
            ),
          ),

          // Rows
          Container(
            decoration: BoxDecoration(
              color: _C.card,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              border: Border(
                left:   BorderSide(color: _C.border, width: 1),
                right:  BorderSide(color: _C.border, width: 1),
                bottom: BorderSide(color: _C.border, width: 1),
              ),
            ),
            child: Column(
              children: _stocks.asMap().entries.map((e) {
                final i = e.key;
                final s = e.value;
                return _MarketRow(
                  ticker:  s.$1,
                  last:    s.$3,
                  bid:     s.$4,
                  ask:     s.$5,
                  change:  s.$7,
                  isUp:    s.$8,
                  isLast:  i == _stocks.length - 1,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketRow extends StatelessWidget {
  final String ticker, last, bid, ask, change;
  final bool isUp, isLast;
  const _MarketRow({
    required this.ticker,
    required this.last,
    required this.bid,
    required this.ask,
    required this.change,
    required this.isUp,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = isUp ? _C.teal : _C.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: _C.border, width: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticker,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrim,
                    )),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(last,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrim,
                )),
          ),
          Expanded(
            flex: 2,
            child: Text(bid,
                style: TextStyle(fontSize: 10.5, color: _C.textSub)),
          ),
          Expanded(
            flex: 2,
            child: Text(ask,
                style: TextStyle(fontSize: 10.5, color: _C.textSub)),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: color,
                    size: 12,
                  ),
                  Text(change,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: color,
                      )),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: CustomPaint(
              size: const Size(36, 18),
              painter: _MiniSparkPainter(isUp: isUp),
            ),
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
    return BottomAppBar(
      color: const Color(0xFF080F1E),
      elevation: 0,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: Container(
        height: 62,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: _C.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            _NavItem(icon: Icons.pie_chart_rounded,
                label: 'Portfolio', index: 0,
                current: currentIndex, onTap: onTap),
            _NavItem(icon: Icons.bar_chart_rounded,
                label: 'Markets', index: 1,
                current: currentIndex, onTap: onTap),

            // Space for FAB
            const Expanded(child: SizedBox()),

            _NavItem(icon: Icons.star_outline_rounded,
                label: 'Watchlist', index: 3,
                current: currentIndex, onTap: onTap),
            _NavItem(icon: Icons.person_outline_rounded,
                label: 'Profile', index: 4,
                current: currentIndex, onTap: onTap),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 28,
              decoration: BoxDecoration(
                color: selected
                    ? _C.gold.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? _C.gold : _C.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? _C.gold : _C.textMuted,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Floating Action Button ───────────────────────────────────────────────────
class _FAB extends StatefulWidget {
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
    _scale = Tween(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF0A1628), Color(0xFF152240)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: _C.gold.withOpacity(0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _C.gold.withOpacity(0.30),
                blurRadius: 20,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: _C.gold,
            size: 28,
          ),
        ),
      ),
    );
  }
}

// ─── Glow orb ─────────────────────────────────────────────────────────────────
class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _GlowOrb({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), Colors.transparent],
        ),
      ),
    );
  }
}

// ─── Card background painter ──────────────────────────────────────────────────
class _CardBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Subtle arc decoration
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 1.1, size.height * 0.5),
        radius: size.width * 0.7,
      ),
      math.pi * 0.6,
      math.pi * 0.6,
      false,
      Paint()
        ..color = const Color(0xFFD4A030).withOpacity(0.06)
        ..strokeWidth = 60
        ..style = PaintingStyle.stroke,
    );
    // Top-right gold shimmer
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.1),
      80,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFD4A030).withOpacity(0.10),
          Colors.transparent,
        ]).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.9, size.height * 0.1),
              radius: 80,
            )),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Mini spark painter for market table ─────────────────────────────────────
class _MiniSparkPainter extends CustomPainter {
  final bool isUp;
  _MiniSparkPainter({required this.isUp});

  static const _upData = [0.8, 0.6, 0.7, 0.45, 0.3, 0.15];
  static const _dnData = [0.2, 0.4, 0.3, 0.55, 0.65, 0.82];

  @override
  void paint(Canvas canvas, Size size) {
    final data  = isUp ? _upData : _dnData;
    final color = isUp ? _C.teal : _C.red;
    final path  = Path();
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = data[i] * size.height;
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path,
        Paint()
          ..color = color.withOpacity(0.75)
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_) => false;
}