import 'dart:convert';
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
  static const blue      = Color(0xFF1565C0);
  static const teal      = Color(0xFF26A69A);
  static const red       = Color(0xFFEF5350);
  static const textPrim  = Color(0xFFEEF2FF);
  static const textSub   = Color(0xFF7A8BA8);
  static const textMuted = Color(0xFF3D5470);
  static const inputFill = Color(0xFF0D1728);
  // Post button gradients
  static const buyGrad1  = Color(0xFF0D3320);
  static const buyGrad2  = Color(0xFF155229);
  static const sellGrad1 = Color(0xFF3D0808);
  static const sellGrad2 = Color(0xFF6B1111);
}

// ─── Light tokens ─────────────────────────────────────────────────────────────
class _Light {
  static const bg        = Color(0xFFF0F4FB);
  static const surface   = Color(0xFFFFFFFF);
  static const card      = Color(0xFFFFFFFF);
  static const border    = Color(0xFFDDE3EF);
  static const blue      = Color(0xFF1565C0);
  static const teal      = Color(0xFF1A8A80);
  static const red       = Color(0xFFD43F3C);
  static const textPrim  = Color(0xFF0D1728);
  static const textSub   = Color(0xFF64748B);
  static const textMuted = Color(0xFFADB5C7);
  static const inputFill = Color(0xFFF8FAFD);
  // Post button gradients
  static const buyGrad1  = Color(0xFF0D6B3A);
  static const buyGrad2  = Color(0xFF148048);
  static const sellGrad1 = Color(0xFF8B1A1A);
  static const sellGrad2 = Color(0xFFB02020);
}

// ─── Base URL ─────────────────────────────────────────────────────────────────
const _baseUrl = 'https://app.trading-ese.com/eseapi/Home';

// ─── Company Model ────────────────────────────────────────────────────────────
class _Company {
  final String code, fullName;
  final double lastPrice, currentPrice, changePercent, changeValue;
  final String trend;

  const _Company({
    required this.code,        required this.fullName,
    required this.lastPrice,   required this.currentPrice,
    required this.changePercent, required this.changeValue,
    required this.trend,
  });

  bool get positive => trend == 'UP' || changeValue >= 0;

  factory _Company.fromJson(Map<String, dynamic> j) => _Company(
    code:          j['company']        as String,
    fullName:      j['fullname']       as String,
    lastPrice:     (j['lastPrice']     as num).toDouble(),
    currentPrice:  (j['currentPrice']  as num).toDouble(),
    changePercent: (j['changePercent'] as num).toDouble(),
    changeValue:   (j['changeValue']   as num).toDouble(),
    trend:         j['trend']          as String? ?? 'FLAT',
  );
}

// ─── Broker Model ─────────────────────────────────────────────────────────────
class _Broker {
  final String id, companyCode, companyName;
  const _Broker({required this.id, required this.companyCode, required this.companyName});

  factory _Broker.fromJson(Map<String, dynamic> j) => _Broker(
    id:          j['id']          as String,
    companyCode: j['companyCode'] as String,
    companyName: j['companyName'] as String,
  );
}

// ─── Enums ────────────────────────────────────────────────────────────────────
enum _TradeType   { buy, sell }
enum _TimeInForce { day, gtc, ioc, fok }
enum _OrderType   { market, limit, stopLoss }

// ─── Trade Screen ─────────────────────────────────────────────────────────────
class TradeScreen extends StatefulWidget {
  final AppThemeNotifier themeNotifier;
  const TradeScreen({super.key, required this.themeNotifier});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  _TradeType   _tradeType  = _TradeType.buy;
  _TimeInForce _tif        = _TimeInForce.day;
  _OrderType   _orderType  = _OrderType.market;
  _Company?    _selected;
  _Broker?     _selectedBroker;

  final _qtyCtrl   = TextEditingController();
  final _priceCtrl = TextEditingController();

  bool   _companyOpen = false;
  bool   _tifOpen     = false;
  bool   _brokerOpen  = false;
  String _searchQuery = '';

  List<_Company> _companies = [];
  List<_Broker>  _brokers   = [];
  bool    _loadingCompanies = true;
  bool    _loadingBrokers   = true;
  String? _companiesError;
  String? _brokersError;

  String _sessionToken = '';
  String _cdsNumber    = '';
  String _clientName   = '';

