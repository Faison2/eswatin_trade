import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../settings /settings.dart';

// ─── Dark tokens ──────────────────────────────────────────────────────────────
class _Dark {
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
  // Chart painter
  static const chartBg   = Color(0xFF0B1628);
  static const chartGrid = Color(0xFF1E2E45);
}

// ─── Light tokens ─────────────────────────────────────────────────────────────
class _Light {
  static const bg        = Color(0xFFF0F4FB);
  static const surface   = Color(0xFFFFFFFF);
  static const card      = Color(0xFFFFFFFF);
  static const border    = Color(0xFFDDE3EF);
  static const gold      = Color(0xFFC49020);
  static const blue      = Color(0xFF1565C0);
  static const teal      = Color(0xFF1A8A80);
  static const red       = Color(0xFFD43F3C);
  static const textPrim  = Color(0xFF0D1728);
  static const textSub   = Color(0xFF64748B);
  static const textMuted = Color(0xFFADB5C7);
  // Chart painter
  static const chartBg   = Color(0xFFF0F6FF);
  static const chartGrid = Color(0xFFDDE3EF);
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
  final bool   positive;
  final List<double>  series;
  final List<_Candle> candles;

  const _Stock({
    required this.ticker, required this.name, required this.sector,
    required this.price,  required this.open,  required this.high,
    required this.low,    required this.change, required this.changePercent,
    required this.volume, required this.positive,
    required this.series, required this.candles,
  });

  factory _Stock.fromJson(Map<String, dynamic> j) {
    final double lastPrice    = (j['lastPrice']     as num? ?? 0).toDouble();
    final double openingPrice = (j['openingPrice']  as num? ?? 0).toDouble();
    final double closingPrice = (j['closingPrice']  as num? ?? lastPrice).toDouble();
    final double highestPrice = (j['highestPrice']  as num? ?? lastPrice).toDouble();
    final double lowestPrice  = (j['lowestPrice']   as num? ?? lastPrice).toDouble();
    final double changeVal    = (j['changeValue']   as num? ?? 0).toDouble();
    final double changePct    = (j['changePercent'] as num? ?? 0).toDouble();
    final double shareVolume  = (j['shareVolume']   as num? ?? 0).toDouble();
    final String trend        = (j['trend']         as String? ?? 'FLAT').toUpperCase();
    final String fullname     = (j['fullname']      as String? ?? 'Unknown').trim();
    final String companyCode  = (j['company']       as String? ?? '');

    double effectivePct = changePct;
    if (effectivePct == 0) {
      if (trend == 'UP')   effectivePct =  0.01;
      if (trend == 'DOWN') effectivePct = -0.01;
    }

    return _Stock(
      ticker:        _deriveTicker(companyCode, fullname),
      name:          fullname,
      sector:        _deriveSector(fullname),
      price:         lastPrice,
      open:          openingPrice,
      high:          highestPrice,
      low:           lowestPrice,
      change:        changeVal,
      changePercent: effectivePct,
      volume:        shareVolume,
      positive:      effectivePct >= 0,
      series:  _buildSeries(open: openingPrice, close: closingPrice,
          high: highestPrice, low: lowestPrice, last: lastPrice, trend: trend),
      candles: _buildCandles(open: openingPrice, close: closingPrice,
          high: highestPrice, low: lowestPrice, last: lastPrice, trend: trend),
    );
  }

