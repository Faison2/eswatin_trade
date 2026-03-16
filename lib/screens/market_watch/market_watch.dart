import 'package:flutter/material.dart';
import 'dart:math' as math;

// ─── ESE Color Palette (shared) ───────────────────────────────────────────────
class _C {
  static const bg        = Color(0xFF060C1A);
  static const surface   = Color(0xFF0D1728);
  static const card      = Color(0xFF111F35);
  static const border    = Color(0xFF1E2E45);
  static const gold      = Color(0xFFD4A030);
  static const blue      = Color(0xFF1565C0);
  static const teal      = Color(0xFF26A69A);
  static const red       = Color(0xFFEF5350);
  static const grey      = Color(0xFF5C6E85);
  static const textPrim  = Color(0xFFEEF2FF);
  static const textSub   = Color(0xFF7A8BA8);
  static const textMuted = Color(0xFF3D5470);
}

// ─── Stock Data Model ─────────────────────────────────────────────────────────
class _Stock {
  final String ticker;
  final String name;
  final String last;
  final String bid;
  final String ask;
  final String change;
  final double changePct;   // raw number for colour logic
  final List<double> history; // normalised 0–1 sparkline points

  const _Stock({
    required this.ticker,
    required this.name,
    required this.last,
    required this.bid,
    required this.ask,
    required this.change,
    required this.changePct,
    required this.history,
  });

  bool get isUp   => changePct > 0;
  bool get isFlat => changePct == 0;

  Color get color =>
      isFlat ? _C.grey : (isUp ? _C.teal : _C.red);
}

// ─── Data ─────────────────────────────────────────────────────────────────────
const _stocks = [
  _Stock(
    ticker: 'DELTA', name: 'Delta Beverages',
    last: 'E 0.82', bid: 'E 0.81', ask: 'E 0.83',
    change: '+2.5%', changePct: 2.5,
    history: [0.72, 0.68, 0.74, 0.65, 0.60, 0.55, 0.48, 0.40, 0.32, 0.22, 0.18],
  ),
  _Stock(
    ticker: 'ECONET', name: 'Econet Wireless',
    last: 'E 1.45', bid: 'E 1.44', ask: 'E 1.46',
    change: '-1.4%', changePct: -1.4,
    history: [0.22, 0.30, 0.25, 0.38, 0.45, 0.52, 0.58, 0.64, 0.70, 0.76, 0.80],
  ),
  _Stock(
    ticker: 'CBZH', name: 'CBZ Holdings',
    last: 'E 0.34', bid: 'E 0.33', ask: 'E 0.35',
    change: '+0.9%', changePct: 0.9,
    history: [0.65, 0.60, 0.66, 0.58, 0.55, 0.50, 0.46, 0.42, 0.38, 0.32, 0.28],
  ),
  _Stock(
    ticker: 'HIPPO', name: 'Hippo Valley',
    last: 'E 2.10', bid: 'E 2.08', ask: 'E 2.12',
    change: '+3.9%', changePct: 3.9,
    history: [0.78, 0.70, 0.75, 0.65, 0.58, 0.50, 0.42, 0.34, 0.25, 0.16, 0.10],
  ),
  _Stock(
    ticker: 'NMBZ', name: 'NMB Holdings',
    last: 'E 0.51', bid: 'E 0.50', ask: 'E 0.52',
    change: '-0.6%', changePct: -0.6,
    history: [0.28, 0.35, 0.30, 0.40, 0.46, 0.50, 0.56, 0.62, 0.66, 0.72, 0.78],
  ),
  _Stock(
    ticker: 'SIMBISA', name: 'Simbisa Brands',
    last: 'E 0.57', bid: 'E 0.56', ask: 'E 0.58',
    change: '0.0%', changePct: 0.0,
    history: [0.48, 0.52, 0.47, 0.51, 0.49, 0.50, 0.51, 0.48, 0.50, 0.49, 0.50],
  ),
];

// ─── Market Watch Widget ──────────────────────────────────────────────────────
class MarketWatch extends StatefulWidget {
  const MarketWatch({super.key});

  @override
  State<MarketWatch> createState() => _MarketWatchState();
}

class _MarketWatchState extends State<MarketWatch>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _cardAnims;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _cardAnims = List.generate(_stocks.length, (i) {
      final start = i * 0.10;
      final end   = start + 0.55;
      return CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start.clamp(0, 1), end.clamp(0, 1),
            curve: Curves.easeOutCubic),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ──
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
              _LiveBadge(),
            ],
          ),

          const SizedBox(height: 6),

          // ── Legend ──
          Row(
            children: const [
              _LegendDot(color: _C.teal,  label: 'Gaining'),
              SizedBox(width: 14),
              _LegendDot(color: _C.red,   label: 'Losing'),
              SizedBox(width: 14),
              _LegendDot(color: _C.grey, label: 'No Change'),
            ],
          ),

          const SizedBox(height: 14),

          // ── Cards Grid ──
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 0,
              mainAxisSpacing: 10,
              childAspectRatio: 3.8,
            ),
            itemCount: _stocks.length,
            itemBuilder: (_, i) {
              return FadeTransition(
                opacity: _cardAnims[i],
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.18),
                    end: Offset.zero,
                  ).animate(_cardAnims[i]),
                  child: _StockCard(stock: _stocks[i]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Live Badge ───────────────────────────────────────────────────────────────
class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _C.teal.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.teal.withOpacity(0.30), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.teal.withOpacity(0.4 + 0.6 * _pulse.value),
              ),
            ),
          ),
          const SizedBox(width: 5),
          const Text('Market Open',
              style: TextStyle(
                  fontSize: 9.5, fontWeight: FontWeight.w700, color: _C.teal)),
        ],
      ),
    );
  }
}