  // ── Theme helpers ────────────────────────────────────────────────────────
  bool   get _isLight  => widget.themeNotifier.isLight;
  Color  get _bg       => _isLight ? _Light.bg        : _Dark.bg;
  Color  get _surface  => _isLight ? _Light.surface   : _Dark.surface;
  Color  get _card     => _isLight ? _Light.card      : _Dark.card;
  Color  get _border   => _isLight ? _Light.border    : _Dark.border;
  Color  get _teal     => _isLight ? _Light.teal      : _Dark.teal;
  Color  get _red      => _isLight ? _Light.red       : _Dark.red;
  Color  get _textPrim => _isLight ? _Light.textPrim  : _Dark.textPrim;
  Color  get _textSub  => _isLight ? _Light.textSub   : _Dark.textSub;
  Color  get _textMut  => _isLight ? _Light.textMuted : _Dark.textMuted;
  Color  get _inputFill=> _isLight ? _Light.inputFill : _Dark.inputFill;

  Color get _accent => _tradeType == _TradeType.buy ? _teal : _red;

  void _rebuild() => setState(() {});

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
    widget.themeNotifier.addListener(_rebuild);
    _loadSession();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    widget.themeNotifier.removeListener(_rebuild);
    super.dispose();
  }

  Future<void> _loadSession() async {
    final prefs   = await SharedPreferences.getInstance();
    _sessionToken = prefs.getString('session_token') ?? '';
    _cdsNumber    = prefs.getString('cds_number')    ?? '';
    _clientName   = prefs.getString('full_name')     ?? '';
    await Future.wait([_fetchMarketWatch(), _fetchBrokers()]);
  }

  Future<void> _fetchMarketWatch() async {
    setState(() { _loadingCompanies = true; _companiesError = null; });
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/MarketWatch'),
        headers: {'Authorization': 'Bearer $_sessionToken',
          'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = (data['securities'] as List<dynamic>)
            .map((e) => _Company.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() { _companies = list; _loadingCompanies = false; });
      } else {
        setState(() {
          _companiesError = 'Failed to load securities (${res.statusCode})';
          _loadingCompanies = false;
        });
      }
    } catch (e) {
      setState(() { _companiesError = 'Network error: $e'; _loadingCompanies = false; });
    }
  }

  Future<void> _fetchBrokers() async {
    setState(() { _loadingBrokers = true; _brokersError = null; });
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/Brokers'),
        headers: {'Authorization': 'Bearer $_sessionToken',
          'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = (data['brokers'] as List<dynamic>)
            .map((e) => _Broker.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() { _brokers = list; _loadingBrokers = false; });
      } else {
        setState(() {
          _brokersError = 'Failed to load brokers (${res.statusCode})';
          _loadingBrokers = false;
        });
      }
    } catch (e) {
      setState(() { _brokersError = 'Network error: $e'; _loadingBrokers = false; });
    }
  }

  double get _unitPrice => _orderType == _OrderType.market
      ? (_selected?.currentPrice ?? 0.0)
      : (double.tryParse(_priceCtrl.text) ?? (_selected?.currentPrice ?? 0.0));
  int    get _qty        => int.tryParse(_qtyCtrl.text) ?? 0;
  double get _estimated  => _unitPrice * _qty;
  double get _commission => _estimated * 0.0025;
  double get _grandTotal => _estimated + _commission;

  List<_Company> get _filtered => _searchQuery.isEmpty
      ? _companies
      : _companies.where((c) =>
  c.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      c.code.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

  String get _tifLabel {
    switch (_tif) {
      case _TimeInForce.day: return 'Day';
      case _TimeInForce.gtc: return 'Good Till Cancelled (GTC)';
      case _TimeInForce.ioc: return 'Immediate or Cancel (IOC)';
      case _TimeInForce.fok: return 'Fill or Kill (FOK)';
    }
  }

  String get _tifApiValue {
    switch (_tif) {
      case _TimeInForce.day: return 'DAY';
      case _TimeInForce.gtc: return 'GTC';
      case _TimeInForce.ioc: return 'IOC';
      case _TimeInForce.fok: return 'FOK';
    }
  }

  String get _orderAttributeApiValue {
    switch (_orderType) {
      case _OrderType.market:   return 'MARKET';
      case _OrderType.limit:    return 'LIMIT';
      case _OrderType.stopLoss: return 'STOPLOSS';
    }
  }

  String _generateBrokerRef() {
    final now = DateTime.now();
    return 'BREF-${now.year}${now.month.toString().padLeft(2,'0')}${now.day.toString().padLeft(2,'0')}-${now.millisecondsSinceEpoch % 100000}';
  }

  String _generateOrderNumber() {
    final now = DateTime.now();
    return 'ORD-${now.year}-${(now.millisecondsSinceEpoch % 100000).toString().padLeft(5,'0')}';
  }

  Future<void> _placeOrder(BuildContext context) async {
    if (_selected == null || _qty <= 0 || _selectedBroker == null) return;
    final body = {
      'OrderType':      _tradeType == _TradeType.buy ? 'BUY' : 'SELL',
      'Company':        _selected!.code,
      'BrokerCode':     _selectedBroker!.companyCode,
      'CDSNumber':      _cdsNumber,
      'ClientName':     _clientName,
      'Quantity':       _qty,
      'BasePrice':      _unitPrice,
      'OrderAttribute': _orderAttributeApiValue,
      'TimeInForce':    _tifApiValue,
      'BrokerRef':      _generateBrokerRef(),
      'OrderNumber':    _generateOrderNumber(),
      'Currency':       'SZL',
      'FOK':            _tif == _TimeInForce.fok,
      'NewType':        'NORMAL',
    };
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/PlaceOrder'),
        headers: {'Authorization': 'Bearer $_sessionToken',
          'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (!context.mounted) return;
      if (res.statusCode == 200 && data['responseCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: _accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          content: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(
              '${_tradeType == _TradeType.buy ? "Buy" : "Sell"} order placed for ${_selected!.code}  ·  #${data['OrderId']}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            )),
          ]),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(data['responseMessage']?.toString() ?? 'Order failed.',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: _red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text('Network error: $e',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ));
    }
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
              child: _GlowOrb(size: 220, color: _accent, opacity: 0.06)),
          Positioned(bottom: 120, left: -60,
              child: _GlowOrb(size: 180,
                  color: _isLight ? _Light.blue : _Dark.blue,
                  opacity: 0.06)),

          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _companyOpen = false;
                    _tifOpen     = false;
                    _brokerOpen  = false;
                  });
                  FocusScope.of(context).unfocus();
                },
                behavior: HitTestBehavior.translucent,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        kToolbarHeight + 8,
                    bottom: 110,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // ── Section header ──────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Row(children: [
                          Container(
                              width: 3, height: 18,
                              decoration: BoxDecoration(
                                  color: _accent,
                                  borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 10),
                          Text('Order Details',
                              style: TextStyle(fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: _textPrim, letterSpacing: -0.3)),
                        ]),
                      ),

                      // ── 1. Company ──────────────────────────────
                      _FieldCard(
                        label: 'Company', labelColor: _accent,
                        card: _card, border: _border, isLight: _isLight,
                        child: _loadingCompanies
                            ? _LoadingRow(textSub: _textSub)
                            : _companiesError != null
                            ? _ErrorRow(message: _companiesError!,
                            onRetry: _fetchMarketWatch,
                            red: _red, teal: _teal)
                            : _CompanyDropdown(
                          selected:    _selected,
                          filtered:    _filtered,
                          open:        _companyOpen,
                          searchQuery: _searchQuery,
                          accent:      _accent,
                          surface:     _surface,
                          border:      _border,
                          textPrim:    _textPrim,
                          textMuted:   _textMut,
                          textSub:     _textSub,
                          teal:        _teal,
                          red:         _red,
                          isLight:     _isLight,
                          onToggle: () => setState(() {
                            _companyOpen = !_companyOpen;
                            _tifOpen = false;
                            _brokerOpen = false;
                          }),
                          onSearch: (q) =>
                              setState(() => _searchQuery = q),
                          onSelect: (c) => setState(() {
                            _selected    = c;
                            _companyOpen = false;
                            _searchQuery = '';
                            if (_orderType == _OrderType.market) {
                              _priceCtrl.text =
                                  c.currentPrice.toStringAsFixed(2);
                            }
                          }),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── 2. Broker ───────────────────────────────
                      _FieldCard(
                        label: 'Broker', labelColor: _accent,
                        card: _card, border: _border, isLight: _isLight,
                        child: _loadingBrokers
                            ? _LoadingRow(textSub: _textSub)
                            : _brokersError != null
                            ? _ErrorRow(message: _brokersError!,
                            onRetry: _fetchBrokers,
                            red: _red, teal: _teal)
                            : _BrokerDropdown(
                          selected:     _selectedBroker,
                          brokers:      _brokers,
                          open:         _brokerOpen,
                          accent:       _accent,
                          border:       _border,
                          textPrim:     _textPrim,
                          textMuted:    _textMut,
                          textSub:      _textSub,
                          onToggle: () => setState(() {
                            _brokerOpen  = !_brokerOpen;
                            _companyOpen = false;
                            _tifOpen     = false;
                          }),
                          onSelect: (b) => setState(() {
                            _selectedBroker = b;
                            _brokerOpen     = false;
                          }),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── 3. Order Time ───────────────────────────
                      _FieldCard(
                        label: 'Order Time', labelColor: _accent,
                        card: _card, border: _border, isLight: _isLight,
                        child: _TifDropdown(
                          tif:      _tif,
                          tifLabel: _tifLabel,
                          open:     _tifOpen,
                          accent:   _accent,
                          border:   _border,
                          textPrim: _textPrim,
                          textSub:  _textSub,
                          onToggle: () => setState(() {
                            _tifOpen     = !_tifOpen;
                            _companyOpen = false;
                            _brokerOpen  = false;
                          }),
                          onSelect: (t) => setState(() {
                            _tif     = t;
                            _tifOpen = false;
                          }),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── 4. Order Type ───────────────────────────
                      _FieldCard(
                        label: 'Order Type', labelColor: _accent,
                        card: _card, border: _border, isLight: _isLight,
                        child: Row(
                          children: [
                            (_OrderType.market,   'Market',    Icons.flash_on_rounded),
                            (_OrderType.limit,    'Limit',     Icons.tune_rounded),
                            (_OrderType.stopLoss, 'Stop Loss', Icons.shield_outlined),
                          ].map((t) {
                            final active = _orderType == t.$1;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _orderType = t.$1;
                                  if (t.$1 == _OrderType.market && _selected != null) {
                                    _priceCtrl.text =
                                        _selected!.currentPrice.toStringAsFixed(2);
                                  } else if (t.$1 != _OrderType.market) {
                                    _priceCtrl.clear();
                                  }
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.only(
                                      right: t.$1 != _OrderType.stopLoss ? 8 : 0),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? _accent.withOpacity(0.12)
                                        : _surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: active
                                          ? _accent.withOpacity(0.35)
                                          : _border,
                                      width: 1,
                                    ),
                                    boxShadow: active && _isLight ? [BoxShadow(
                                        color: _accent.withOpacity(0.12),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2))] : [],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(t.$3,
                                          color: active ? _accent : _textMut,
                                          size: 16),
                                      const SizedBox(height: 4),
                                      Text(t.$2,
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: active
                                                  ? FontWeight.w700
                                                  : FontWeight.w400,
                                              color: active ? _accent : _textSub)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── 5. Order Side ───────────────────────────
                      _FieldCard(
                        label: 'Order Side', labelColor: _accent,
                        card: _card, border: _border, isLight: _isLight,
                        child: Row(children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _tradeType = _TradeType.buy),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _tradeType == _TradeType.buy
                                      ? _teal.withOpacity(0.14)
                                      : _surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _tradeType == _TradeType.buy
                                        ? _teal.withOpacity(0.45)
                                        : _border,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.trending_up_rounded,
                                        color: _tradeType == _TradeType.buy
                                            ? _teal : _textMut,
                                        size: 18),
                                    const SizedBox(width: 8),
                                    Text('BUY',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: _tradeType == _TradeType.buy
                                                ? _teal : _textMut,
                                            letterSpacing: 1)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _tradeType = _TradeType.sell),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _tradeType == _TradeType.sell
                                      ? _red.withOpacity(0.14)
                                      : _surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _tradeType == _TradeType.sell
                                        ? _red.withOpacity(0.45)
                                        : _border,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.trending_down_rounded,
                                        color: _tradeType == _TradeType.sell
                                            ? _red : _textMut,
                                        size: 18),
                                    const SizedBox(width: 8),
                                    Text('SELL',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: _tradeType == _TradeType.sell
                                                ? _red : _textMut,
                                            letterSpacing: 1)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),

                      const SizedBox(height: 10),

                      // ── 6. Quantity ─────────────────────────────
                      _FieldCard(
                        label: 'Quantity', labelColor: _accent,
                        card: _card, border: _border, isLight: _isLight,
                        child: _InlineInput(
                          controller: _qtyCtrl,
                          hint: 'Enter quantity',
                          inputType: TextInputType.number,
                          suffix: 'shares',
                          textPrim: _textPrim,
                          textSub: _textSub,
                          textMuted: _textMut,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── 7. Price ────────────────────────────────
                      _FieldCard(
                        label: 'Price', labelColor: _accent,
                        card: _card, border: _border, isLight: _isLight,
                        child: _InlineInput(
                          controller: _priceCtrl,
                          hint: _orderType == _OrderType.market
                              ? 'Market price' : 'Enter price',
                          inputType: const TextInputType.numberWithOptions(
                              decimal: true),
                          prefix: 'E',
                          readOnly: _orderType == _OrderType.market,
                          textPrim: _textPrim,
                          textSub: _textSub,
                          textMuted: _textMut,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),

                      // ── Order summary ───────────────────────────
                      if (_selected != null && _qty > 0) ...[
                        const SizedBox(height: 10),
                        _SummaryCard(
                          company:    _selected!,
                          broker:     _selectedBroker,
                          qty:        _qty,
                          unitPrice:  _unitPrice,
                          estimated:  _estimated,
                          commission: _commission,
                          grandTotal: _grandTotal,
                          tradeType:  _tradeType,
                          accent:     _accent,
                          card:       _card,
                          border:     _border,
                          textPrim:   _textPrim,
                          textSub:    _textSub,
                          isLight:    _isLight,
                        ),
                      ],

                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Orders processed during ESE market hours  ·  Mon–Fri  09:00–15:30 SAST',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 9.5,
                              color: _textMut, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),

        bottomNavigationBar: _PostButton(
          tradeType: _tradeType,
          accent:    _accent,
          surface:   _surface,
          border:    _border,
          textMuted: _textMut,
          isLight:   _isLight,
          enabled:   _selected != null && _selectedBroker != null && _qty > 0,
          onTap:     () => _confirmOrder(context),
        ),
      ),
    );
  }

  void _confirmOrder(BuildContext context) {
    if (_selected == null || _selectedBroker == null || _qty <= 0) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ConfirmSheet(
        company:    _selected!,
        broker:     _selectedBroker!,
        tradeType:  _tradeType,
        orderType:  _orderType,
        tif:        _tif,
        qty:        _qty,
        grandTotal: _grandTotal,
        accent:     _accent,
        surface:    _surface,
        card:       _card,
        border:     _border,
        textPrim:   _textPrim,
        textSub:    _textSub,
        isLight:    _isLight,
        onConfirm:  () async {
          Navigator.pop(context);
          await _placeOrder(context);
        },
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
              color: _bg.withOpacity(_isLight ? 0.85 : 0.65),
              border: Border(
                  bottom: BorderSide(color: _border.withOpacity(0.5))),
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
              title: Text('Post Order',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                      color: _textPrim, letterSpacing: 0.2)),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Company Dropdown ─────────────────────────────────────────────────────────
class _CompanyDropdown extends StatelessWidget {
  final _Company? selected;
  final List<_Company> filtered;
  final bool    open;
  final String  searchQuery;
  final Color   accent, surface, border, textPrim, textMuted, textSub, teal, red;
  final bool    isLight;
  final VoidCallback onToggle;
  final ValueChanged<String> onSearch;
  final ValueChanged<_Company> onSelect;

  const _CompanyDropdown({
    required this.selected,   required this.filtered,
    required this.open,       required this.searchQuery,
    required this.accent,     required this.surface,
    required this.border,     required this.textPrim,
    required this.textMuted,  required this.textSub,
    required this.teal,       required this.red,
    required this.isLight,    required this.onToggle,
    required this.onSearch,   required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: onToggle,
        child: Row(children: [
          Expanded(child: Text(
            selected?.fullName ?? 'Please Select',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                color: selected == null ? textMuted : textPrim),
          )),
          AnimatedRotation(
            turns: open ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(Icons.keyboard_arrow_down_rounded, color: accent, size: 22),
          ),
        ]),
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: open ? Column(children: [
          const SizedBox(height: 12),
          Container(height: 1, color: border),
          const SizedBox(height: 10),
          // Search
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
              boxShadow: isLight ? [BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6, offset: const Offset(0, 2))] : [],
            ),
            child: Row(children: [
              Padding(padding: const EdgeInsets.only(left: 10),
                  child: Icon(Icons.search_rounded, color: textMuted, size: 16)),
              Expanded(child: TextField(
                autofocus: true,
                onChanged: onSearch,
                style: TextStyle(fontSize: 13, color: textPrim),
                decoration: InputDecoration(
                  hintText: 'Search…',
                  hintStyle: TextStyle(fontSize: 13, color: textMuted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              )),
            ]),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final c   = filtered[i];
                final sel = c.code == (selected?.code ?? '');
                return GestureDetector(
                  onTap: () => onSelect(c),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? accent.withOpacity(0.10) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: sel ? accent.withOpacity(0.28) : Colors.transparent),
                    ),
                    child: Row(children: [
                      Container(
                        width: 52,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: border),
                        ),
                        child: Text(c.code,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: sel ? accent : textSub,
                                letterSpacing: 0.4)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(c.fullName,
                          style: TextStyle(fontSize: 12.5,
                              fontWeight: FontWeight.w600, color: textPrim),
                          overflow: TextOverflow.ellipsis)),
                      Column(crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('E ${c.currentPrice.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 12.5,
                                    fontWeight: FontWeight.w700, color: textPrim)),
                            Text(
                              '${c.positive ? '+' : ''}${c.changePercent.toStringAsFixed(2)}%',
                              style: TextStyle(fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: c.positive ? teal : red),
                            ),
                          ]),
                    ]),
                  ),
                );
              },
            ),
          ),
        ]) : const SizedBox.shrink(),
      ),
    ]);
  }
}

