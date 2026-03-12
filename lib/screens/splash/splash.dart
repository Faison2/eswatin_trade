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

  late AnimationController _masterCtrl;   // drives the entrance sequence
  late AnimationController _breatheCtrl;  // continuous ring breathe
  late AnimationController _tickerCtrl;   // continuous ticker scroll
  late AnimationController _floatCtrl;    // continuous card float
  late AnimationController _exitCtrl;     // fade-out before navigation

  // ── Entrance animations (from master) ──────────────────────────
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _ringReveal;
  late Animation<double> _lineFade;
  late Animation<double> _titleFade;
  late Animation<Offset>  _titleSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _statsFade;
  late Animation<double> _cardsFade;
  late Animation<double> _tickerFade;

  // ── Continuous ─────────────────────────────────────────────────
  late Animation<double> _breathe;
  late Animation<double> _float;

  // ── Exit ───────────────────────────────────────────────────────
  late Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();

    _masterCtrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 3200));

    _breatheCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 3000))..repeat(reverse: true);

    _tickerCtrl  = AnimationController(vsync: this,
        duration: const Duration(seconds: 16))..repeat();

    _floatCtrl   = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 3600))..repeat(reverse: true);

    _exitCtrl    = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600));

    // ── Entrance intervals ────────────────────────────────────────
    _logoFade   = _interval(0.00, 0.30, curve: Curves.easeOut);
    _logoScale  = Tween(begin: 0.70, end: 1.0).animate(
        _interval(0.00, 0.40, curve: Curves.easeOutBack));

    _ringReveal = _interval(0.20, 0.55, curve: Curves.easeOut);

    _lineFade   = _interval(0.35, 0.52, curve: Curves.easeOut);

    _titleFade  = _interval(0.42, 0.60, curve: Curves.easeOut);
    _titleSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(_interval(0.42, 0.60, curve: Curves.easeOutCubic));

    _taglineFade = _interval(0.52, 0.68, curve: Curves.easeOut);
    _statsFade   = _interval(0.60, 0.76, curve: Curves.easeOut);
    _cardsFade   = _interval(0.66, 0.82, curve: Curves.easeOut);
    _tickerFade  = _interval(0.74, 0.90, curve: Curves.easeOut);

    // ── Continuous ────────────────────────────────────────────────
    _breathe = Tween(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut));

    _float = Tween(begin: -6.0, end: 6.0).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    // ── Exit ──────────────────────────────────────────────────────
    _exitOpacity = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));

    _runSequence();
  }

  Animation<double> _interval(double start, double end,
      {Curve curve = Curves.linear}) =>
      CurvedAnimation(parent: _masterCtrl,
          curve: Interval(start, end, curve: curve));

  Future<void> _runSequence() async {
    _masterCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 4200));
    await _exitCtrl.forward();
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
    _masterCtrl.dispose();
    _breatheCtrl.dispose();
    _tickerCtrl.dispose();
    _floatCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _exitOpacity,
      builder: (_, child) =>
          Opacity(opacity: _exitOpacity.value, child: child),
      child: Scaffold(
        backgroundColor: const Color(0xFF060C1A),
        body: Stack(
          children: [

            // ── 1. Rich background ─────────────────────────────────
            Positioned.fill(
              child: CustomPaint(painter: _BackgroundPainter()),
            ),

            // ── 2. Breathing ring system (behind logo) ─────────────
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([_breatheCtrl, _ringReveal]),
                builder: (_, __) => CustomPaint(
                  painter: _RingSystemPainter(
                    breathe: _breathe.value,
                    reveal: _ringReveal.value,
                    center: Offset(size.width / 2, size.height * 0.415),
                  ),
                ),
              ),
            ),

            // ── 3. Floating market cards ───────────────────────────
            AnimatedBuilder(
              animation: Listenable.merge([_floatCtrl, _cardsFade]),
              builder: (_, __) => Stack(children: [
                Positioned(
                  top: size.height * 0.10,
                  left: 20,
                  child: Opacity(
                    opacity: _cardsFade.value,
                    child: Transform.translate(
                      offset: Offset(0, _float.value * 0.65),
                      child: const _MarketCard(
                        symbol: 'SWSC',
                        price: 'E 12.40',
                        change: '+2.4%',
                        isUp: true,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: size.height * 0.13,
                  right: 20,
                  child: Opacity(
                    opacity: _cardsFade.value,
                    child: Transform.translate(
                      offset: Offset(0, -_float.value * 0.7),
                      child: const _MarketCard(
                        symbol: 'ESE INDEX',
                        price: '1,847.3',
                        change: '+1.2%',
                        isUp: true,
                      ),
                    ),
                  ),
                ),
              ]),
            ),

            // ── 4. Center: logo + branding ─────────────────────────
            Positioned(
              top: 0, left: 0, right: 0,
              bottom: 36,  // above ticker
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // Logo
                  AnimatedBuilder(
                    animation: _masterCtrl,
                    builder: (_, __) => FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: _LogoWithGlow(breathe: _breathe),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Shimmer divider line
                  AnimatedBuilder(
                    animation: Listenable.merge([_masterCtrl, _breatheCtrl]),
                    builder: (_, __) => FadeTransition(
                      opacity: _lineFade,
                      child: _ShimmerLine(breathe: _breathe.value),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Exchange title
                  AnimatedBuilder(
                    animation: _masterCtrl,
                    builder: (_, __) => FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              const LinearGradient(
                                colors: [
                                  Color(0xFFF5D98B),
                                  Color(0xFFFFFFFF),
                                  Color(0xFFD4A030),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                          child: const Text(
                            'ESWATINI STOCK EXCHANGE',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 3.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tagline
                  AnimatedBuilder(
                    animation: _masterCtrl,
                    builder: (_, __) => FadeTransition(
                      opacity: _taglineFade,
                      child: Text(
                        "Investing in the Kingdom's Future",
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.8,
                          color: const Color(0xFFD4A030).withOpacity(0.65),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Stats pill
                  AnimatedBuilder(
                    animation: _statsFade,
                    builder: (_, __) => FadeTransition(
                      opacity: _statsFade,
                      child: const _StatsPill(),
                    ),
                  ),
                ],
              ),
            ),

            // ── 5. Ticker bar at bottom ────────────────────────────
            AnimatedBuilder(
              animation: _tickerFade,
              builder: (_, child) => Positioned(
                bottom: 0, left: 0, right: 0,
                child: Opacity(
                  opacity: _tickerFade.value,
                  child: child,
                ),
              ),
              child: _TickerBar(controller: _tickerCtrl),
            ),

            // ── 6. Version label ───────────────────────────────────
            AnimatedBuilder(
              animation: _statsFade,
              builder: (_, __) => Positioned(
                bottom: 44, left: 0, right: 0,
                child: Opacity(
                  opacity: _statsFade.value * 0.38,
                  child: const Text(
                    'v1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8.5,
                      letterSpacing: 3,
                      color: Colors.white,
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

// ─── Logo with animated glow halo ────────────────────────────────────────────
class _LogoWithGlow extends StatelessWidget {
  final Animation<double> breathe;
  const _LogoWithGlow({required this.breathe});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: breathe,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A030)
                  .withOpacity(0.40 * breathe.value),
              blurRadius: 55,
              spreadRadius: 8,
            ),
            BoxShadow(
              color: const Color(0xFF1565C0)
                  .withOpacity(0.22 * breathe.value),
              blurRadius: 38,
              spreadRadius: -4,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.asset(
          'assets/images/logo.png',
          width: 160,
          height: 160,
        //  fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackLogo(),
        ),
      ),
    );
  }
}

// ─── Fallback logo ────────────────────────────────────────────────────────────
class _FallbackLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1A33), Color(0xFF1A2F55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
            color: const Color(0xFFD4A030).withOpacity(0.5), width: 2),
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFFF5D98B), Color(0xFFD4A030)],
          ).createShader(b),
          child: const Text('ESE',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 5,
              )),
        ),
      ),
    );
  }
}

// ─── Shimmer divider line ─────────────────────────────────────────────────────
class _ShimmerLine extends StatelessWidget {
  final double breathe;
  const _ShimmerLine({required this.breathe});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 1.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFD4A030).withOpacity(breathe * 0.7),
            const Color(0xFFF5D98B).withOpacity(breathe),
            const Color(0xFFD4A030).withOpacity(breathe * 0.7),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ─── Stats pill ───────────────────────────────────────────────────────────────
class _StatsPill extends StatelessWidget {
  const _StatsPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 44),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1A33).withOpacity(0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD4A030).withOpacity(0.20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.12),
            blurRadius: 24,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Stat(label: 'LISTED',   value: '28',     icon: Icons.business_rounded),
          _Divider(),
          _Stat(label: 'VOL',      value: 'E 2.1M', icon: Icons.bar_chart_rounded),
          _Divider(),
          _Stat(label: 'MKT CAP', value: 'E 8.4B', icon: Icons.trending_up_rounded),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 28,
    color: const Color(0xFFD4A030).withOpacity(0.18),
  );
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
        Icon(icon, color: const Color(0xFFD4A030).withOpacity(0.55), size: 13),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            )),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
              fontSize: 8,
              letterSpacing: 1.8,
              color: Colors.white.withOpacity(0.35),
            )),
      ],
    );
  }
}

