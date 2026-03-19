import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─── ESE Color Palette ────────────────────────────────────────────────────────
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
  final double changePct;
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

  // ── Build a _Stock from the API JSON map ────────────────────────────────
  factory _Stock.fromJson(Map<String, dynamic> json) {
    final double lastPrice    = (json['lastPrice']    as num? ?? 0).toDouble();
    final double openingPrice = (json['openingPrice'] as num? ?? 0).toDouble();
    final double closingPrice = (json['closingPrice'] as num? ?? 0).toDouble();
    final double highestPrice = (json['highestPrice'] as num? ?? lastPrice).toDouble();
    final double lowestPrice  = (json['lowestPrice']  as num? ?? lastPrice).toDouble();
    final double bidPrice     = (json['bid']          as num? ?? 0).toDouble();
    final double offerPrice   = (json['offer']        as num? ?? 0).toDouble();
    final double changePct    = (json['changePercent']as num? ?? 0).toDouble();
    final double changeVal    = (json['changeValue']  as num? ?? 0).toDouble();
    final String trend        = (json['trend']        as String? ?? 'FLAT').toUpperCase();

    // Derive ticker: last 6 chars of company code, or abbreviate fullname
    final String companyCode = json['company'] as String? ?? '';
    final String fullname    = json['fullname'] as String? ?? companyCode;
    final String ticker      = _deriveTicker(companyCode, fullname);

    // Format prices
    String fmt(double v) =>
        v == 0 ? '—' : 'E ${v.toStringAsFixed(2)}';

    // Change label
    String changeLabel;
    if (changePct == 0 && changeVal == 0) {
      changeLabel = '0.0%';
    } else if (changePct != 0) {
      changeLabel =
      '${changePct > 0 ? '+' : ''}${changePct.toStringAsFixed(1)}%';
    } else {
      changeLabel =
      '${changeVal > 0 ? '+' : ''}E ${changeVal.toStringAsFixed(2)}';
    }

    // Override with trend string when both numbers are 0
    if (changePct == 0 && changeVal == 0 && trend == 'UP') {
      changeLabel = '+0.0%';
    } else if (changePct == 0 && changeVal == 0 && trend == 'DOWN') {
      changeLabel = '-0.0%';
    }

    // Effective change percent for colour logic
    double effectivePct = changePct;
    if (effectivePct == 0) {
      if (trend == 'UP')   effectivePct = 0.01;
      if (trend == 'DOWN') effectivePct = -0.01;
    }

    // ── Generate sparkline from available price points ───────────────────
    // We have: openingPrice, closingPrice, highestPrice, lowestPrice, lastPrice
    // Build a plausible 11-point normalised curve
    final history = _buildSparkline(
      open:    openingPrice,
      close:   closingPrice,
      high:    highestPrice,
      low:     lowestPrice,
      last:    lastPrice,
      trend:   trend,
    );

    return _Stock(
      ticker:    ticker,
      name:      fullname,
      last:      fmt(lastPrice),
      bid:       bidPrice  == 0 ? '—' : fmt(bidPrice),
      ask:       offerPrice == 0 ? '—' : fmt(offerPrice),
      change:    changeLabel,
      changePct: effectivePct,
      history:   history,
    );
  }

  // ── Derive a short ticker from company code or name ──────────────────────
  static String _deriveTicker(String code, String fullname) {
    // ESE company codes often end in meaningful letters after the number part
    // e.g. "SZE000331023" → try last alpha chars, else abbreviate name
    final letters = code.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (letters.length >= 2 && letters.length <= 6) {
      return letters.toUpperCase();
    }
    // Abbreviate fullname: take first letter of each word (max 5)
    final words = fullname.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words.first.substring(0, math.min(5, words.first.length))
          .toUpperCase();
    }
    return words
        .take(5)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
  }

  // ── Build a normalised 11-point sparkline ─────────────────────────────────
  static List<double> _buildSparkline({
    required double open,
    required double close,
    required double high,
    required double low,
    required double last,
    required String trend,
  }) {
    // All prices we know about
    final allPrices = [open, close, high, low, last]
        .where((p) => p > 0)
        .toList();
    if (allPrices.isEmpty) return List.filled(11, 0.5);

    final minP = allPrices.reduce(math.min);
    final maxP = allPrices.reduce(math.max);
    final range = (maxP - minP).abs();

    // Normalise a price to 0–1 (inverted: high value = low y on canvas
    // since y=0 is top). We want high price = top of chart so invert.
    double norm(double v) {
      if (range == 0) return 0.5;
      return 1.0 - ((v - minP) / range).clamp(0.0, 1.0);
    }

    // Build 11-point path: open → interpolated → high/low peak → close → last
    final rng = math.Random(open.toInt() + last.toInt());

    // Decide if upward or downward overall
    final goingUp = trend == 'UP' || last >= open;

    List<double> pts = [];

    // Point 0: open
    pts.add(norm(open));

    // Points 1-4: interpolation with noise
    for (int i = 1; i <= 4; i++) {
      final t = i / 10.0;
      final base = open + (last - open) * t;
      // Add some wiggle: up trend wiggles up, down trend wiggles down
      final wiggle = range * 0.15 * (rng.nextDouble() - (goingUp ? 0.3 : 0.7));
      pts.add(norm((base + wiggle).clamp(minP, maxP)));
    }

    // Point 5: high or low depending on trend (midpoint peak/trough)
    pts.add(goingUp ? norm(high) : norm(low));

    // Points 6-9: interpolation with noise back toward close
    for (int i = 6; i <= 9; i++) {
      final t = (i - 5) / 5.0;
      final base = (goingUp ? high : low) + (close - (goingUp ? high : low)) * t;
      final wiggle = range * 0.10 * (rng.nextDouble() - 0.5);
      pts.add(norm((base + wiggle).clamp(minP, maxP)));
    }

    // Point 10: last price
    pts.add(norm(last));

    return pts;
  }
}