// ─── Broker Dropdown ──────────────────────────────────────────────────────────
class _BrokerDropdown extends StatelessWidget {
  final _Broker? selected;
  final List<_Broker> brokers;
  final bool  open;
  final Color accent, border, textPrim, textMuted, textSub;
  final VoidCallback onToggle;
  final ValueChanged<_Broker> onSelect;

  const _BrokerDropdown({
    required this.selected, required this.brokers, required this.open,
    required this.accent,   required this.border,  required this.textPrim,
    required this.textMuted, required this.textSub,
    required this.onToggle, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: onToggle,
        behavior: HitTestBehavior.opaque,
        child: Row(children: [
          Expanded(child: Text(
            selected?.companyName ?? 'Please Select',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                color: selected == null ? textMuted : textPrim),
          )),
          AnimatedRotation(
            turns: open ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(Icons.keyboard_arrow_down_rounded, color: accent, size: 22),
          ),
        ]),
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: open ? Column(children: [
          const SizedBox(height: 12),
          Container(height: 1, color: border),
          const SizedBox(height: 8),
          ...brokers.map((b) {
            final active = selected?.companyCode == b.companyCode;
            return GestureDetector(
              onTap: () => onSelect(b),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? accent.withOpacity(0.10) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: active ? accent.withOpacity(0.28) : Colors.transparent),
                ),
                child: Row(children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.companyName,
                          style: TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: active ? accent : textPrim)),
                      Text(b.companyCode,
                          style: TextStyle(fontSize: 10, color: textSub)),
                    ],
                  )),
                  if (active)
                    Icon(Icons.check_circle_rounded, color: accent, size: 18),
                ]),
              ),
            );
          }),
        ]) : const SizedBox.shrink(),
      ),
    ]);
  }
}

