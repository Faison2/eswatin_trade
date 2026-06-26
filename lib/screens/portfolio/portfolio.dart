import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../settings /settings.dart';

class _Dark {
  static const bg        = Color(0xFF060C1A);
  static const surface   = Color(0xFF0D1728);
  static const card      = Color(0xFF111F35);
  static const border    = Color(0xFF1E2E45);
  static const gold      = Color(0xFFD4A030);
  static const goldLight = Color(0xFFF5D98B);
  static const teal      = Color(0xFF26A69A);
  static const red       = Color(0xFFEF5350);
  static const blue      = Color(0xFF1565C0);
  static const textPrim  = Color(0xFFEEF2FF);
  static const textSub   = Color(0xFF7A8BA8);
  static const chartBg   = Color(0xFF0B1628);
  static const chartGrid = Color(0xFF1E2E45);
}

class _Light {
  static const bg        = Color(0xFFF0F4FB);
  static const surface   = Color(0xFFFFFFFF);
  static const card      = Color(0xFFFFFFFF);
  static const border    = Color(0xFFDDE3EF);
  static const gold      = Color(0xFFC49020);
  static const goldLight = Color(0xFF8B6010);
  static const teal      = Color(0xFF1A8A80);
  static const red       = Color(0xFFD43F3C);
  static const blue      = Color(0xFF1565C0);
  static const textPrim  = Color(0xFF0D1728);
  static const textSub   = Color(0xFF64748B);
  static const chartBg   = Color(0xFFF0F6FF);
  static const chartGrid = Color(0xFFDDE3EF);
}

class PortfolioScreen extends StatefulWidget {
  final AppThemeNotifier themeNotifier;
  const PortfolioScreen({super.key, required this.themeNotifier});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _chartDraw;
  late Animation<double> _pulse;
  late Animation<double> _cardScale;

  final _portfolioSeries = _generatePortfolioSeries();

  bool get _isLight => widget.themeNotifier.isLight;
  Color get _bg        => _isLight ? _Light.bg        : _Dark.bg;
  Color get _surface   => _isLight ? _Light.surface   : _Dark.surface;
  Color get _card      => _isLight ? _Light.card      : _Dark.card;
  Color get _border    => _isLight ? _Light.border    : _Dark.border;
  Color get _gold      => _isLight ? _Light.gold      : _Dark.gold;
  Color get _goldL     => _isLight ? _Light.goldLight : _Dark.goldLight;
  Color get _teal      => _isLight ? _Light.teal      : _Dark.teal;
  Color get _red       => _isLight ? _Light.red       : _Dark.red;
  Color get _blue      => _isLight ? _Light.blue      : _Dark.blue;
  Color get _textPrim  => _isLight ? _Light.textPrim  : _Dark.textPrim;
  Color get _textSub   => _isLight ? _Light.textSub   : _Dark.textSub;
  Color get _chartBg   => _isLight ? _Light.chartBg   : _Dark.chartBg;
  Color get _chartGrid => _isLight ? _Light.chartGrid : _Dark.chartGrid;

  static List<Offset> _generatePortfolioSeries() {
    final rng = math.Random(42);
    const n = 60;
    double val = 0.3;
    final pts = <Offset>[];
    for (int i = 0; i < n; i++) {
      val += (rng.nextDouble() - 0.45) * 0.05;
      val = val.clamp(0.05, 0.95);
      pts.add(Offset(i / (n - 1), val));
    }
    return pts;
  }