  static String _deriveTicker(String code, String name) {
    final letters = code.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (letters.isNotEmpty && letters.length <= 6) return letters.toUpperCase();
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words.first.substring(0, math.min(5, words.first.length)).toUpperCase();
    }
    return words.where((w) => w.isNotEmpty).take(5).map((w) => w[0].toUpperCase()).join();
  }

  static String _deriveSector(String name) {
    final n = name.toLowerCase();
    if (n.contains('bank') || n.contains('nedbank') || n.contains('fnb') ||
        n.contains('capital') || n.contains('financial') ||
        n.contains('investment')) return 'Finance';
    if (n.contains('sugar') || n.contains('brew') || n.contains('food') ||
        n.contains('beverag')) return 'FMCG';
    if (n.contains('telecom') || n.contains('wireless') ||
        n.contains('mobile')) return 'Telecom';
    if (n.contains('property') || n.contains('real estate') ||
        n.contains('precast') || n.contains('construction')) return 'Real Estate';
    return 'Diversified';
  }

  static List<double> _buildSeries({
    required double open, required double close, required double high,
    required double low,  required double last,  required String trend,
  }) {
    final prices = [open, close, high, low, last].where((p) => p > 0).toList();
    if (prices.isEmpty) return List.filled(20, 0.5);
    final minP    = prices.reduce(math.min);
    final maxP    = prices.reduce(math.max);
    final range   = (maxP - minP).abs();
    double norm(double v) => range == 0 ? 0.5 : ((v - minP) / range).clamp(0.0, 1.0);
    final rng     = math.Random((open * 100).toInt() ^ (last * 100).toInt());
    final goingUp = trend == 'UP' || last >= open;
    final List<double> pts = [];
    for (int i = 0; i < 20; i++) {
      final t    = i / 19.0;
      final base = open + (last - open) * t;
      double bump = 0;
      if (i >= 7 && i <= 12) {
        final mid  = (i - 7) / 5.0;
        final tent = mid < 0.5 ? mid * 2 : (1 - mid) * 2;
        bump = (goingUp ? 1 : -1) * (range * 0.25) * tent;
      }
      final wiggle = range * 0.08 * (rng.nextDouble() - 0.5);
      pts.add(norm((base + bump + wiggle).clamp(minP, maxP)));
    }
    return pts;
  }

  static List<_Candle> _buildCandles({
    required double open, required double close, required double high,
    required double low,  required double last,  required String trend,
  }) {
    final prices = [open, close, high, low, last].where((p) => p > 0).toList();
    if (prices.isEmpty) return List.filled(10, const _Candle(1, 1, 1, 1));
    final minP    = prices.reduce(math.min);
    final maxP    = prices.reduce(math.max);
    final range   = (maxP - minP).abs();
    final goingUp = trend == 'UP' || last >= open;
    final rng     = math.Random((open * 100).toInt() ^ (close * 100).toInt());
    final List<_Candle> candles = [];
    for (int i = 0; i < 10; i++) {
      final t      = i / 9.0;
      final base   = open + (last - open) * t;
      final body   = range * 0.05 * (rng.nextDouble() + 0.3);
      final wick   = range * 0.04 * (rng.nextDouble() + 0.2);
      final isBull = goingUp ? rng.nextDouble() > 0.35 : rng.nextDouble() > 0.65;
      final cOpen  = (base - (isBull ? body : 0)).clamp(minP, maxP);
      final cClose = (base + (isBull ? body : 0) - (isBull ? 0 : body)).clamp(minP, maxP);
      final cHigh  = (math.max(cOpen, cClose) + wick).clamp(minP, maxP);
      final cLow   = (math.min(cOpen, cClose) - wick).clamp(minP, maxP);
      candles.add(_Candle(cOpen, cHigh, cLow, cClose));
    }
    return candles;
  }
}

// ─── Market Watch Screen ──────────────────────────────────────────────────────
class MarketWatchScreen extends StatefulWidget {
  final AppThemeNotifier themeNotifier;
  const MarketWatchScreen({super.key, required this.themeNotifier});

  @override
  State<MarketWatchScreen> createState() => _MarketWatchScreenState();
}