// ─── TIF Dropdown ─────────────────────────────────────────────────────────────
class _TifDropdown extends StatelessWidget {
  final _TimeInForce tif;
  final String tifLabel;
  final bool   open;
  final Color  accent, border, textPrim, textSub;
  final VoidCallback onToggle;
  final ValueChanged<_TimeInForce> onSelect;

  const _TifDropdown({
    required this.tif, required this.tifLabel, required this.open,
    required this.accent, required this.border,
    required this.textPrim, required this.textSub,
    required this.onToggle, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(tifLabel,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                  color: textPrim))),
          AnimatedRotation(
            turns: open ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(Icons.keyboard_arrow_down_rounded, color: accent, size: 22),
          ),
        ]),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: open ? Column(children: [
            const SizedBox(height: 12),
            Container(height: 1, color: border),
            const SizedBox(height: 8),
            ...[
              (_TimeInForce.day, 'Day',               'Order expires at end of trading day'),
              (_TimeInForce.gtc, 'Good Till Cancelled','Order stays open until cancelled'),
              (_TimeInForce.ioc, 'Immediate or Cancel','Fill immediately or cancel'),
              (_TimeInForce.fok, 'Fill or Kill',       'Fill entire order or cancel'),
            ].map((t) {
              final active = tif == t.$1;
              return GestureDetector(
                onTap: () => onSelect(t.$1),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? accent.withOpacity(0.10) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: active ? accent.withOpacity(0.28) : Colors.transparent),
                  ),
                  child: Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.$2,
                            style: TextStyle(fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: active ? accent : textPrim)),
                        Text(t.$3,
                            style: TextStyle(fontSize: 10, color: textSub)),
                      ],
                    )),
                    if (active)
                      Icon(Icons.check_circle_rounded, color: accent, size: 18),
                  ]),
                ),
              );
            }),
          ]) : const SizedBox.shrink(),
        ),
      ]),
    );
  }
}

