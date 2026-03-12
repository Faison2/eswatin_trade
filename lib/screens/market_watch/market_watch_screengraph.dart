import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class _C {
  static const bg        = Color(0xFF060C1A);
  static const surface   = Color(0xFF0D1728);
  static const card      = Color(0xFF111F35);
  static const border    = Color(0xFF1E2E45);
  static const gold      = Color(0xFFD4A030);
  static const blue      = Color(0xFF1565C0);
  static const teal      = Color(0xFF26A69A);
  static const red       = Color(0xFFEF5350);
  static const textPrim  = Color(0xFFEEF2FF);
  static const textSub   = Color(0xFF7A8BA8);
  static const textMuted = Color(0xFF3D5470);
}

// ─── Models ───────────────────────────────────────────────────────────────────
class _Candle {
  final double open, high, low, close;
  const _Candle(this.open, this.high, this.low, this.close);
  bool get bullish => close >= open;
}

class _Stock {
  final String ticker, name, sector;
  final double price, open, high, low, change, changePercent, volume;
  final bool positive;
  final List<double> series;
  final List<_Candle> candles;
  const _Stock({
    required this.ticker, required this.name, required this.sector,
    required this.price, required this.open, required this.high,
    required this.low, required this.change, required this.changePercent,
    required this.volume, required this.positive,
    required this.series, required this.candles,
  });
}