class _MarketWatchScreenState extends State<MarketWatchScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late Animation<double>   _fade;

  List<_Stock> _stocks  = [];
  bool    _loading      = true;
  String? _error;
  DateTime? _lastFetch;

  final Map<String, int> _chartModes = {};
  String       _sectorFilter = 'All';
  List<String> _sectors      = ['All'];

  // ── Theme helpers ────────────────────────────────────────────────────────
  bool   get _isLight  => widget.themeNotifier.isLight;
  Color  get _bg       => _isLight ? _Light.bg       : _Dark.bg;
  Color  get _surface  => _isLight ? _Light.surface  : _Dark.surface;
  Color  get _card     => _isLight ? _Light.card     : _Dark.card;
  Color  get _border   => _isLight ? _Light.border   : _Dark.border;
  Color  get _gold     => _isLight ? _Light.gold     : _Dark.gold;
  Color  get _teal     => _isLight ? _Light.teal     : _Dark.teal;
  Color  get _red      => _isLight ? _Light.red      : _Dark.red;
  Color  get _textPrim => _isLight ? _Light.textPrim : _Dark.textPrim;
  Color  get _textSub  => _isLight ? _Light.textSub  : _Dark.textSub;
  Color  get _textMut  => _isLight ? _Light.textMuted: _Dark.textMuted;
  Color  get _chartBg  => _isLight ? _Light.chartBg  : _Dark.chartBg;
  Color  get _chartGrid=> _isLight ? _Light.chartGrid : _Dark.chartGrid;

  void _rebuild() => setState(() {});

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    widget.themeNotifier.addListener(_rebuild);
    _fetchMarketData();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    widget.themeNotifier.removeListener(_rebuild);
    super.dispose();
  }

  Future<void> _fetchMarketData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('session_token') ?? '';
      final response = await http.get(
        Uri.parse('https://app.trading-ese.com/eseapi/Home/MarketWatch'),
        headers: {
          'Content-Type':  'application/json',
          'Accept':        'application/json',
          'Authorization': 'Bearer $token',
          'sessionToken':  token,
        },
      ).timeout(const Duration(seconds: 20));

      if (!mounted) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 &&
          (data['responseCode'] == 200 || data['securities'] != null)) {
        final rawList = data['securities'] as List<dynamic>? ?? [];
        final stocks  = rawList
            .map((s) => _Stock.fromJson(s as Map<String, dynamic>))
            .toList();
        final sectorSet = <String>{'All'};
        for (final s in stocks) sectorSet.add(s.sector);
        for (final s in stocks) _chartModes.putIfAbsent(s.ticker, () => 0);
        _entranceCtrl.reset();
        setState(() {
          _stocks    = stocks;
          _sectors   = sectorSet.toList();
          _loading   = false;
          _lastFetch = DateTime.now();
          if (!_sectors.contains(_sectorFilter)) _sectorFilter = 'All';
        });
        _entranceCtrl.forward();
      } else {
        setState(() {
          _error   = data['responseMessage'] as String? ?? 'Failed to load market data.';
          _loading = false;
        });
      }
    } on http.ClientException catch (e) {
      if (mounted) setState(() { _error = 'Network error: ${e.message}'; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Unable to reach ESE servers.'; _loading = false; });
    }
  }

  List<_Stock> get _filtered => _sectorFilter == 'All'
      ? _stocks
      : _stocks.where((s) => s.sector == _sectorFilter).toList();

  String get _timeLabel {
    if (_lastFetch == null) return 'Fetching…';
    final h = _lastFetch!.hour.toString().padLeft(2, '0');
    final m = _lastFetch!.minute.toString().padLeft(2, '0');
    return 'Updated $h:$m';
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
        appBar: _buildAppBar(context),
        body: Stack(children: [
          Positioned(top: -40, right: -60,
              child: _Orb(220, _teal, 0.05)),
          Positioned(bottom: 100, left: -60,
              child: _Orb(180, _isLight ? _Light.blue : _Dark.blue, 0.05)),

          if (_loading)
            _FullLoadingState(gold: _gold, textSub: _textSub)
          else if (_error != null)
            _FullErrorState(message: _error!, onRetry: _fetchMarketData,
                red: _red, gold: _gold, textSub: _textSub, isLight: _isLight)
          else
            FadeTransition(
              opacity: _fade,
              child: Column(children: [
                SizedBox(height: MediaQuery.of(context).padding.top +
                    kToolbarHeight + 10),

                _SectorChips(
                  sectors:  _sectors,
                  selected: _sectorFilter,
                  onSelect: (s) => setState(() => _sectorFilter = s),
                  gold:     _gold,
                  card:     _card,
                  border:   _border,
                  textSub:  _textSub,
                  isLight:  _isLight,
                ),
                const SizedBox(height: 8),

                _MarketSummary(
                  stocks:   _filtered,
                  card:     _card,
                  border:   _border,
                  textPrim: _textPrim,
                  teal:     _teal,
                  red:      _red,
                  isLight:  _isLight,
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final s = _filtered[i];
                      return _StockCard(
                        stock:       s,
                        chartMode:   _chartModes[s.ticker] ?? 0,
                        onChartMode: (m) =>
                            setState(() => _chartModes[s.ticker] = m),
                        isLight:     _isLight,
                        card:        _card,
                        surface:     _surface,
                        border:      _border,
                        gold:        _gold,
                        teal:        _teal,
                        red:         _red,
                        textPrim:    _textPrim,
                        textSub:     _textSub,
                        textMuted:   _textMut,
                        chartBg:     _chartBg,
                        chartGrid:   _chartGrid,
                      );
                    },
                  ),
                ),
              ]),
            ),
        ]),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: _bg.withOpacity(0.80),
              border: Border(bottom: BorderSide(
                  color: _border.withOpacity(0.5), width: 1)),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0, centerTitle: true,
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
                      boxShadow: _isLight ? [BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8, offset: const Offset(0, 2))] : [],
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: _textSub, size: 15),
                  ),
                ),
              ),
              title: Column(children: [
                Text('ESE Market Watch',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                        color: _textPrim)),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 5, height: 5,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: _teal)),
                  const SizedBox(width: 5),
                  Text('Live  ·  $_timeLabel',
                      style: TextStyle(fontSize: 9, color: _textSub)),
                ]),
              ]),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: _fetchMarketData,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _border, width: 1),
                        boxShadow: _isLight ? [BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8, offset: const Offset(0, 2))] : [],
                      ),
                      child: Icon(Icons.refresh_rounded,
                          color: _textSub, size: 16),
                    ),
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