// ─── Market card ──────────────────────────────────────────────────────────────
class _MarketCard extends StatelessWidget {
  final String symbol, price, change;
  final bool isUp;
  const _MarketCard({
    required this.symbol,
    required this.price,
    required this.change,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    final color = isUp ? const Color(0xFF26A69A) : const Color(0xFFEF5350);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1A33).withOpacity(0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.28),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Symbol + sparkline row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                symbol,
                style: TextStyle(
                  fontSize: 8.5,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.45),
                ),
              ),
              const SizedBox(width: 10),
              CustomPaint(
                size: const Size(38, 18),
                painter: _SparkPainter(isUp: isUp),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUp
                          ? Icons.arrow_drop_up_rounded
                          : Icons.arrow_drop_down_rounded,
                      color: color,
                      size: 12,
                    ),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Sparkline painter ────────────────────────────────────────────────────────
class _SparkPainter extends CustomPainter {
  final bool isUp;
  _SparkPainter({required this.isUp});
  static const _up = [0.85, 0.68, 0.75, 0.52, 0.62, 0.38, 0.28, 0.14];
  static const _dn = [0.14, 0.30, 0.22, 0.44, 0.36, 0.58, 0.50, 0.76];

  @override
  void paint(Canvas canvas, Size size) {
    final data  = isUp ? _up : _dn;
    final color = isUp ? const Color(0xFF26A69A) : const Color(0xFFEF5350);
    final path  = Path();
    final fill  = Path();
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = data[i] * size.height;
      if (i == 0) { path.moveTo(x, y); fill.moveTo(x, y); }
      else { path.lineTo(x, y); fill.lineTo(x, y); }
    }
    fill
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.22), color.withOpacity(0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(0.85)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Ring system painter ──────────────────────────────────────────────────────
class _RingSystemPainter extends CustomPainter {
  final double breathe;
  final double reveal;
  final Offset center;
  _RingSystemPainter({
    required this.breathe,
    required this.reveal,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (reveal == 0) return;

    final rings = [
      (105.0, 0.18),  // innermost
      (148.0, 0.11),
      (196.0, 0.07),
      (250.0, 0.04),  // outermost
    ];

    for (int i = 0; i < rings.length; i++) {
      final r       = rings[i].$1;
      final opacity = rings[i].$2;
      final delay   = i * 0.18;
      final t       = ((reveal - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (t == 0) continue;

      // Dashed arc sweep
      final sweepAngle = 2 * math.pi * t;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -math.pi / 2,
        sweepAngle,
        false,
        Paint()
          ..color = const Color(0xFFD4A030)
              .withOpacity(opacity * breathe * t)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );

      // Small accent dots at start / end of arc
      if (t > 0.05) {
        canvas.drawCircle(
          Offset(center.dx,
              center.dy - r),
          1.8,
          Paint()
            ..color = const Color(0xFFD4A030).withOpacity(0.45 * t * breathe),
        );
      }
      if (t > 0.5) {
        final endAngle = -math.pi / 2 + sweepAngle;
        canvas.drawCircle(
          Offset(
            center.dx + r * math.cos(endAngle),
            center.dy + r * math.sin(endAngle),
          ),
          1.8,
          Paint()
            ..color =
            const Color(0xFFD4A030).withOpacity(0.55 * t * breathe),
        );
      }
    }

    // Subtle cross-hairs through center
    if (reveal > 0.5) {
      final crossOpacity = ((reveal - 0.5) / 0.5).clamp(0.0, 1.0) * 0.07;
      final crossPaint = Paint()
        ..color = const Color(0xFFD4A030).withOpacity(crossOpacity)
        ..strokeWidth = 0.6;
      canvas.drawLine(
        Offset(center.dx - 260, center.dy),
        Offset(center.dx + 260, center.dy),
        crossPaint,
      );
      canvas.drawLine(
        Offset(center.dx, center.dy - 260),
        Offset(center.dx, center.dy + 260),
        crossPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingSystemPainter old) =>
      old.breathe != breathe || old.reveal != reveal;
}

// ─── Background painter ───────────────────────────────────────────────────────
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Deep navy gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF060C1A),
            Color(0xFF0A1528),
            Color(0xFF060C1A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Top-right gold bloom
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.08),
      180,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFD4A030).withOpacity(0.10),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.88, size.height * 0.08),
          radius: 180,
        )),
    );

    // Bottom-left blue bloom
    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.88),
      200,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFF1565C0).withOpacity(0.12),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.12, size.height * 0.88),
          radius: 200,
        )),
    );

    // Fine dot grid — very subtle
    final dotPaint = Paint()
      ..color = const Color(0xFFD4A030).withOpacity(0.028)
      ..style = PaintingStyle.fill;
    const spacing = 32.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.9, dotPaint);
      }
    }

    // Two thin diagonal accent lines (top-left → bottom-right)
    final linePaint = Paint()
      ..color = const Color(0xFFD4A030).withOpacity(0.055)
      ..strokeWidth = 0.7;
    canvas.drawLine(
      Offset(0, size.height * 0.18),
      Offset(size.width * 0.35, 0),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, size.height),
      Offset(size.width, size.height * 0.72),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Ticker bar ───────────────────────────────────────────────────────────────