// ─── ESE Data ─────────────────────────────────────────────────────────────────
const List<_Stock> _stocks = [
  _Stock(
    ticker: 'CBEET', name: 'Commercial Bank of Ethiopia',
    sector: 'Banking', price: 42.50, open: 41.80, high: 43.10, low: 41.50,
    change: 1.20, changePercent: 2.91, volume: 3.4, positive: true,
    series: [0.42,0.40,0.38,0.43,0.48,0.45,0.50,0.52,0.49,0.55,0.58,0.60,0.57,0.63,0.68,0.65,0.70,0.74,0.71,0.78],
    candles: [
      _Candle(38.0,39.5,37.2,39.1), _Candle(39.1,40.2,38.8,39.8),
      _Candle(39.8,41.0,39.4,40.6), _Candle(40.6,40.9,39.8,40.2),
      _Candle(40.2,41.5,39.9,41.3), _Candle(41.3,42.0,40.8,41.8),
      _Candle(41.8,42.5,41.2,41.5), _Candle(41.5,42.8,41.0,42.2),
      _Candle(42.2,43.1,41.8,41.9), _Candle(41.9,43.1,41.5,42.5),
    ],
  ),
  _Stock(
    ticker: 'AWBET', name: 'Awash Bank',
    sector: 'Banking', price: 38.75, open: 39.20, high: 39.40, low: 38.50,
    change: -0.45, changePercent: -1.15, volume: 2.1, positive: false,
    series: [0.60,0.62,0.65,0.61,0.58,0.63,0.60,0.55,0.57,0.53,0.50,0.52,0.48,0.50,0.46,0.44,0.47,0.43,0.41,0.38],
    candles: [
      _Candle(40.5,41.0,39.8,40.8), _Candle(40.8,41.2,40.2,40.3),
      _Candle(40.3,40.8,39.6,39.7), _Candle(39.7,40.2,39.2,40.0),
      _Candle(40.0,40.5,39.4,39.5), _Candle(39.5,40.0,39.0,39.8),
      _Candle(39.8,40.1,39.2,39.3), _Candle(39.3,39.8,38.8,39.6),
      _Candle(39.6,39.9,38.7,38.9), _Candle(38.9,39.4,38.5,38.75),
    ],
  ),
  _Stock(
    ticker: 'DASHET', name: 'Dashen Bank',
    sector: 'Banking', price: 35.20, open: 34.80, high: 35.60, low: 34.60,
    change: 0.80, changePercent: 2.32, volume: 1.8, positive: true,
    series: [0.30,0.32,0.28,0.35,0.38,0.34,0.40,0.42,0.39,0.45,0.48,0.46,0.50,0.53,0.51,0.56,0.58,0.55,0.61,0.64],
    candles: [
      _Candle(33.0,33.8,32.5,33.5), _Candle(33.5,34.2,33.1,34.0),
      _Candle(34.0,34.5,33.6,33.8), _Candle(33.8,34.8,33.5,34.6),
      _Candle(34.6,35.0,34.2,34.8), _Candle(34.8,35.2,34.4,35.0),
      _Candle(35.0,35.5,34.7,34.9), _Candle(34.9,35.6,34.6,35.3),
      _Candle(35.3,35.8,35.0,35.1), _Candle(35.1,35.6,34.6,35.2),
    ],
  ),
  _Stock(
    ticker: 'ETTEL', name: 'Ethio Telecom',
    sector: 'Telecom', price: 88.00, open: 85.50, high: 89.00, low: 85.00,
    change: 3.00, changePercent: 3.53, volume: 5.6, positive: true,
    series: [0.35,0.38,0.42,0.45,0.40,0.48,0.52,0.55,0.50,0.58,0.62,0.65,0.60,0.68,0.72,0.70,0.75,0.78,0.74,0.82],
    candles: [
      _Candle(82.0,83.5,81.0,83.0), _Candle(83.0,84.5,82.5,84.0),
      _Candle(84.0,85.0,83.2,83.5), _Candle(83.5,85.5,83.0,85.0),
      _Candle(85.0,86.0,84.5,85.5), _Candle(85.5,87.0,85.0,86.5),
      _Candle(86.5,87.5,85.8,86.8), _Candle(86.8,88.5,86.2,87.8),
      _Candle(87.8,89.0,87.0,87.5), _Candle(87.5,89.0,85.0,88.0),
    ],
  ),
  _Stock(
    ticker: 'ETBREW', name: 'Ethiopian Breweries',
    sector: 'FMCG', price: 55.00, open: 53.00, high: 55.80, low: 52.80,
    change: 2.50, changePercent: 4.76, volume: 4.2, positive: true,
    series: [0.25,0.30,0.35,0.28,0.40,0.38,0.45,0.50,0.48,0.55,0.60,0.58,0.63,0.68,0.65,0.70,0.72,0.68,0.75,0.80],
    candles: [
      _Candle(50.0,51.5,49.5,51.0), _Candle(51.0,52.0,50.5,51.5),
      _Candle(51.5,52.5,50.8,50.8), _Candle(50.8,52.8,50.5,52.5),
      _Candle(52.5,53.5,52.0,53.0), _Candle(53.0,54.0,52.5,53.8),
      _Candle(53.8,54.5,53.2,53.5), _Candle(53.5,55.0,53.2,54.8),
      _Candle(54.8,55.8,54.2,54.5), _Candle(54.5,55.8,52.8,55.0),
    ],
  ),
  _Stock(
    ticker: 'ABYET', name: 'Abyssinia Bank',
    sector: 'Banking', price: 29.60, open: 29.90, high: 30.10, low: 29.40,
    change: -0.30, changePercent: -1.00, volume: 0.9, positive: false,
    series: [0.65,0.60,0.62,0.58,0.60,0.55,0.57,0.53,0.55,0.50,0.52,0.48,0.50,0.47,0.49,0.44,0.46,0.43,0.45,0.42],
    candles: [
      _Candle(31.0,31.5,30.5,30.8), _Candle(30.8,31.2,30.3,30.5),
      _Candle(30.5,31.0,30.0,30.8), _Candle(30.8,31.0,30.2,30.3),
      _Candle(30.3,30.8,29.8,30.5), _Candle(30.5,30.8,29.9,30.0),
      _Candle(30.0,30.5,29.6,30.2), _Candle(30.2,30.5,29.7,29.8),
      _Candle(29.8,30.2,29.5,30.0), _Candle(30.0,30.1,29.4,29.6),
    ],
  ),
  _Stock(
    ticker: 'NBET', name: 'Nib Bank',
    sector: 'Banking', price: 24.10, open: 23.70, high: 24.40, low: 23.60,
    change: 0.55, changePercent: 2.33, volume: 0.7, positive: true,
    series: [0.38,0.35,0.40,0.42,0.39,0.45,0.43,0.48,0.50,0.47,0.52,0.55,0.52,0.57,0.60,0.58,0.62,0.65,0.62,0.68],
    candles: [
      _Candle(22.5,23.0,22.0,22.8), _Candle(22.8,23.2,22.4,23.0),
      _Candle(23.0,23.5,22.8,22.9), _Candle(22.9,23.6,22.7,23.4),
      _Candle(23.4,23.8,23.0,23.6), _Candle(23.6,24.0,23.3,23.8),
      _Candle(23.8,24.2,23.5,23.7), _Candle(23.7,24.2,23.5,24.0),
      _Candle(24.0,24.4,23.8,23.9), _Candle(23.9,24.4,23.6,24.1),
    ],
  ),
  _Stock(
    ticker: 'MBET', name: 'Meta Abo Brewery',
    sector: 'FMCG', price: 46.30, open: 47.00, high: 47.20, low: 46.10,
    change: -1.10, changePercent: -2.32, volume: 1.5, positive: false,
    series: [0.70,0.68,0.65,0.68,0.62,0.64,0.60,0.62,0.58,0.55,0.57,0.53,0.55,0.51,0.52,0.48,0.50,0.46,0.44,0.42],
    candles: [
      _Candle(48.5,49.0,47.8,48.2), _Candle(48.2,48.8,47.5,47.8),
      _Candle(47.8,48.5,47.3,48.2), _Candle(48.2,48.5,47.5,47.6),
      _Candle(47.6,48.2,47.0,47.8), _Candle(47.8,48.0,47.2,47.2),
      _Candle(47.2,47.8,46.8,47.5), _Candle(47.5,47.8,46.8,46.9),
      _Candle(46.9,47.5,46.5,47.2), _Candle(47.2,47.2,46.1,46.3),
    ],
  ),
];