// ─── Full Loading ─────────────────────────────────────────────────────────────
class _FullLoadingState extends StatelessWidget {
  final Color gold, textSub;
  const _FullLoadingState({required this.gold, required this.textSub});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: gold, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text('Loading market data…',
              style: TextStyle(fontSize: 13, color: textSub)),
        ]));
  }
}

// ─── Full Error ───────────────────────────────────────────────────────────────
class _FullErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Color red, gold, textSub;
  final bool isLight;

  const _FullErrorState({required this.message, required this.onRetry,
    required this.red, required this.gold, required this.textSub,
    required this.isLight});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.wifi_off_rounded, color: red.withOpacity(0.65), size: 40),
          const SizedBox(height: 14),
          Text(message, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: textSub)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
              decoration: BoxDecoration(
                color: gold.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: gold.withOpacity(0.30), width: 1),
              ),
              child: Text('Retry', style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w700, color: gold)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Sector Chips ─────────────────────────────────────────────────────────────
class _SectorChips extends StatelessWidget {
  final List<String> sectors;
  final String selected;
  final ValueChanged<String> onSelect;
  final Color gold, card, border, textSub;
  final bool isLight;

  const _SectorChips({required this.sectors, required this.selected,
    required this.onSelect, required this.gold, required this.card,
    required this.border, required this.textSub, required this.isLight});

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
          final s      = sectors[i];
          final active = s == selected;
          return GestureDetector(
            onTap: () => onSelect(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? gold.withOpacity(0.15) : card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: active ? gold.withOpacity(0.40) : border,
                    width: 1),
                boxShadow: active && isLight ? [BoxShadow(
                    color: gold.withOpacity(0.12),
                    blurRadius: 8, offset: const Offset(0, 2))] : [],
              ),
              child: Text(s, style: TextStyle(fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? gold : textSub)),
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
  final Color card, border, textPrim, teal, red;
  final bool isLight;

