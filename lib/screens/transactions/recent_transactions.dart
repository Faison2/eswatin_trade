import 'package:flutter/material.dart';

// ─── ESE Color Palette (shared) ───────────────────────────────────────────────
class _C {
  static const bg        = Color(0xFF060C1A);
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

class RecentOrders extends StatelessWidget {
  const RecentOrders({super.key});

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
                    width: 3, height: 16,
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
                        _TH('SYMBOL', flex: 3),
                        _TH('SIDE',   flex: 2),
                        _TH('QTY',    flex: 2),
                        _TH('PRICE',  flex: 2),
                        _TH('STATUS', flex: 3),
                      ],
                    ),
                  ),
                  // Data rows
                  ..._orders.asMap().entries.map((e) => _OrderRow(
                    symbol: e.value.$1,
                    side:   e.value.$2,
                    qty:    e.value.$3,
                    price:  e.value.$4,
                    status: e.value.$5,
                    isLast: e.key == _orders.length - 1,
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
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: sideColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(side,
                  style: TextStyle(
                    fontSize: 9,
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
                  fontSize: 11,
                  color: _C.textSub,
                )),
          ),
          Expanded(
            flex: 2,
            child: Text(price,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrim,
                )),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(status,
                  style: TextStyle(
                    fontSize: 9,
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