// ─── Legend Dot ───────────────────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7, height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                fontSize: 9.5, color: _C.textSub, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─── Stock Card ───────────────────────────────────────────────────────────────
class _StockCard extends StatefulWidget {
  final _Stock stock;
  const _StockCard({required this.stock});

  @override
  State<_StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<_StockCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _chartCtrl;
  late Animation<double> _chartProgress;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _chartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _chartProgress = CurvedAnimation(
        parent: _chartCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _chartCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.stock;
    final c = s.color;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp:   (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                _C.card,
                Color.lerp(_C.card, c, 0.06)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: c.withOpacity(0.22), width: 1),
            boxShadow: [
              BoxShadow(
                color: c.withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // ── Background area chart fill ──
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedBuilder(
                    animation: _chartProgress,
                    builder: (_, __) => CustomPaint(
                      painter: _AreaChartPainter(
                        data: s.history,
                        color: c,
                        progress: _chartProgress.value,
                        showFill: true,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Content ──
              Padding(
                padding: const EdgeInsets.fromLTRB(11, 10, 11, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top row: ticker + badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.ticker,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: _C.textPrim,
                                letterSpacing: 0.3)),
                        _ChangeBadge(change: s.change, color: c,
                            isFlat: s.isFlat, isUp: s.isUp),
                      ],
                    ),

                    // Company name
                    Text(s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 8.5,
                            color: _C.textSub.withOpacity(0.8))),

                    const Spacer(),

                    // Price + bid/ask
                    Text(s.last,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: c,
                            letterSpacing: -0.3)),

                    Row(
                      children: [
                        _MicroLabel(label: 'B', value: s.bid,
                            color: _C.teal),
                        const SizedBox(width: 8),
                        _MicroLabel(label: 'A', value: s.ask,
                            color: _C.red),
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

// ─── Change Badge ─────────────────────────────────────────────────────────────
class _ChangeBadge extends StatelessWidget {
  final String change;
  final Color color;
  final bool isFlat, isUp;
  const _ChangeBadge(
      {required this.change, required this.color,
        required this.isFlat, required this.isUp});

  @override
  Widget build(BuildContext context) {
    IconData icon = isFlat
        ? Icons.drag_handle_rounded
        : (isUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.28), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 1),
          Text(change,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: color)),
        ],
      ),
    );
  }
}

// ─── Micro Bid/Ask Label ──────────────────────────────────────────────────────
class _MicroLabel extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MicroLabel(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label ',
            style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: color.withOpacity(0.7))),
        Text(value,
            style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                color: _C.textSub)),
      ],
    );
  }
}

// ─── Area Chart Painter ───────────────────────────────────────────────────────
class _AreaChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double progress;
  final bool showFill;

  const _AreaChartPainter({
    required this.data,
    required this.color,
    required this.progress,
    required this.showFill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final pts = <Offset>[];
    final totalPts = data.length;

    // Only draw up to `progress` fraction of the line
    final visibleCount = (totalPts * progress).clamp(1, totalPts.toDouble()).round();

    for (int i = 0; i < visibleCount; i++) {
      final x = (i / (totalPts - 1)) * size.width;
      final y = data[i] * size.height;
      pts.add(Offset(x, y));
    }

    if (pts.length < 2) return;

    // ── Smooth bezier path ──
    final linePath = Path();
    linePath.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = pts[i];
      final p1 = pts[i + 1];
      final cpX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(cpX, p0.dy, cpX, p1.dy, p1.dx, p1.dy);
    }

    // ── Fill area ──
    if (showFill) {
      final fillPath = Path.from(linePath)
        ..lineTo(pts.last.dx, size.height)
        ..lineTo(0, size.height)
        ..close();

      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            colors: [
              color.withOpacity(0.18),
              color.withOpacity(0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
      );
    }

    // ── Line stroke ──
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color.withOpacity(0.65)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // ── End dot ──
    if (pts.isNotEmpty) {
      canvas.drawCircle(
        pts.last,
        3.0,
        Paint()..color = color.withOpacity(0.9),
      );
      canvas.drawCircle(
        pts.last,
        5.5,
        Paint()..color = color.withOpacity(0.20),
      );
    }
  }

  @override
  bool shouldRepaint(_AreaChartPainter old) =>
      old.progress != progress || old.color != color;
}