  const _MarketSummary({required this.stocks, required this.card,
    required this.border, required this.textPrim, required this.teal,
    required this.red, required this.isLight});

  @override
  Widget build(BuildContext context) {
    final gainers = stocks.where((s) => s.positive).length;
    final losers  = stocks.length - gainers;
    final avg     = stocks.isEmpty ? 0.0
        : stocks.map((s) => s.changePercent).reduce((a, b) => a + b) / stocks.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1),
          boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 10, offset: const Offset(0, 3))] : [],
        ),
        child: Row(children: [
          _SumTile('Stocks',  '${stocks.length}', textPrim),
          _SumDiv(border: border),
          _SumTile('Gainers', '$gainers', teal),
          _SumDiv(border: border),
          _SumTile('Losers',  '$losers', red),
          _SumDiv(border: border),
          _SumTile('Avg',
              '${avg >= 0 ? '+' : ''}${avg.toStringAsFixed(2)}%',
              avg >= 0 ? teal : red),
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
      Text(label, style: const TextStyle(fontSize: 8.5,
          color: Color(0xFF7A8BA8), letterSpacing: 0.4)),
    ]),
  );
}

class _SumDiv extends StatelessWidget {
  final Color border;
  const _SumDiv({required this.border});

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 26, color: border);
}

// ─── Stock Card ───────────────────────────────────────────────────────────────
class _StockCard extends StatelessWidget {
  final _Stock stock;
  final int    chartMode;
  final ValueChanged<int> onChartMode;
  final bool   isLight;
  final Color  card, surface, border, gold, teal, red;
  final Color  textPrim, textSub, textMuted, chartBg, chartGrid;

  const _StockCard({
    required this.stock, required this.chartMode, required this.onChartMode,
    required this.isLight, required this.card, required this.surface,
    required this.border, required this.gold, required this.teal,
    required this.red, required this.textPrim, required this.textSub,
    required this.textMuted, required this.chartBg, required this.chartGrid,
  });