// ─── Loading Row ──────────────────────────────────────────────────────────────
class _LoadingRow extends StatelessWidget {
  final Color textSub;
  const _LoadingRow({required this.textSub});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 14, height: 14,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: textSub)),
      const SizedBox(width: 10),
      Text('Loading…', style: TextStyle(fontSize: 13, color: textSub)),
    ]);
  }
}

// ─── Error Row ────────────────────────────────────────────────────────────────
class _ErrorRow extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Color red, teal;
  const _ErrorRow({required this.message, required this.onRetry,
    required this.red, required this.teal});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(Icons.error_outline_rounded, color: red, size: 15),
      const SizedBox(width: 8),
      Expanded(child: Text(message,
          style: TextStyle(fontSize: 12, color: red))),
      GestureDetector(
        onTap: onRetry,
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text('Retry', style: TextStyle(fontSize: 12,
              color: teal, fontWeight: FontWeight.w600)),
        ),
      ),
    ]);
  }
}

// ─── Field Card ───────────────────────────────────────────────────────────────
class _FieldCard extends StatelessWidget {
  final String label;
  final Color  labelColor, card, border;
  final bool   isLight;
  final Widget child;

  const _FieldCard({
    required this.label, required this.labelColor,
    required this.card,  required this.border,
    required this.isLight, required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isLight ? 0.06 : 0.18),
              blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700,
                  color: labelColor, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ─── Inline Input ─────────────────────────────────────────────────────────────
class _InlineInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType inputType;
  final String? prefix, suffix;
  final bool    readOnly;
  final Color   textPrim, textSub, textMuted;
  final ValueChanged<String>? onChanged;

  const _InlineInput({
    required this.controller, required this.hint, required this.inputType,
    required this.textPrim, required this.textSub, required this.textMuted,
    this.prefix, this.suffix, this.readOnly = false, this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      if (prefix != null) ...[
        Text(prefix!, style: TextStyle(fontSize: 15,
            fontWeight: FontWeight.w700, color: textSub)),
        const SizedBox(width: 8),
      ],
      Expanded(
        child: TextField(
          controller: controller,
          keyboardType: inputType,
          readOnly: readOnly,
          onChanged: onChanged,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              color: readOnly ? textSub : textPrim),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 15, color: textMuted,
                fontWeight: FontWeight.w400),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
      if (suffix != null) ...[
        const SizedBox(width: 8),
        Text(suffix!, style: TextStyle(fontSize: 11,
            color: textSub, fontWeight: FontWeight.w500)),
      ],
    ]);
  }
}

