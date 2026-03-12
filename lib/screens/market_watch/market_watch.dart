import 'package:flutter/material.dart';

// ─── ESE Color Palette (shared) ───────────────────────────────────────────────
class _C {
  static const surface   = Color(0xFF0D1728);
  static const card      = Color(0xFF111F35);
  static const border    = Color(0xFF1E2E45);
  static const gold      = Color(0xFFD4A030);
  static const teal      = Color(0xFF26A69A);
  static const red       = Color(0xFFEF5350);
  static const textPrim  = Color(0xFFEEF2FF);
  static const textSub   = Color(0xFF7A8BA8);
  static const textMuted = Color(0xFF3D5470);
}

class MarketWatch extends StatelessWidget {
  const MarketWatch({super.key});

  static const _stocks = [
    ('DELTA',   'E0.82', 'E0.81', 'E0.83', '+2.5%', true),
    ('ECONET',  'E1.45', 'E1.44', 'E1.46', '-1.4%', false),
    ('CBZH',    'E0.34', 'E0.33', 'E0.35', '+0.9%', true),
    ('HIPPO',   'E2.10', 'E2.08', 'E2.12', '+3.9%', true),
    ('NMBZ',    'E0.51', 'E0.50', 'E0.52', '-0.6%', false),
    ('SIMBISA', 'E0.57', 'E0.56', 'E0.58', '0.0%',  false),
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

          // Table
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: _C.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.border, width: 1),
              ),
              child: Column(
                children: [
                  // Header row
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _C.surface,
                      border: Border(
                        bottom: BorderSide(color: _C.border, width: 1),
                      ),
                    ),
                    child: Row(
                      children: const [
                        _TH('TICKER', flex: 3),
                        _TH('LAST',   flex: 3),
                        _TH('BID',    flex: 2),
                        _TH('ASK',    flex: 2),
                        _TH('CHANGE', flex: 3),
                        _TH('TREND',  flex: 2),
                      ],
                    ),
                  ),
                  // Data rows
                  ..._stocks.asMap().entries.map((e) => _MarketRow(
                    ticker: e.value.$1,
                    last:   e.value.$2,
                    bid:    e.value.$3,
                    ask:    e.value.$4,
                    change: e.value.$5,
                    isUp:   e.value.$6,
                    isLast: e.key == _stocks.length - 1,
                  )),
                ],
              ),
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
        style: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          color: _C.textMuted,
          letterSpacing: 1.2,
        )),
  );
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: _C.border, width: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(ticker,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrim,
                )),
          ),
          Expanded(
            flex: 3,
            child: Text(last,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrim,
                )),
          ),
          Expanded(
            flex: 2,
            child: Text(bid,
                style: TextStyle(fontSize: 10, color: _C.textSub)),
          ),
          Expanded(
            flex: 2,
            child: Text(ask,
                style: TextStyle(fontSize: 10, color: _C.textSub)),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: color, size: 12,
                  ),
                  Text(change,
                      style: TextStyle(
                        fontSize: 9,
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
              painter: _SparkPainter(isUp: isUp),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final bool isUp;
  _SparkPainter({required this.isUp});
  static const _up = [0.8, 0.6, 0.7, 0.45, 0.3, 0.15];
  static const _dn = [0.2, 0.4, 0.3, 0.55, 0.65, 0.82];

  @override
  void paint(Canvas canvas, Size size) {
    final data  = isUp ? _up : _dn;
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