// ─── Market Watch Screen ──────────────────────────────────────────────────────
class MarketWatchScreen extends StatefulWidget {
  const MarketWatchScreen({super.key});
  @override
  State<MarketWatchScreen> createState() => _MarketWatchScreenState();
}

class _MarketWatchScreenState extends State<MarketWatchScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late Animation<double> _fade;

  // Each card has its own chart mode (0 = line, 1 = candle)
  final Map<String, int> _chartModes = {};

  String _sectorFilter = 'All';
  final _sectors = ['All', 'Banking', 'Telecom', 'FMCG', 'Insurance'];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _entranceCtrl.forward();
    // Default all to line chart
    for (final s in _stocks) {
      _chartModes[s.ticker] = 0;
    }
  }

  @override
  void dispose() { _entranceCtrl.dispose(); super.dispose(); }

  List<_Stock> get _filtered => _sectorFilter == 'All'
      ? _stocks
      : _stocks.where((s) => s.sector == _sectorFilter).toList();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _C.bg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          Positioned(top: -40, right: -60, child: _Orb(220, _C.teal, 0.05)),
          Positioned(bottom: 100, left: -60, child: _Orb(180, _C.blue, 0.05)),

          FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top +
                    kToolbarHeight + 10),

                // Sector chips
                _SectorChips(
                  sectors: _sectors, selected: _sectorFilter,
                  onSelect: (s) => setState(() => _sectorFilter = s),
                ),
                const SizedBox(height: 8),

                // Summary
                _MarketSummary(stocks: _filtered),
                const SizedBox(height: 8),

                // Cards — always big, always showing chart
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final s = _filtered[i];
                      return _StockCard(
                        stock: s,
                        chartMode: _chartModes[s.ticker] ?? 0,
                        onChartMode: (m) =>
                            setState(() => _chartModes[s.ticker] = m),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: _C.bg.withOpacity(0.65),
            elevation: 0, centerTitle: true,
            automaticallyImplyLeading: false,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: _C.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _C.border, width: 1)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: _C.textSub, size: 15),
                ),
              ),
            ),
            title: Column(children: [
              const Text('ESE Market Watch',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                      color: _C.textPrim)),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 5, height: 5,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: _C.teal)),
                const SizedBox(width: 5),
                const Text('Live  ·  Thu 12 Mar 2026  09:44 EAT',
                    style: TextStyle(fontSize: 9, color: _C.textSub)),
              ]),
            ]),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: _C.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _C.border, width: 1)),
                  child: const Icon(Icons.refresh_rounded,
                      color: _C.textSub, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sector Chips ─────────────────────────────────────────────────────────────
class _SectorChips extends StatelessWidget {
  final List<String> sectors;
  final String selected;
  final ValueChanged<String> onSelect;
  const _SectorChips(
      {required this.sectors, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: sectors.length,
        itemBuilder: (_, i) {
          final s = sectors[i];
          final active = s == selected;
          return GestureDetector(
            onTap: () => onSelect(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? _C.gold.withOpacity(0.15) : _C.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: active ? _C.gold.withOpacity(0.40) : _C.border,
                    width: 1),
              ),
              child: Text(s, style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? _C.gold : _C.textSub)),
            ),
          );
        },
      ),
    );
  }
}