  @override
  Widget build(BuildContext context) {
    final color = stock.positive ? teal : red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.28), width: 1),
        boxShadow: [
          BoxShadow(color: color.withOpacity(isLight ? 0.08 : 0.12),
              blurRadius: 24, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withOpacity(isLight ? 0.06 : 0.35),
              blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: [
          // ── Chart zone ───────────────────────────────────────────
          SizedBox(
            height: 175, width: double.infinity,
            child: Stack(children: [
              Positioned.fill(
                child: chartMode == 0
                    ? CustomPaint(painter: _FullAreaPainter(
                    series: stock.series, color: color,
                    chartBg: chartBg, chartGrid: chartGrid))
                    : CustomPaint(painter: _FullCandlePainter(
                    candles: stock.candles,
                    bullColor: teal, bearColor: red,
                    chartBg: chartBg, chartGrid: chartGrid)),
              ),

              // Top fade
              Positioned(top: 0, left: 0, right: 0,
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [card.withOpacity(0.85), card.withOpacity(0.0)],
                    ),
                  ),
                ),
              ),

              // Company info — top left
              Positioned(top: 12, left: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withOpacity(0.45), width: 1),
                        ),
                        child: Text(stock.ticker,
                            style: TextStyle(fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: color, letterSpacing: 0.6)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLight
                              ? Colors.black.withOpacity(0.06)
                              : Colors.black.withOpacity(0.30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(stock.sector,
                            style: TextStyle(fontSize: 9, color: textSub)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 130,
                      child: Text(stock.name,
                          style: TextStyle(fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: textSub, height: 1.2),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),

              // Price + change — top right
              Positioned(top: 12, right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('E ${stock.price.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                            color: textPrim, letterSpacing: -0.6, height: 1)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withOpacity(0.35), width: 1),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(stock.positive
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                            color: color, size: 11),
                        const SizedBox(width: 3),
                        Text(
                            '${stock.positive ? '+' : ''}${stock.changePercent.abs() < 0.02 ? '0.0' : stock.changePercent.toStringAsFixed(2)}%',
                            style: TextStyle(fontSize: 10,
                                fontWeight: FontWeight.w800, color: color)),
                      ]),
                    ),
                  ],
                ),
              ),

              // Chart type toggle — bottom left
              Positioned(bottom: 8, left: 14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: surface.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: border.withOpacity(0.60), width: 1),
                      ),
                      child: Row(children: [
                        _ToggleBtn('Line',   0, chartMode, onChartMode,
                            gold: gold, textMuted: textMuted),
                        Container(width: 1, height: 22,
                            color: border.withOpacity(0.6)),
                        _ToggleBtn('Candle', 1, chartMode, onChartMode,
                            gold: gold, textMuted: textMuted),
                      ]),
                    ),
                  ),
                ),
              ),

              // 10-Day label — bottom right
              Positioned(bottom: 12, right: 14,
                child: Text('10-Day',
                    style: TextStyle(fontSize: 9.5,
                        color: textMuted.withOpacity(0.70),
                        letterSpacing: 0.4)),
              ),
            ]),
          ),

          // ── OHLCV + Trade row ────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: surface.withOpacity(isLight ? 0.95 : 0.80),
              border: Border(top: BorderSide(
                  color: color.withOpacity(0.15), width: 1)),
            ),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(children: [
              Row(children: [
                _OhlcCell('OPEN',
                    'E ${stock.open.toStringAsFixed(2)}', textPrim),
                _OhlcDiv(border: border),
                _OhlcCell('HIGH',
                    'E ${stock.high.toStringAsFixed(2)}', teal),
                _OhlcDiv(border: border),
                _OhlcCell('LOW',
                    'E ${stock.low.toStringAsFixed(2)}', red),
                _OhlcDiv(border: border),
                _OhlcCell('CHANGE',
                    '${stock.positive ? '+' : ''}E ${stock.change.abs().toStringAsFixed(2)}',
                    color),
                _OhlcDiv(border: border),
                _OhlcCell('VOL',
                    stock.volume == 0 ? '—' : stock.volume.toStringAsFixed(0),
                    textSub),
              ]),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.40), width: 1),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.20),
                        blurRadius: 14, offset: const Offset(0, 4))],
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(stock.positive
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                            color: color, size: 18),
                        const SizedBox(width: 8),
                        Text('Trade ${stock.ticker}',
                            style: TextStyle(fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: color, letterSpacing: 0.3)),
                      ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Toggle Button ────────────────────────────────────────────────────────────
class _ToggleBtn extends StatelessWidget {
  final String label;
  final int    index, current;
  final Color  gold, textMuted;
  final ValueChanged<int> onTap;

  const _ToggleBtn(this.label, this.index, this.current, this.onTap,
      {required this.gold, required this.textMuted});

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        color: active ? gold.withOpacity(0.18) : Colors.transparent,
        child: Text(label, style: TextStyle(fontSize: 10.5,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? gold : textMuted)),
      ),
    );
  }
}

// ─── OHLCV helpers ────────────────────────────────────────────────────────────
class _OhlcCell extends StatelessWidget {
  final String label, value;
  final Color  color;
  const _OhlcCell(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(label, style: const TextStyle(fontSize: 7,
          color: Color(0xFF3D5470), letterSpacing: 0.8,
          fontWeight: FontWeight.w700)),
      const SizedBox(height: 3),
      Text(value, style: TextStyle(fontSize: 10.5,
          fontWeight: FontWeight.w700, color: color),
          overflow: TextOverflow.ellipsis),
    ]),
  );
}

