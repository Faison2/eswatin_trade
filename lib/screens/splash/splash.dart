import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../main.dart';
import '../auth/login/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _masterController;   // drives everything sequentially
  late AnimationController _tickerController;   // continuous scroll
  late AnimationController _pulseController;    // continuous glow
  late AnimationController _floatController;    // continuous card float
  late AnimationController _fadeController;     // exit fade

  // Derived animations from master
  late Animation<double> _chartProgress;
  late Animation<double> _candleProgress;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _lineWidth;
  late Animation<double> _textFade;
  late Animation<Offset>  _textSlide;
  late Animation<double> _statsFade;
  late Animation<double> _cardsFade;
  late Animation<double> _exitOpacity;

  // Continuous
  late Animation<double> _pulse;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();

    // One master timeline: 0 → 1 over 3.8 s
    _masterController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3800));

    // Charts start immediately, draw over first 60%
    _chartProgress = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.60, curve: Curves.easeOut),
    );
    _candleProgress = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.05, 0.65, curve: Curves.easeOut),
    );

    // Logo at 20–45%
    _logoOpacity = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.20, 0.38, curve: Curves.easeOut),
    );
    _logoScale = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.18, 0.44, curve: Curves.elasticOut),
    ).drive(Tween(begin: 0.4, end: 1.0));

    // Divider at 38–50%
    _lineWidth = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.38, 0.52, curve: Curves.easeInOut),
    );

    // Text at 44–58%
    _textFade = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.44, 0.60, curve: Curves.easeOut),
    );
    _textSlide = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.44, 0.60, curve: Curves.easeOutCubic),
    ).drive(Tween(begin: const Offset(0, 0.35), end: Offset.zero));

    // Stats at 52–66%
    _statsFade = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.52, 0.68, curve: Curves.easeOut),
    );

    // Cards at 58–74%
    _cardsFade = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.58, 0.76, curve: Curves.easeOut),
    );

    // ── Continuous animations ──────────────────────────────────────────
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
        .drive(Tween(begin: 0.55, end: 1.0));

    _floatController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);
    _float = CurvedAnimation(parent: _floatController, curve: Curves.easeInOut)
        .drive(Tween(begin: -5.0, end: 5.0));

    _tickerController = AnimationController(
        vsync: this, duration: const Duration(seconds: 14))
      ..repeat();

    // ── Exit ──────────────────────────────────────────────────────────
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _exitOpacity = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn)
        .drive(Tween(begin: 1.0, end: 0.0));

    _runSequence();
  }

  Future<void> _runSequence() async {
    _masterController.forward();
    // Hold at end of master, then exit
    await Future.delayed(const Duration(milliseconds: 4400));
    await _fadeController.forward();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginPage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _tickerController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _exitOpacity,
      builder: (_, child) => Opacity(opacity: _exitOpacity.value, child: child),
      child: Scaffold(
        backgroundColor: const Color(0xFF060E1C),
        body: Stack(
          children: [
            // ── 1. Deep gradient base ────────────────────────────────
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0B1A30),
                      Color(0xFF081424),
                      Color(0xFF050E1A),
                    ],
                  ),
                ),
              ),
            ),

            // ── 2. Fine dot-grid ─────────────────────────────────────
            Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),

            // ── 3. Background line chart (covers full screen) ─────────
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _chartProgress,
                builder: (_, __) => CustomPaint(
                  painter: _BgLineChartPainter(progress: _chartProgress.value),
                ),
              ),
            ),

            // ── 4. Top section: corner accents ───────────────────────
            Positioned(
              top: 0, left: 0,
              child: CustomPaint(
                size: Size(size.width * 0.5, 3),
                painter: _AccentLinePainter(fromLeft: true),
              ),
            ),
            Positioned(
              top: 0, right: 0,
              child: CustomPaint(
                size: Size(size.width * 0.5, 3),
                painter: _AccentLinePainter(fromLeft: false),
              ),
            ),

            // ── 5. Upper floating market cards ───────────────────────
            Positioned(
              top: size.height * 0.07,
              left: 16,
              child: AnimatedBuilder(
                animation: Listenable.merge([_floatController, _cardsFade]),
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, _float.value * 0.7),
                  child: Opacity(
                    opacity: _cardsFade.value,
                    child: const _FloatCard(
                      symbol: 'SWSC',
                      price: 'E 12.40',
                      change: '+2.4%',
                      isUp: true,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.11,
              right: 16,
              child: AnimatedBuilder(
                animation: Listenable.merge([_floatController, _cardsFade]),
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, -_float.value * 0.75),
                  child: Opacity(
                    opacity: _cardsFade.value,
                    child: const _FloatCard(
                      symbol: 'ESE INDEX',
                      price: '1,847.3',
                      change: '+1.2%',
                      isUp: true,
                    ),
                  ),
                ),
              ),
            ),

            // ── 6. Center content (logo + text + stats) ───────────────
            Positioned(
              top: size.height * 0.28,
              left: 0, right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glow orb
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, child) => Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            ESEColors.primary.withAlpha(((0.24 * _pulse.value) * 255).clamp(0,255).toInt()),
                            ESEColors.accent.withAlpha(((0.06 * _pulse.value) * 255).clamp(0,255).toInt()),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                      child: child,
                    ),
                    child: Center(
                      // Logo
                      child: AnimatedBuilder(
                        animation: _masterController,
                        builder: (_, __) => Transform.scale(
                          scale: _logoScale.value,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 175,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => _FallbackLogo(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Divider
                  AnimatedBuilder(
                    animation: _lineWidth,
                    builder: (_, __) => Container(
                      width: 210 * _lineWidth.value,
                      height: 1.4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          ESEColors.accent.withAlpha((0.05 * 255).toInt()),
                          ESEColors.accent,
                          ESEColors.primary,
                          ESEColors.primary.withAlpha((0.05 * 255).toInt()),
                        ]),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tagline
                  AnimatedBuilder(
                    animation: _masterController,
                    builder: (_, __) => SlideTransition(
                      position: _textSlide,
                      child: Opacity(
                        opacity: _textFade.value,
                        child: Column(
                          children: [
                            Text(
                              'ESWATINI STOCK EXCHANGE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontFamily: 'Georgia',
                                letterSpacing: 4.0,
                                color: ESEColors.cream.withAlpha((0.80 * 255).toInt()),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Investing in the Kingdom's Future",
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Georgia',
                                fontStyle: FontStyle.italic,
                                letterSpacing: 1.0,
                                color: ESEColors.gold.withAlpha((0.72 * 255).toInt()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Stats pill
                  AnimatedBuilder(
                    animation: _statsFade,
                    builder: (_, __) => Opacity(
                      opacity: _statsFade.value,
                      child: const _StatsPill(),
                    ),
                  ),
                ],
              ),
            ),

            // ── 7. Candlestick chart — fills the lower portion ────────
            Positioned(
              bottom: 36,
              left: 0, right: 0,
              height: size.height * 0.30,
              child: AnimatedBuilder(
                animation: _candleProgress,
                builder: (_, __) => CustomPaint(
                  painter: _CandlesPainter(progress: _candleProgress.value),
                ),
              ),
            ),

            // ── 8. Gradient fade at candlestick top edge ─────────────
            Positioned(
              bottom: 36 + size.height * 0.22,
              left: 0, right: 0,
              height: size.height * 0.08,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFF060E1C).withAlpha(0),
                      const Color(0xFF060E1C).withAlpha((0.85 * 255).toInt()),
                    ],
                  ),
                ),
              ),
            ),

            // ── 9. Ticker ────────────────────────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _TickerBar(controller: _tickerController),
            ),

            // ── 10. Version ──────────────────────────────────────────
            Positioned(
              bottom: 42, left: 0, right: 0,
              child: AnimatedBuilder(
                animation: _statsFade,
                builder: (_, __) => Opacity(
                  opacity: _statsFade.value * 0.45,
                  child: Text(
                    'v1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8.5,
                      letterSpacing: 2.5,
                      color: ESEColors.cream.withAlpha((0.30 * 255).toInt()),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAINTERS
// ─────────────────────────────────────────────────────────────────────────────

/// Subtle dot grid background
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ESEColors.primary.withAlpha((0.055 * 255).toInt())
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.2;
    const step = 30.0;
    for (double x = step; x < size.width; x += step) {
      for (double y = step; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

/// Top accent gradient lines
class _AccentLinePainter extends CustomPainter {
  final bool fromLeft;
  _AccentLinePainter({required this.fromLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: fromLeft
              ? [ESEColors.accent.withAlpha((0.8 * 255).toInt()), Colors.transparent]
              : [Colors.transparent, ESEColors.primary.withAlpha((0.8 * 255).toInt())],
        ).createShader(rect),
    );
  }
  @override
  bool shouldRepaint(_) => false;
}

/// Animated multi-layer line chart for background
class _BgLineChartPainter extends CustomPainter {
  final double progress;
  _BgLineChartPainter({required this.progress});

  // Three layers with different rhythms
  static const _layer1 = [
    0.72, 0.65, 0.70, 0.62, 0.55, 0.60, 0.52, 0.58, 0.48,
    0.44, 0.50, 0.43, 0.38, 0.44, 0.36, 0.30, 0.38, 0.32,
    0.26, 0.33, 0.25, 0.20, 0.28, 0.22, 0.17, 0.24, 0.16,
    0.22, 0.14, 0.20, 0.12, 0.18, 0.10, 0.16, 0.08,
  ];
  static const _layer2 = [
    0.82, 0.75, 0.80, 0.73, 0.68, 0.74, 0.66, 0.71, 0.62,
    0.58, 0.64, 0.57, 0.52, 0.58, 0.50, 0.46, 0.53, 0.47,
    0.42, 0.49, 0.41, 0.36, 0.43, 0.37, 0.32, 0.39, 0.31,
    0.37, 0.28, 0.35, 0.26, 0.32, 0.24, 0.30, 0.22,
  ];
  static const _layer3 = [
    0.60, 0.55, 0.62, 0.54, 0.48, 0.54, 0.46, 0.51, 0.42,
    0.38, 0.45, 0.38, 0.34, 0.40, 0.32, 0.28, 0.35, 0.28,
    0.22, 0.29, 0.21, 0.17, 0.25, 0.18, 0.14, 0.21, 0.13,
    0.20, 0.11, 0.17, 0.09, 0.16, 0.07, 0.13, 0.06,
  ];

  void _drawLayer(Canvas canvas, Size size, List<double> pts,
      Color strokeColor, Color fillColor, double strokeW) {
    final count      = pts.length;
    final drawCount  = (count * progress).round().clamp(2, count);
    final path       = Path();
    final fill       = Path();

    for (int i = 0; i < drawCount; i++) {
      final x = (i / (count - 1)) * size.width;
      final y = pts[i] * size.height;
      if (i == 0) {
        path.moveTo(x, y); fill.moveTo(x, y);
      } else {
        final px  = ((i-1)/(count-1)) * size.width;
        final py  = pts[i-1] * size.height;
        final cpx = (px + x) / 2;
        path.cubicTo(cpx, py, cpx, y, x, y);
        fill.cubicTo(cpx, py, cpx, y, x, y);
      }
    }
    final endX = ((drawCount-1)/(count-1)) * size.width;
    fill.lineTo(endX, size.height);
    fill.lineTo(0, size.height);
    fill.close();

    canvas.drawPath(fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [fillColor, fillColor.withAlpha(0)],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    canvas.drawPath(path,
        Paint()
          ..color = strokeColor
          ..strokeWidth = strokeW
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);

    // Glowing head dot
    canvas.drawCircle(
      Offset(endX, pts[drawCount-1] * size.height),
      strokeW * 3.5,
      Paint()..color = strokeColor.withAlpha((0.18 * 255).toInt()),
    );
    canvas.drawCircle(
      Offset(endX, pts[drawCount-1] * size.height),
      strokeW * 1.2,
      Paint()..color = strokeColor.withAlpha((0.9 * 255).toInt()),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    _drawLayer(canvas, size, _layer2,
        ESEColors.accent.withAlpha((0.14 * 255).toInt()),
        ESEColors.accent.withAlpha((0.04 * 255).toInt()), 1.0);
    _drawLayer(canvas, size, _layer3,
        ESEColors.lightBlue.withAlpha((0.18 * 255).toInt()),
        ESEColors.lightBlue.withAlpha((0.04 * 255).toInt()), 0.8);
    _drawLayer(canvas, size, _layer1,
        ESEColors.lightBlue.withAlpha((0.38 * 255).toInt()),
        ESEColors.primary.withAlpha((0.09 * 255).toInt()), 1.8);
  }

  @override
  bool shouldRepaint(_BgLineChartPainter old) => old.progress != progress;
}

/// Candlestick chart with volume bars + axis labels
class _CandlesPainter extends CustomPainter {
  final double progress;
  _CandlesPainter({required this.progress});

  // (open, high, low, close) — fraction of panel height (0=top, 1=bottom)
  static const _data = [
    (0.70, 0.40, 0.85, 0.52), (0.52, 0.28, 0.62, 0.35),
    (0.35, 0.55, 0.72, 0.65), (0.65, 0.38, 0.70, 0.42),
    (0.42, 0.22, 0.50, 0.28), (0.28, 0.45, 0.60, 0.55),
    (0.55, 0.32, 0.62, 0.38), (0.38, 0.58, 0.72, 0.66),
    (0.66, 0.42, 0.75, 0.48), (0.48, 0.25, 0.55, 0.30),
    (0.30, 0.48, 0.65, 0.58), (0.58, 0.35, 0.65, 0.40),
    (0.40, 0.20, 0.48, 0.25), (0.25, 0.42, 0.58, 0.52),
    (0.52, 0.28, 0.62, 0.34), (0.34, 0.18, 0.42, 0.22),
    (0.22, 0.38, 0.55, 0.48), (0.48, 0.26, 0.56, 0.32),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final h         = size.height;
    final w         = size.width;
    final chartH    = h * 0.76;   // top 76% is candlestick area
    final drawCount = (_data.length * progress).ceil().clamp(1, _data.length);
    final spacing   = w / (_data.length + 1);
    final bodyW     = spacing * 0.50;

    // ── Horizontal grid ───────────────────────────────────────────
    final gridP = Paint()
      ..color = ESEColors.primary.withAlpha((0.10 * 255).toInt())
      ..strokeWidth = 0.6;
    for (int i = 1; i <= 4; i++) {
      final y = chartH * i / 5;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridP);
    }
    // Volume separator
    canvas.drawLine(
      Offset(0, chartH + h * 0.04),
      Offset(w, chartH + h * 0.04),
      Paint()..color = ESEColors.primary.withAlpha((0.12 * 255).toInt())..strokeWidth = 0.5,
    );

    // ── Candles ───────────────────────────────────────────────────
    for (int i = 0; i < drawCount; i++) {
      final c      = _data[i];
      final x      = spacing * (i + 1);
      final isUp   = c.$4 <= c.$1;  // close ≤ open → green (price went up, y inverted)
      final teal   = const Color(0xFF26A69A);
      final red    = const Color(0xFFEF5350);
      final color  = isUp ? teal : red;

      final openY  = c.$1 * chartH;
      final closeY = c.$4 * chartH;
      final highY  = c.$2 * chartH;
      final lowY   = c.$3 * chartH;

      // Wick
      canvas.drawLine(
        Offset(x, highY), Offset(x, lowY),
        Paint()..color = color.withAlpha((0.65 * 255).toInt())..strokeWidth = 1.3,
      );

      // Body
      final top    = math.min(openY, closeY);
      final bottom = math.max(openY, closeY);
      final bh     = (bottom - top).clamp(2.5, 9999.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - bodyW / 2, top, bodyW, bh),
          const Radius.circular(2.5),
        ),
        Paint()..color = color.withAlpha((0.80 * 255).toInt()),
      );
      // Inner shine on bullish candles
      if (isUp && bh > 6) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x - bodyW / 2 + 1.5, top + 1.5, bodyW * 0.3, bh - 3),
            const Radius.circular(1),
          ),
          Paint()..color = Colors.white.withAlpha((0.10 * 255).toInt()),
        );
      }

      // Volume bar
      final maxVol = chartH * 0.14;
      final vol    = maxVol * (0.3 + (i % 5) * 0.14);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x - bodyW / 2,
            chartH + h * 0.06 + (maxVol - vol),
            bodyW,
            vol,
          ),
          const Radius.circular(1.5),
        ),
        Paint()..color = color.withAlpha((0.30 * 255).toInt()),
      );
    }
  }

  @override
  bool shouldRepaint(_CandlesPainter old) => old.progress != progress;
 }

 // ─────────────────────────────────────────────────────────────────────────────
 // WIDGETS
 // ─────────────────────────────────────────────────────────────────────────────

 class _FallbackLogo extends StatelessWidget {
   @override
   Widget build(BuildContext context) {
     return Row(
       mainAxisSize: MainAxisSize.min,
       children: [
         const Text('ESE',
             style: TextStyle(
               fontFamily: 'Georgia', fontSize: 58,
               fontWeight: FontWeight.bold,
               color: ESEColors.primary, letterSpacing: 3,
             )),
         const SizedBox(width: 12),
         CustomPaint(size: const Size(48, 56), painter: _HexPainter()),
       ],
     );
   }
 }

 class _HexPainter extends CustomPainter {
   @override
   void paint(Canvas canvas, Size size) {
     final cx = size.width / 2;
     final cy = size.height / 2;
     final r  = size.width * 0.48;
     final bp = Paint()
       ..color = ESEColors.primary..style = PaintingStyle.stroke
       ..strokeWidth = 3.0..strokeCap = StrokeCap.round;
     final op = Paint()
       ..color = ESEColors.accent..style = PaintingStyle.stroke
       ..strokeWidth = 3.0..strokeCap = StrokeCap.round;
     canvas.drawLine(Offset(cx - r * .55, cy - r * .7),
         Offset(cx - r * .55, cy + r * .7), bp);
     canvas.drawLine(Offset(cx - r * .10, cy - r * .85),
         Offset(cx - r * .10, cy + r * .85), op);
     canvas.drawPath(
       Path()
         ..moveTo(cx + r * .20, cy - r * .85)
         ..lineTo(cx + r * .75, cy)
         ..lineTo(cx + r * .20, cy + r * .85),
       bp..color = ESEColors.lightBlue,
     );
   }
   @override
   bool shouldRepaint(_) => false;
 }

 /// Glassmorphism floating card with sparkline
 class _FloatCard extends StatelessWidget {
   final String symbol;
   final String price;
   final String change;
   final bool   isUp;
   const _FloatCard({
     required this.symbol, required this.price,
     required this.change, required this.isUp,
   });

   @override
   Widget build(BuildContext context) {
     final color = isUp ? const Color(0xFF26A69A) : const Color(0xFFEF5350);
     return ClipRRect(
       borderRadius: BorderRadius.circular(12),
       child: Container(
         padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
         decoration: BoxDecoration(
           color: ESEColors.midNavy.withAlpha((0.75 * 255).toInt()),
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: color.withAlpha((0.32 * 255).toInt()), width: 1),
           boxShadow: [
             BoxShadow(
               color: color.withAlpha((0.12 * 255).toInt()),
               blurRadius: 16,
               offset: const Offset(0, 4),
             ),
             BoxShadow(
               color: Colors.black.withAlpha((0.40 * 255).toInt()),
               blurRadius: 10,
             ),
           ],
         ),
         child: Row(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             // Sparkline
             CustomPaint(
               size: const Size(34, 22),
               painter: _SparkPainter(isUp: isUp),
             ),
             const SizedBox(width: 9),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisSize: MainAxisSize.min,
               children: [
                 Text(symbol,
                     style: TextStyle(
                       fontSize: 8.5, letterSpacing: 1.3, fontWeight: FontWeight.w700,
                       color: ESEColors.cream.withAlpha((0.48 * 255).toInt()),
                     )),
                 const SizedBox(height: 2),
                 Text(price,
                     style: const TextStyle(
                       fontSize: 13, fontWeight: FontWeight.bold,
                       color: ESEColors.cream,
                     )),
               ],
             ),
             const SizedBox(width: 8),
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
               decoration: BoxDecoration(
                 color: color.withAlpha((0.14 * 255).toInt()),
                 borderRadius: BorderRadius.circular(5),
               ),
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                       color: color, size: 12),
                   Text(change,
                       style: TextStyle(
                           fontSize: 9.5, fontWeight: FontWeight.bold, color: color)),
                 ],
               ),
             ),
           ],
         ),
       ),
     );
   }
 }

 class _SparkPainter extends CustomPainter {
   final bool isUp;
   _SparkPainter({required this.isUp});
   static const _u = [0.90, 0.72, 0.80, 0.58, 0.68, 0.44, 0.34, 0.18];
   static const _d = [0.18, 0.34, 0.24, 0.46, 0.38, 0.60, 0.52, 0.78];

   @override
   void paint(Canvas canvas, Size size) {
     final data  = isUp ? _u : _d;
     final color = isUp ? const Color(0xFF26A69A) : const Color(0xFFEF5350);
     final path  = Path();
     final fill  = Path();
     for (int i = 0; i < data.length; i++) {
       final x = (i / (data.length - 1)) * size.width;
       final y = data[i] * size.height;
       if (i == 0) {
         path.moveTo(x, y);
         fill.moveTo(x, y);
       } else {
         path.lineTo(x, y);
         fill.lineTo(x, y);
       }
     }
     fill.lineTo(size.width, size.height);
     fill.lineTo(0, size.height);
     fill.close();

     canvas.drawPath(fill,
         Paint()
           ..shader = LinearGradient(
             begin: Alignment.topCenter, end: Alignment.bottomCenter,
             colors: [color.withAlpha((0.22 * 255).toInt()), color.withAlpha(0)],
           ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

     canvas.drawPath(path,
         Paint()
           ..color = color.withAlpha((0.85 * 255).toInt())
           ..strokeWidth = 1.6
           ..style = PaintingStyle.stroke
           ..strokeCap = StrokeCap.round);
   }
   @override
   bool shouldRepaint(_) => false;
}

/// Frosted stats pill
class _StatsPill extends StatelessWidget {
  const _StatsPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: ESEColors.midNavy.withAlpha((0.55 * 255).toInt()),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: ESEColors.primary.withAlpha((0.22 * 255).toInt()), width: 1),
        boxShadow: [
          BoxShadow(
            color: ESEColors.primary.withAlpha((0.08 * 255).toInt()),
            blurRadius: 20, spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Stat(label: 'LISTED',   value: '28',     icon: Icons.business_rounded),
          _VDivider(),
          _Stat(label: 'VOL',      value: 'E 2.1M', icon: Icons.bar_chart_rounded),
          _VDivider(),
          _Stat(label: 'MKT CAP', value: 'E 8.4B', icon: Icons.trending_up_rounded),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 30, color: ESEColors.primary.withAlpha((0.20 * 255).toInt()));
}

class _Stat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _Stat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: ESEColors.lightBlue.withAlpha((0.60 * 255).toInt()), size: 13),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold,
              color: ESEColors.cream, letterSpacing: 0.3,
            )),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
              fontSize: 8.5, letterSpacing: 1.6,
              color: ESEColors.cream.withAlpha((0.36 * 255).toInt()),
            )),
      ],
    );
  }
}