// ─── Market Summary ───────────────────────────────────────────────────────────
class _MarketSummary extends StatelessWidget {
  final List<_Stock> stocks;
  const _MarketSummary({required this.stocks});

  @override
  Widget build(BuildContext context) {
    final gainers = stocks.where((s) => s.positive).length;
    final losers  = stocks.length - gainers;
    final avg     = stocks.isEmpty ? 0.0
        : stocks.map((s) => s.changePercent).reduce((a, b) => a + b)
        / stocks.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(color: _C.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.border, width: 1)),
        child: Row(children: [
          _SumTile('Stocks',  '${stocks.length}',  _C.textPrim),
          _SumDiv(),
          _SumTile('Gainers', '$gainers',           _C.teal),
          _SumDiv(),
          _SumTile('Losers',  '$losers',            _C.red),
          _SumDiv(),
          _SumTile('Avg',
              '${avg >= 0 ? '+' : ''}${avg.toStringAsFixed(2)}%',
              avg >= 0 ? _C.teal : _C.red),
        ]),
      ),
    );
  }
}

class _SumTile extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SumTile(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
          color: color, letterSpacing: -0.3)),
      Text(label, style: const TextStyle(
          fontSize: 8.5, color: _C.textSub, letterSpacing: 0.4)),
    ]),
  );
}

class _SumDiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 26, color: _C.border);
}

// ─── Stock Card — always fully expanded ───────────────────────────────────────
class _StockCard extends StatelessWidget {
  final _Stock stock;
  final int chartMode;
  final ValueChanged<int> onChartMode;

  const _StockCard({
    required this.stock,
    required this.chartMode,
    required this.onChartMode,
  });