// ─── Market Watch Widget ──────────────────────────────────────────────────────
class MarketWatch extends StatefulWidget {
  const MarketWatch({super.key});

  @override
  State<MarketWatch> createState() => _MarketWatchState();
}

class _MarketWatchState extends State<MarketWatch>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  List<Animation<double>> _cardAnims = [];

  List<_Stock> _stocks  = [];
  bool  _loading        = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fetchMarketData();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Fetch from API ──────────────────────────────────────────────────────
  Future<void> _fetchMarketData() async {
    setState(() {
      _loading      = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('session_token') ?? '';

      final response = await http
          .get(
        Uri.parse('https://app.trading-ese.com/eseapi/Home/MarketWatch'),
        headers: {
          'Content-Type':  'application/json',
          'Accept':        'application/json',
          'Authorization': 'Bearer $token',
          'sessionToken':  token,
        },
      )
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 &&
          (data['responseCode'] == 200 || data['securities'] != null)) {
        final rawList = data['securities'] as List<dynamic>? ?? [];
        final stocks  = rawList
            .map((s) => _Stock.fromJson(s as Map<String, dynamic>))
            .take(4)
            .toList();

        // Build staggered animations
        _ctrl.reset();
        _cardAnims = List.generate(stocks.length, (i) {
          final start = (i * 0.08).clamp(0.0, 1.0);
          final end   = (start + 0.55).clamp(0.0, 1.0);
          return CurvedAnimation(
            parent: _ctrl,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          );
        });

        setState(() {
          _stocks  = stocks;
          _loading = false;
        });

        _ctrl.forward();
      } else {
        setState(() {
          _errorMessage = data['responseMessage'] as String? ??
              'Failed to load market data.';
          _loading = false;
        });
      }
    } on http.ClientException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Network error: ${e.message}';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to load market data.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
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
                        fontSize: 15, fontWeight: FontWeight.w800,
                        color: _C.textPrim, letterSpacing: 0.2)),
              ]),
              Row(children: [
                // Refresh button
                GestureDetector(
                  onTap: _fetchMarketData,
                  child: Container(
                    width: 30, height: 30,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: _C.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _C.border),
                    ),
                    child: const Icon(Icons.refresh_rounded,
                        color: _C.textSub, size: 15),
                  ),
                ),
                _LiveBadge(),
              ]),
            ],
          ),

          const SizedBox(height: 14),

          // ── States ────────────────────────────────────────────────────
          if (_loading)
            _LoadingState()
          else if (_errorMessage != null)
            _ErrorState(
              message: _errorMessage!,
              onRetry: _fetchMarketData,
            )
          else
          // ── Cards ─────────────────────────────────────────────────
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stocks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                if (i >= _cardAnims.length) {
                  return _StockCard(stock: _stocks[i]);
                }
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