// ─── Order Summary Card ───────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final _Company company;
  final _Broker? broker;
  final int      qty;
  final double   unitPrice, estimated, commission, grandTotal;
  final _TradeType tradeType;
  final Color    accent, card, border, textPrim, textSub;
  final bool     isLight;

  const _SummaryCard({
    required this.company,    required this.broker,
    required this.qty,        required this.unitPrice,
    required this.estimated,  required this.commission,
    required this.grandTotal, required this.tradeType,
    required this.accent,     required this.card,
    required this.border,     required this.textPrim,
    required this.textSub,    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.22), width: 1),
        boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.06),
            blurRadius: 10, offset: const Offset(0, 3))] : [],
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 10),
          child: Row(children: [
            Container(width: 3, height: 14,
                decoration: BoxDecoration(color: accent,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text('Order Summary', style: TextStyle(fontSize: 11,
                fontWeight: FontWeight.w700, color: accent, letterSpacing: 0.4)),
          ]),
        ),
        Container(height: 1, color: border),
        _SumRow('Company', company.code,
            textPrim: textPrim, textSub: textSub),
        if (broker != null)
          _SumRow('Broker', broker!.companyName,
              textPrim: textPrim, textSub: textSub),
        _SumRow('Action',
            tradeType == _TradeType.buy ? 'BUY' : 'SELL',
            valueColor: accent, textPrim: textPrim, textSub: textSub),
        _SumRow('Qty', '$qty share${qty != 1 ? "s" : ""}',
            textPrim: textPrim, textSub: textSub),
        _SumRow('Price / Share', 'E ${unitPrice.toStringAsFixed(2)}',
            textPrim: textPrim, textSub: textSub),
        _SumRow('Subtotal', 'E ${estimated.toStringAsFixed(2)}',
            textPrim: textPrim, textSub: textSub),
        _SumRow('Commission (0.25%)', 'E ${commission.toStringAsFixed(2)}',
            valueColor: textSub, textPrim: textPrim, textSub: textSub),
        Container(height: 1, color: border,
            margin: const EdgeInsets.symmetric(horizontal: 16)),
        _SumRow('Total', 'E ${grandTotal.toStringAsFixed(2)}',
            valueColor: accent, bold: true, last: true,
            textPrim: textPrim, textSub: textSub),
      ]),
    );
  }
}