// ─── Ticker bar ───────────────────────────────────────────────────────────────
class _TickerBar extends StatelessWidget {
  final AnimationController controller;
  const _TickerBar({required this.controller});

  static const _t = [
    ('SWSC',        '+2.4%', true),
    ('FNB',         '+0.8%', true),
    ('NEDBANK',     '-1.2%', false),
    ('SWAZIBANK',   '+3.1%', true),
    ('STANDARD',    '+0.3%', true),
    ('SAPPI',       '-0.6%', false),
    ('SOFALA',      '+1.7%', true),
    ('ESWATINI RE', '+4.2%', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628).withAlpha((0.97 * 255).toInt()),
        border: Border(
            top: BorderSide(
                color: ESEColors.primary.withAlpha((0.28 * 255).toInt()), width: 1)),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final sw    = MediaQuery.of(context).size.width;
          final total = sw * 2.8;
          final off   = controller.value * total;
          return ClipRect(
            child: Transform.translate(
              offset: Offset(-(off % total), 0),
              child: Row(children: [
                ..._t.map((e) => _TItem(e.$1, e.$2, e.$3)),
                ..._t.map((e) => _TItem(e.$1, e.$2, e.$3)),
                ..._t.map((e) => _TItem(e.$1, e.$2, e.$3)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _TItem extends StatelessWidget {
  final String sym, chg;
  final bool   up;
  const _TItem(this.sym, this.chg, this.up);

  @override
  Widget build(BuildContext context) {
    final color = up ? const Color(0xFF26A69A) : const Color(0xFFEF5350);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(sym,
              style: const TextStyle(
                color: ESEColors.cream, fontSize: 10.5,
                fontWeight: FontWeight.w600, letterSpacing: 1.0,
              )),
          const SizedBox(width: 5),
          Text(chg,
              style: TextStyle(
                  color: color, fontSize: 10.5, fontWeight: FontWeight.bold)),
          const SizedBox(width: 1),
          Icon(up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: color, size: 13),
          const SizedBox(width: 10),
          Container(width: 1, height: 11,
            color: ESEColors.primary.withAlpha((0.30 * 255).toInt())),
        ],
      ),
    );
  }
}