  @override
  Widget build(BuildContext context) {
    final color = stock.positive ? _C.teal : _C.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.28), width: 1),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.12),
              blurRadius: 24, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withOpacity(0.35),
              blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: [

          // ══════════════════════════════════════════════════════════════
          //  FULL-BLEED CHART ZONE
          // ══════════════════════════════════════════════════════════════
          SizedBox(
            height: 175,
            width: double.infinity,
            child: Stack(
              children: [

                // ── Chart painter fills every pixel ──────────────────
                Positioned.fill(
                  child: chartMode == 0
                      ? CustomPaint(
                      painter: _FullAreaPainter(
                          series: stock.series, color: color))
                      : CustomPaint(
                      painter: _FullCandlePainter(
                          candles: stock.candles,
                          bullColor: _C.teal,
                          bearColor: _C.red)),
                ),

                // ── Top fade so overlay text stays readable ───────────
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _C.card.withOpacity(0.85),
                          _C.card.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Company info — top left ────────────────────────────
                Positioned(top: 12, left: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        // Ticker pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: color.withOpacity(0.45), width: 1),
                          ),
                          child: Text(stock.ticker,
                              style: TextStyle(fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: color, letterSpacing: 0.6)),
                        ),
                        const SizedBox(width: 8),
                        // Sector pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(stock.sector,
                              style: const TextStyle(
                                  fontSize: 9, color: _C.textSub)),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      // Company name
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 130,
                        child: Text(stock.name,
                            style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: _C.textSub,
                                height: 1.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),

                // ── Price + change — top right ────────────────────────
                Positioned(top: 12, right: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('E ${stock.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: _C.textPrim,
                              letterSpacing: -0.6,
                              height: 1)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: color.withOpacity(0.35), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                                stock.positive
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                color: color, size: 11),
                            const SizedBox(width: 3),
                            Text(
                                '${stock.positive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: color)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Chart type toggle — bottom left of chart ──────────
                Positioned(bottom: 8, left: 14,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _C.surface.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _C.border.withOpacity(0.60), width: 1),
                        ),
                        child: Row(children: [
                          _ToggleBtn('Line',   0, chartMode, onChartMode),
                          Container(width: 1, height: 22,
                              color: _C.border.withOpacity(0.6)),
                          _ToggleBtn('Candle', 1, chartMode, onChartMode),
                        ]),
                      ),
                    ),
                  ),
                ),

                // ── 10-Day label — bottom right ───────────────────────
                Positioned(bottom: 12, right: 14,
                  child: Text('10-Day',
                      style: TextStyle(fontSize: 9.5,
                          color: _C.textMuted.withOpacity(0.70),
                          letterSpacing: 0.4)),
                ),
              ],
            ),
          ),

          // ══════════════════════════════════════════════════════════════
          //  OHLCV + TRADE ROW
          // ══════════════════════════════════════════════════════════════
          Container(
            decoration: BoxDecoration(
              color: _C.surface.withOpacity(0.80),
              border: Border(top: BorderSide(
                  color: color.withOpacity(0.15), width: 1)),
            ),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(children: [
              // OHLCV row
              Row(children: [
                _OhlcCell('OPEN',
                    'E ${stock.open.toStringAsFixed(2)}', _C.textPrim),
                _OhlcDiv(),
                _OhlcCell('HIGH',
                    'E ${stock.high.toStringAsFixed(2)}', _C.teal),
                _OhlcDiv(),
                _OhlcCell('LOW',
                    'E ${stock.low.toStringAsFixed(2)}', _C.red),
                _OhlcDiv(),
                _OhlcCell('CHANGE',
                    '${stock.positive ? '+' : ''}E ${stock.change.toStringAsFixed(2)}',
                    color),
                _OhlcDiv(),
                _OhlcCell('VOL', '${stock.volume}M', _C.textSub),
              ]),

              const SizedBox(height: 8),

              // Full-width Trade button
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: stock.positive
                          ? [const Color(0xFF1B5E20),
                        const Color(0xFF2E7D32)]
                          : [const Color(0xFF7F0000),
                        const Color(0xFFC62828)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: color.withOpacity(0.50), width: 1),
                    boxShadow: [BoxShadow(
                        color: color.withOpacity(0.28),
                        blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                          stock.positive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: color, size: 18),
                      const SizedBox(width: 8),
                      Text('Trade ${stock.ticker}',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: color,
                              letterSpacing: 0.3)),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Chart toggle button ──────────────────────────────────────────────────────
class _ToggleBtn extends StatelessWidget {
  final String label;
  final int index, current;
  final ValueChanged<int> onTap;
  const _ToggleBtn(this.label, this.index, this.current, this.onTap);

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        color: active ? _C.gold.withOpacity(0.18) : Colors.transparent,
        child: Text(label, style: TextStyle(
            fontSize: 10.5,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? _C.gold : _C.textMuted)),
      ),
    );
  }
}

// ─── OHLCV helpers ────────────────────────────────────────────────────────────
class _OhlcCell extends StatelessWidget {
  final String label, value;
  final Color color;
  const _OhlcCell(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(label, style: const TextStyle(fontSize: 7,
          color: _C.textMuted, letterSpacing: 0.8,
          fontWeight: FontWeight.w700)),
      const SizedBox(height: 3),
      Text(value, style: TextStyle(fontSize: 10.5,
          fontWeight: FontWeight.w700, color: color),
          overflow: TextOverflow.ellipsis),
    ]),
  );
}

class _OhlcDiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: _C.border);
}