  void _rebuild() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.themeNotifier.addListener(_rebuild);

    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);

    _fade = CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
    _slide = Tween(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic)));
    _chartDraw = CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic));
    _cardScale = Tween(begin: 0.94, end: 1.0).animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)));
    _pulse = Tween(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    widget.themeNotifier.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: _isLight ? Brightness.dark : Brightness.light,
    ));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: _bg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: Stack(children: [
          // Ambient orbs
          Positioned(top: -60, right: -100,
              child: _Orb(300, _gold, _isLight ? 0.06 : 0.07)),
          Positioned(bottom: 80, left: -100,
              child: _Orb(260, _blue, _isLight ? 0.04 : 0.05)),
          Positioned(top: 300, right: -60,
              child: _Orb(180, _teal, _isLight ? 0.04 : 0.05)),

          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Column(children: [
                    const SizedBox(height: 16),

                    // ── Portfolio Value Card ──────────────────────────
                    ScaleTransition(
                      scale: _cardScale,
                      child: _PortfolioCard(
                        pulse: _pulse,
                        isLight: _isLight,
                        gold: _gold,
                        goldLight: _goldL,
                        teal: _teal,
                        red: _red,
                        card: _card,
                        border: _border,
                        surface: _surface,
                        textPrim: _textPrim,
                        textSub: _textSub,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Hero Chart ────────────────────────────────────
                    _HeroChart(
                      series: _portfolioSeries,
                      drawProgress: _chartDraw,
                      isLight: _isLight,
                      gold: _gold,
                      teal: _teal,
                      red: _red,
                      card: _card,
                      border: _border,
                      chartBg: _chartBg,
                      chartGrid: _chartGrid,
                      textSub: _textSub,
                      textPrim: _textPrim,
                    ),

                    const SizedBox(height: 20),

                    // ── Mini Stats Row ────────────────────────────────
                    _MiniStatsRow(
                      isLight: _isLight,
                      card: _card,
                      border: _border,
                      teal: _teal,
                      red: _red,
                      gold: _gold,
                      textPrim: _textPrim,
                      textSub: _textSub,
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: _bg.withOpacity(0.80),
              border: Border(
                  bottom: BorderSide(color: _border.withOpacity(0.5), width: 1)),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border, width: 1),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: _textSub, size: 15),
                  ),
                ),
              ),
              title: Text('Portfolio',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrim)),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border, width: 1),
                    ),
                    child: Icon(Icons.tune_rounded, color: _textSub, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Portfolio Value Card ──────────────────────────────────────────────────────
class _PortfolioCard extends StatelessWidget {
  final Animation<double> pulse;
  final bool  isLight;
  final Color gold, goldLight, teal, red, card, border, surface, textPrim, textSub;

  const _PortfolioCard({
    required this.pulse,
    required this.isLight,
    required this.gold,
    required this.goldLight,
    required this.teal,
    required this.red,
    required this.card,
    required this.border,
    required this.surface,
    required this.textPrim,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLight
                ? [const Color(0xFF1A3A6B), const Color(0xFF0D1F3C)]
                : [const Color(0xFF0F2040), const Color(0xFF060C1A)],
          ),
          border: Border.all(color: gold.withOpacity(0.22), width: 1.2),
          boxShadow: [
            BoxShadow(
                color: gold.withOpacity(0.12),
                blurRadius: 40,
                offset: const Offset(0, 12)),
            BoxShadow(
                color: Colors.black.withOpacity(0.30),
                blurRadius: 24,
                offset: const Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Subtle inner shimmer
              Positioned(top: -40, right: -40,
                child: Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      gold.withOpacity(0.10),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
              Positioned(bottom: -30, left: 10,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      teal.withOpacity(0.08),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          AnimatedBuilder(
                            animation: pulse,
                            builder: (_, __) => Container(
                              width: 7, height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: teal,
                                boxShadow: [BoxShadow(
                                    color: teal.withOpacity(pulse.value * 0.6),
                                    blurRadius: 6 * pulse.value,
                                    spreadRadius: 1)],
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text('LIVE PORTFOLIO',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: teal,
                                  letterSpacing: 1.4)),
                        ]),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                                width: 1),
                          ),
                          child: Text('ZSE · VFEX',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.55),
                                  letterSpacing: 0.8)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Main value
                    Text('E 00.00',
                        style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.5,
                            height: 1)),

                    const SizedBox(height: 10),

                    // Gain pill
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: teal.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: teal.withOpacity(0.35), width: 1),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.arrow_upward_rounded,
                              color: teal, size: 13),
                          const SizedBox(width: 4),
                          Text('+E 3,842.15  (+3.2%)',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: teal)),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      Text('today',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.35))),
                    ]),

                    const SizedBox(height: 22),

                    // Divider
                    Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.08)),

                    const SizedBox(height: 18),

                    // Bottom quick stats
                    Row(
                      children: [
                        _CardStat(
                            label: 'Invested',
                            value: 'E 00,00',
                            color: Colors.white),
                        _VSeparator(),
                        _CardStat(
                            label: 'Total Return',
                            value: '+0%',
                            color: teal),
                        _VSeparator(),
                        _CardStat(
                            label: 'Positions',
                            value: '0',
                            color: Colors.white),
                        _VSeparator(),
                        _CardStat(
                            label: 'Dividends',
                            value: 'E 0',
                            color: gold),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _CardStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.3)),
      const SizedBox(height: 4),
      Text(label,
          style: TextStyle(
              fontSize: 9.5,
              color: Colors.white.withOpacity(0.38),
              letterSpacing: 0.2),
          textAlign: TextAlign.center),
    ]),
  );
}