class _SumRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final Color  textPrim, textSub;
  final bool   bold, last;

  const _SumRow(this.label, this.value, {
    this.valueColor, required this.textPrim, required this.textSub,
    this.bold = false, this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, last ? 11 : 9, 16, last ? 11 : 9),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 12, color: textSub,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
        Text(value, style: TextStyle(
            fontSize: bold ? 14.5 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? textPrim,
            letterSpacing: bold ? -0.3 : 0)),
      ]),
    );
  }
}

// ─── Sticky POST Button ───────────────────────────────────────────────────────
class _PostButton extends StatelessWidget {
  final _TradeType tradeType;
  final Color  accent, surface, border, textMuted;
  final bool   enabled, isLight;
  final VoidCallback onTap;

  const _PostButton({
    required this.tradeType, required this.accent,
    required this.surface,   required this.border,
    required this.textMuted, required this.enabled,
    required this.isLight,   required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final buyG1  = isLight ? _Light.buyGrad1  : _Dark.buyGrad1;
    final buyG2  = isLight ? _Light.buyGrad2  : _Dark.buyGrad2;
    final sellG1 = isLight ? _Light.sellGrad1 : _Dark.sellGrad1;
    final sellG2 = isLight ? _Light.sellGrad2 : _Dark.sellGrad2;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 14),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: enabled
                  ? tradeType == _TradeType.buy
                  ? [buyG1, buyG2]
                  : [sellG1, sellG2]
                  : [surface, surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: enabled ? accent.withOpacity(0.50) : border,
              width: 1,
            ),
            boxShadow: enabled
                ? [BoxShadow(color: accent.withOpacity(0.28),
                blurRadius: 18, offset: const Offset(0, 6))]
                : [],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
              tradeType == _TradeType.buy
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: enabled ? Colors.white : textMuted,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              tradeType == _TradeType.buy ? 'POST BUY ORDER' : 'POST SELL ORDER',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                  color: enabled ? Colors.white : textMuted,
                  letterSpacing: 1.5),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Confirm Bottom Sheet ─────────────────────────────────────────────────────
class _ConfirmSheet extends StatelessWidget {
  final _Company     company;
  final _Broker      broker;
  final _TradeType   tradeType;
  final _OrderType   orderType;
  final _TimeInForce tif;
  final int          qty;
  final double       grandTotal;
  final Color        accent, surface, card, border, textPrim, textSub;
  final bool         isLight;
  final VoidCallback onConfirm;