class _OhlcDiv extends StatelessWidget {
  final Color border;
  const _OhlcDiv({required this.border});

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: border);
}

// ─── Full-Bleed Area Chart ────────────────────────────────────────────────────
class _FullAreaPainter extends CustomPainter {
  final List<double> series;
  final Color color, chartBg, chartGrid;
  const _FullAreaPainter({required this.series, required this.color,
    required this.chartBg, required this.chartGrid});

  @override
  void paint(Canvas canvas, Size size) {
    if (series.length < 2) return;

    canvas.drawRect(Offset.zero & size, Paint()..color = chartBg);

    final gridP = Paint()
      ..color = chartGrid.withOpacity(0.55)
      ..strokeWidth = 0.6;
    for (int i = 1; i <= 5; i++) {
      final y = (i / 6) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridP);
    }

    const topReserve = 0.28;
    final pts = <Offset>[
      for (int i = 0; i < series.length; i++)
        Offset(
          (i / (series.length - 1)) * size.width,
          size.height * topReserve +
              (1 - series[i]) * size.height * (1 - topReserve) * 0.92,
        ),
    ];

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i+1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i+1].dx) / 2, pts[i+1].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy,
          pts[i+1].dx, pts[i+1].dy);
    }

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

    canvas.drawPath(path, Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    for (int i = 0; i < pts.length; i++) {
      if (i % 4 == 0 || i == pts.length - 1) {
        canvas.drawCircle(pts[i], 3.2, Paint()..color = color);
        canvas.drawCircle(pts[i], 6.5, Paint()..color = color.withOpacity(0.18));
      }
    }

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
  bool shouldRepaint(_FullAreaPainter o) =>
      o.series != series || o.color != color ||
          o.chartBg != chartBg || o.chartGrid != chartGrid;
}

// ─── Full-Bleed Candlestick Chart ─────────────────────────────────────────────
class _FullCandlePainter extends CustomPainter {
  final List<_Candle> candles;
  final Color bullColor, bearColor, chartBg, chartGrid;
  const _FullCandlePainter({required this.candles, required this.bullColor,
    required this.bearColor, required this.chartBg, required this.chartGrid});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    canvas.drawRect(Offset.zero & size, Paint()..color = chartBg);

    final gridP = Paint()
      ..color = chartGrid.withOpacity(0.55)
      ..strokeWidth = 0.6;
    for (int i = 1; i <= 5; i++) {
      final y = (i / 6) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridP);
    }

    const topReserve  = 0.28;
    final chartTop    = size.height * topReserve;
    final chartHeight = size.height * (1 - topReserve) * 0.92;

    final allP  = candles.expand((c) => [c.high, c.low]).toList();
    final minP  = allP.reduce(math.min);
    final maxP  = allP.reduce(math.max);
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

      canvas.drawLine(
        Offset(cx, norm(c.high)), Offset(cx, norm(c.low)),
        Paint()..color = color.withOpacity(0.65)
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke,
      );

      final bTop = norm(c.bullish ? c.close : c.open);
      final bBot = norm(c.bullish ? c.open  : c.close);
      final bH   = (bBot - bTop).abs().clamp(2.5, double.infinity);

      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - bodyW / 2, bTop, bodyW, bH),
        const Radius.circular(3),
      );
      canvas.drawRRect(rr, Paint()..color = color.withOpacity(0.90));
      if (c.bullish) {
        canvas.drawRRect(rr.inflate(2.5), Paint()..color = color.withOpacity(0.12));
      }
    }
  }

  @override
  bool shouldRepaint(_FullCandlePainter o) =>
      o.candles != candles || o.chartBg != chartBg || o.chartGrid != chartGrid;
}

// ─── Glow Orb ─────────────────────────────────────────────────────────────────
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