class _VSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1, height: 30,
      color: Colors.white.withOpacity(0.09));
}

// ─── Hero Chart ────────────────────────────────────────────────────────────────
class _HeroChart extends StatelessWidget {
  final List<Offset> series;
  final Animation<double> drawProgress;
  final bool  isLight;
  final Color gold, teal, red, card, border, chartBg, chartGrid, textSub, textPrim;

  const _HeroChart({
    required this.series,
    required this.drawProgress,
    required this.isLight,
    required this.gold,
    required this.teal,
    required this.red,
    required this.card,
    required this.border,
    required this.chartBg,
    required this.chartGrid,
    required this.textSub,
    required this.textPrim,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: border, width: 1),
          boxShadow: [
            BoxShadow(
                color: isLight
                    ? Colors.black.withOpacity(0.07)
                    : teal.withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 10)),
            BoxShadow(
                color: Colors.black.withOpacity(isLight ? 0.04 : 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(children: [
          // Chart header inside card
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Performance',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textPrim)),
                  const SizedBox(height: 3),
                  Text('June 2025 – Present',
                      style: TextStyle(fontSize: 10, color: textSub)),
                ]),
                _TimeRangeChips(
                    gold: gold, textSub: textSub, border: border, card: card),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Chart canvas
          SizedBox(
            height: 240,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              child: AnimatedBuilder(
                animation: drawProgress,
                builder: (_, __) => CustomPaint(
                  painter: _HeroChartPainter(
                    series: series,
                    progress: drawProgress.value,
                    color: teal,
                    gold: gold,
                    chartBg: chartBg,
                    chartGrid: chartGrid,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),

          // Bottom axis labels
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final label in ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Now'])
                  Text(label,
                      style: TextStyle(
                          fontSize: 10,
                          color: label == 'Now'
                              ? gold
                              : textSub.withOpacity(0.6),
                          fontWeight: label == 'Now'
                              ? FontWeight.w700
                              : FontWeight.w400)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Time Range Chips ──────────────────────────────────────────────────────────
class _TimeRangeChips extends StatefulWidget {
  final Color gold, textSub, border, card;
  const _TimeRangeChips({
    required this.gold, required this.textSub,
    required this.border, required this.card,
  });

  @override
  State<_TimeRangeChips> createState() => _TimeRangeChipsState();
}

class _TimeRangeChipsState extends State<_TimeRangeChips> {
  int _selected = 2;
  final _labels = ['1D', '1W', '1M', '3M', '1Y', 'ALL'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: widget.border.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_labels.length, (i) {
          final active = i == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: active ? widget.card : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                boxShadow: active
                    ? [BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1))]
                    : [],
              ),
              child: Text(_labels[i],
                  style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? widget.gold : widget.textSub)),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Mini Stats Row ────────────────────────────────────────────────────────────
class _MiniStatsRow extends StatelessWidget {
  final bool  isLight;
  final Color card, border, teal, red, gold, textPrim, textSub;

  const _MiniStatsRow({
    required this.isLight, required this.card, required this.border,
    required this.teal, required this.red, required this.gold,
    required this.textPrim, required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        _MiniStatCard('Total Return', '+E0.00', '+0%', teal,
            card, border, textPrim, textSub, isLight),
        const SizedBox(width: 10),
        _MiniStatCard('Day P&L', '+E 0.00', '+0.00%', teal,
            card, border, textPrim, textSub, isLight),
        const SizedBox(width: 10),
        _MiniStatCard('Dividends', 'E 0.00', 'YTD', gold,
            card, border, textPrim, textSub, isLight),
      ]),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label, value, tag;
  final Color color, card, border, textPrim, textSub;
  final bool isLight;

  const _MiniStatCard(this.label, this.value, this.tag, this.color,
      this.card, this.border, this.textPrim, this.textSub, this.isLight);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 1),
          boxShadow: isLight
              ? [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 9.5,
                    color: textSub,
                    letterSpacing: 0.2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.4),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.25), width: 1),
              ),
              child: Text(tag,
                  style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero Chart Painter ────────────────────────────────────────────────────────
class _HeroChartPainter extends CustomPainter {
  final List<Offset> series;
  final double progress;
  final Color color, gold, chartBg, chartGrid;

  const _HeroChartPainter({
    required this.series,
    required this.progress,
    required this.color,
    required this.gold,
    required this.chartBg,
    required this.chartGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (series.length < 2) return;

    canvas.drawRect(Offset.zero & size, Paint()..color = chartBg);

    // Horizontal grid lines with Y-axis labels
    final gridP = Paint()
      ..color = chartGrid.withOpacity(0.5)
      ..strokeWidth = 0.7;
    for (int i = 1; i <= 4; i++) {
      final y = (i / 5) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridP);
    }

    const topPad = 0.08;
    const bottomPad = 0.06;
    final chartH = size.height * (1 - topPad - bottomPad);
    final chartTop = size.height * topPad;

    final pts = <Offset>[
      for (int i = 0; i < series.length; i++)
        Offset(
          series[i].dx * size.width,
          chartTop + (1 - series[i].dy) * chartH,
        ),
    ];

    final visibleCount =
    (pts.length * progress).clamp(2, pts.length.toDouble()).toInt();
    final visible = pts.sublist(0, visibleCount);

    // Smooth bezier path
    final path = Path()..moveTo(visible.first.dx, visible.first.dy);
    for (int i = 0; i < visible.length - 1; i++) {
      final cp1 = Offset(
          (visible[i].dx + visible[i + 1].dx) / 2, visible[i].dy);
      final cp2 = Offset(
          (visible[i].dx + visible[i + 1].dx) / 2, visible[i + 1].dy);
      path.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, visible[i + 1].dx, visible[i + 1].dy);
    }

    // Gradient fill under curve
    final fillPath = Path.from(path)
      ..lineTo(visible.last.dx, size.height)
      ..lineTo(visible.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.28),
            color.withOpacity(0.08),
            color.withOpacity(0.0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Outer glow on line
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(0.18)
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Main line
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // End dot — gold accent
    final last = visible.last;
    canvas.drawCircle(last, 9, Paint()..color = color.withOpacity(0.15));
    canvas.drawCircle(last, 5.5, Paint()..color = color);
    canvas.drawCircle(last, 2.5, Paint()..color = Colors.white);

    // Vertical dashed line at current position
    final dashH = 6.0;
    final gap   = 4.0;
    double dy = chartTop;
    final dashP = Paint()
      ..color = color.withOpacity(0.30)
      ..strokeWidth = 1;
    while (dy < last.dy - dashH) {
      canvas.drawLine(Offset(last.dx, dy), Offset(last.dx, dy + dashH), dashP);
      dy += dashH + gap;
    }

    // Price label at end dot
    final tp = TextPainter(
      text: TextSpan(
        text: 'E 124.8K',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final labelX = (last.dx + 10).clamp(0.0, size.width - tp.width - 4);
    final labelY = (last.dy - 14).clamp(chartTop + 2, size.height - 18);

    // Label bg pill
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(labelX - 6, labelY - 3, tp.width + 12, tp.height + 6),
      const Radius.circular(6),
    );
    canvas.drawRRect(bgRect, Paint()..color = color.withOpacity(0.85));
    tp.paint(canvas, Offset(labelX, labelY));
  }

  @override
  bool shouldRepaint(_HeroChartPainter o) =>
      o.progress != progress ||
          o.color != color ||
          o.chartBg != chartBg ||
          o.chartGrid != chartGrid;
}

// ─── Glow Orb ──────────────────────────────────────────────────────────────────
class _Orb extends StatelessWidget {
  final double size, opacity;
  final Color  color;
  const _Orb(this.size, this.color, this.opacity);

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
          colors: [color.withOpacity(opacity), Colors.transparent]),
    ),
  );
}