  const _ConfirmSheet({
    required this.company,   required this.broker,
    required this.tradeType, required this.orderType,
    required this.tif,       required this.qty,
    required this.grandTotal, required this.accent,
    required this.surface,   required this.card,
    required this.border,    required this.textPrim,
    required this.textSub,   required this.isLight,
    required this.onConfirm,
  });

  String get _orderTypeLabel {
    switch (orderType) {
      case _OrderType.market:   return 'Market Order';
      case _OrderType.limit:    return 'Limit Order';
      case _OrderType.stopLoss: return 'Stop Loss Order';
    }
  }

  @override
  Widget build(BuildContext context) {
    final buyG1  = isLight ? _Light.buyGrad1  : _Dark.buyGrad1;
    final buyG2  = isLight ? _Light.buyGrad2  : _Dark.buyGrad2;
    final sellG1 = isLight ? _Light.sellGrad1 : _Dark.sellGrad1;
    final sellG2 = isLight ? _Light.sellGrad2 : _Dark.sellGrad2;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.10 : 0.30),
            blurRadius: 24, offset: const Offset(0, -4))],
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: border,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withOpacity(0.12),
            border: Border.all(color: accent.withOpacity(0.30), width: 1.5),
          ),
          child: Icon(
            tradeType == _TradeType.buy
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: accent, size: 26,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Confirm ${tradeType == _TradeType.buy ? "Buy" : "Sell"} Order',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
              color: textPrim),
        ),
        const SizedBox(height: 4),
        Text(_orderTypeLabel,
            style: TextStyle(fontSize: 12, color: textSub)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1),
            boxShadow: isLight ? [BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8, offset: const Offset(0, 2))] : [],
          ),
          child: Column(children: [
            _SheetRow(label: 'Company',
                value: '${company.fullName} (${company.code})',
                textPrim: textPrim, textSub: textSub),
            const SizedBox(height: 10),
            _SheetRow(label: 'Broker', value: broker.companyName,
                textPrim: textPrim, textSub: textSub),
            const SizedBox(height: 10),
            _SheetRow(label: 'Shares',
                value: '$qty share${qty != 1 ? "s" : ""}',
                textPrim: textPrim, textSub: textSub),
            const SizedBox(height: 10),
            _SheetRow(label: 'Total Amount',
                value: 'E ${grandTotal.toStringAsFixed(2)}',
                bold: true, valueColor: accent,
                textPrim: textPrim, textSub: textSub),
          ]),
        ),
        const SizedBox(height: 22),
        GestureDetector(
          onTap: onConfirm,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: tradeType == _TradeType.buy
                    ? [buyG1, buyG2]
                    : [sellG1, sellG2],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withOpacity(0.45), width: 1),
              boxShadow: [BoxShadow(color: accent.withOpacity(0.28),
                  blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Center(child: Text('Confirm & Post Order',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                    color: Colors.white, letterSpacing: 0.3))),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text('Cancel',
              style: TextStyle(fontSize: 13, color: textSub,
                  fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final String label, value;
  final bool   bold;
  final Color? valueColor;
  final Color  textPrim, textSub;

  const _SheetRow({required this.label, required this.value,
    required this.textPrim, required this.textSub,
    this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 12, color: textSub)),
      Flexible(child: Text(value, textAlign: TextAlign.end,
          style: TextStyle(fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? textPrim))),
    ]);
  }
}

// ─── Glow Orb ─────────────────────────────────────────────────────────────────
class _GlowOrb extends StatelessWidget {
  final double size, opacity;
  final Color  color;
  const _GlowOrb({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
            colors: [color.withOpacity(opacity), Colors.transparent]),
      ),
    );
  }
}