// ─── Loading State ────────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(4, (_) => _SkeletonCard()),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _shimmer = Tween(begin: -1.5, end: 2.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) => Container(
        height: 82,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              _C.card,
              _C.surface,
              _C.card,
            ],
            stops: [
              (_shimmer.value - 1).clamp(0.0, 1.0),
              _shimmer.value.clamp(0.0, 1.0),
              (_shimmer.value + 1).clamp(0.0, 1.0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: _C.border, width: 1),
        ),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.red.withOpacity(0.25), width: 1),
      ),
      child: Column(children: [
        Icon(Icons.wifi_off_rounded,
            color: _C.red.withOpacity(0.70), size: 32),
        const SizedBox(height: 10),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12.5, color: _C.textSub)),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
            decoration: BoxDecoration(
              color: _C.gold.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.gold.withOpacity(0.28), width: 1),
            ),
            child: const Text('Retry',
                style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700,
                    color: _C.gold)),
          ),
        ),
      ]),
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
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

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
              style: TextStyle(fontSize: 9.5,
                  fontWeight: FontWeight.w700, color: _C.teal)),
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
            style: const TextStyle(
                fontSize: 9.5, color: _C.textSub,
                fontWeight: FontWeight.w500)),
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
  late Animation<double>   _chartProgress;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _chartCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _chartProgress = CurvedAnimation(
        parent: _chartCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() { _chartCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = widget.stock;
    final c = s.color;

    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) => setState(() => _pressed = false),
      onTapCancel: ()  => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _C.card,
            border: Border.all(color: c.withOpacity(0.20), width: 1),
            boxShadow: [
              BoxShadow(color: c.withOpacity(0.10),
                  blurRadius: 18, offset: const Offset(0, 4)),
              BoxShadow(color: Colors.black.withOpacity(0.28),
                  blurRadius: 10, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              // ── Left colour accent bar ───────────────────────────────
              Container(
                width: 3,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: const BorderRadius.only(
                    topRight:    Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ── Ticker + name + bid/ask ──────────────────────────────
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.ticker,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: _C.textPrim,
                            letterSpacing: 0.4)),
                    const SizedBox(height: 2),
                    Text(s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 8.5,
                            color: _C.textSub.withOpacity(0.75))),
                    const SizedBox(height: 6),
                    Row(children: [
                      _MicroLabel(label: 'B', value: s.bid, color: _C.teal),
                      const SizedBox(width: 10),
                      _MicroLabel(label: 'A', value: s.ask, color: _C.red),
                    ]),
                  ],
                ),
              ),

              // ── Sparkline ────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 88,
                  height: 52,
                  margin: const EdgeInsets.symmetric(vertical: 22),
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.withOpacity(0.14), width: 1),
                  ),
                  child: AnimatedBuilder(
                    animation: _chartProgress,
                    builder: (_, __) => CustomPaint(
                      painter: _SparklinePainter(
                        data:     s.history,
                        color:    c,
                        progress: _chartProgress.value,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ── Price + change badge ─────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(s.last,
                      style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: c,
                          letterSpacing: -0.4)),
                  const SizedBox(height: 5),
                  _ChangeBadge(
                      change: s.change, color: c,
                      isFlat: s.isFlat, isUp: s.isUp),
                ],
              ),

              const SizedBox(width: 14),
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
  final Color  color;
  final bool   isFlat, isUp;
  const _ChangeBadge({
    required this.change, required this.color,
    required this.isFlat, required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon = isFlat
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
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                  color: color)),
        ],
      ),
    );
  }
}

// ─── Micro Bid/Ask Label ──────────────────────────────────────────────────────
class _MicroLabel extends StatelessWidget {
  final String label, value;
  final Color  color;
  const _MicroLabel(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label ',
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800,
                color: color.withOpacity(0.7))),
        Text(value,
            style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600,
                color: _C.textSub)),
      ],
    );
  }
}

// ─── Sparkline Painter ────────────────────────────────────────────────────────
class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color  color;
  final double progress;

  const _SparklinePainter({
    required this.data,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final totalPts     = data.length;
    final visibleCount =
    (totalPts * progress).clamp(1, totalPts.toDouble()).round();

    final pts = <Offset>[];
    for (int i = 0; i < visibleCount; i++) {
      // data is 0–1 where 1 = high price = top of chart, so invert y
      final x = (i / (totalPts - 1)) * size.width;
      final y = (1.0 - data[i]) * size.height;
      pts.add(Offset(x, y));
    }
    if (pts.length < 2) return;

    // ── Smooth bezier path ────────────────────────────────────────────
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final cpX = (pts[i].dx + pts[i + 1].dx) / 2;
      path.cubicTo(
          cpX, pts[i].dy,
          cpX, pts[i + 1].dy,
          pts[i + 1].dx, pts[i + 1].dy);
    }

    // ── Gradient fill under the line ──────────────────────────────────
    final fillPath = Path.from(path)
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            color.withOpacity(0.32),
            color.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // ── Line stroke ───────────────────────────────────────────────────
    canvas.drawPath(
      path,
      Paint()
        ..color       = color
        ..strokeWidth = 1.8
        ..style       = PaintingStyle.stroke
        ..strokeCap   = StrokeCap.round
        ..strokeJoin  = StrokeJoin.round,
    );

    // ── End dot: glow ring + filled dot + white centre ────────────────
    canvas.drawCircle(pts.last, 6.5,
        Paint()..color = color.withOpacity(0.15));
    canvas.drawCircle(pts.last, 3.2,
        Paint()..color = color);
    canvas.drawCircle(pts.last, 1.4,
        Paint()..color = Colors.white.withOpacity(0.90));
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.progress != progress || old.color != color;
}