// ─── Full-Bleed Area Chart ────────────────────────────────────────────────────
class _FullAreaPainter extends CustomPainter {
  final List<double> series;
  final Color color;
  const _FullAreaPainter({required this.series, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (series.length < 2) return;

    // Background
    canvas.drawRect(Offset.zero & size,
        Paint()..color = const Color(0xFF0B1628));

    // Grid lines
    final gridP = Paint()
      ..color = const Color(0xFF1E2E45).withOpacity(0.45)
      ..strokeWidth = 0.6;
    for (int i = 1; i <= 5; i++) {
      final y = (i / 6) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridP);
    }

    // Points — occupy full height range
    // Top 28% is reserved for price overlay text; line lives in remaining 72%
    const topReserve = 0.28;
    final pts = <Offset>[
      for (int i = 0; i < series.length; i++)
        Offset(
          (i / (series.length - 1)) * size.width,
          size.height * topReserve +
              (1 - series[i]) * size.height * (1 - topReserve) * 0.92,
        ),
    ];

    // Smooth bezier
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i+1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i+1].dx) / 2, pts[i+1].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i+1].dx, pts[i+1].dy);
    }

    // Gradient fill under line
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.42), color.withOpacity(0.02)],
      ).createShader(Offset.zero & size));

    // Stroke
    canvas.drawPath(path, Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Dots every ~4 points + last
    for (int i = 0; i < pts.length; i++) {
      if (i % 4 == 0 || i == pts.length - 1) {
        canvas.drawCircle(pts[i], 3.2, Paint()..color = color);
        canvas.drawCircle(pts[i], 6.5,
            Paint()..color = color.withOpacity(0.18));
      }
    }

    // Current price vertical cursor
    canvas.drawLine(
      Offset(pts.last.dx, size.height * topReserve),
      Offset(pts.last.dx, size.height),
      Paint()
        ..color = color.withOpacity(0.35)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_FullAreaPainter o) => o.series != series;
}

// ─── Full-Bleed Candlestick Chart ─────────────────────────────────────────────
class _FullCandlePainter extends CustomPainter {
  final List<_Candle> candles;
  final Color bullColor, bearColor;
  const _FullCandlePainter({
    required this.candles,
    required this.bullColor,
    required this.bearColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    // Background
    canvas.drawRect(Offset.zero & size,
        Paint()..color = const Color(0xFF0B1628));

    // Grid
    final gridP = Paint()
      ..color = const Color(0xFF1E2E45).withOpacity(0.45)
      ..strokeWidth = 0.6;
    for (int i = 1; i <= 5; i++) {
      final y = (i / 6) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridP);
    }

    // Candles sit in lower 72% (top 28% for overlay text)
    const topReserve = 0.28;
    final chartTop    = size.height * topReserve;
    final chartHeight = size.height * (1 - topReserve) * 0.92;

    final allP = candles.expand((c) => [c.high, c.low]).toList();
    final minP = allP.reduce(math.min);
    final maxP = allP.reduce(math.max);
    final range = (maxP - minP) == 0 ? 1.0 : maxP - minP;

    double norm(double p) =>
        chartTop + chartHeight - ((p - minP) / range) * chartHeight;

    final n     = candles.length;
    final gap   = size.width / n;
    final bodyW = gap * 0.56;

    for (int i = 0; i < n; i++) {
      final c     = candles[i];
      final cx    = gap * i + gap / 2;
      final color = c.bullish ? bullColor : bearColor;

      // Wick
      canvas.drawLine(
        Offset(cx, norm(c.high)), Offset(cx, norm(c.low)),
        Paint()..color = color.withOpacity(0.65)
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke,
      );

      // Body
      final bTop = norm(c.bullish ? c.close : c.open);
      final bBot = norm(c.bullish ? c.open  : c.close);
      final bH   = (bBot - bTop).abs().clamp(2.5, double.infinity);

      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - bodyW / 2, bTop, bodyW, bH),
        const Radius.circular(3),
      );
      canvas.drawRRect(rr, Paint()..color = color.withOpacity(0.90));

      // Glow on bullish
      if (c.bullish) {
        canvas.drawRRect(rr.inflate(2.5),
            Paint()..color = color.withOpacity(0.12));
      }
    }
  }

  @override
  bool shouldRepaint(_FullCandlePainter o) => o.candles != candles;
}

// ─── Glow Orb ─────────────────────────────────────────────────────────────────
class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
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