class _TickerBar extends StatelessWidget {
  final AnimationController controller;
  const _TickerBar({required this.controller});

  static const _t = [
    ('SWSC', '+2.4%', true),  ('FNB', '+0.8%', true),
    ('NEDBANK', '-1.2%', false), ('SWAZIBANK', '+3.1%', true),
    ('STANDARD', '+0.3%', true), ('SAPPI', '-0.6%', false),
    ('SOFALA', '+1.7%', true), ('ESE RE', '+4.2%', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF080F1E).withOpacity(0.97),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD4A030).withOpacity(0.22),
            width: 1,
          ),
        ),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final sw    = MediaQuery.of(context).size.width;
          final total = sw * 2.6;
          final off   = controller.value * total;
          return ClipRect(
            child: OverflowBox(
              maxWidth: double.infinity,
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: Offset(-(off % total), 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ..._t.map((e) => _TItem(e.$1, e.$2, e.$3)),
                    ..._t.map((e) => _TItem(e.$1, e.$2, e.$3)),
                    ..._t.map((e) => _TItem(e.$1, e.$2, e.$3)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TItem extends StatelessWidget {
  final String sym, chg;
  final bool up;
  const _TItem(this.sym, this.chg, this.up);

  @override
  Widget build(BuildContext context) {
    final color =
    up ? const Color(0xFF26A69A) : const Color(0xFFEF5350);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            sym,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 6),
          Text(chg,
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 2),
          Icon(
            up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: color,
            size: 13,
          ),
          const SizedBox(width: 10),
          Container(
            width: 1,
            height: 11,
            color: const Color(0xFFD4A030).withOpacity(0.22),
          ),
        ],
      ),
    );
  }
}