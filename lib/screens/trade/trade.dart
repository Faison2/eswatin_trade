import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static const textPrim  = Color(0xFFEEF2FF);
  static const textSub   = Color(0xFF7A8BA8);
  static const textMuted = Color(0xFF3D5470);
}

// ─── Company Model ────────────────────────────────────────────────────────────
class _Company {
  final String ticker, name, sector;
  final double price, change, changePercent;
  final bool positive;
  const _Company({
    required this.ticker, required this.name, required this.sector,
    required this.price, required this.change,
    required this.changePercent, required this.positive,
  });
}

const List<_Company> _companies = [
  _Company(ticker:'CBEET',  name:'Commercial Bank of Ethiopia',
      sector:'Banking',   price:42.50, change:1.20,  changePercent:2.91,  positive:true),
  _Company(ticker:'AWBET',  name:'Awash Bank',
      sector:'Banking',   price:38.75, change:-0.45, changePercent:1.15,  positive:false),
  _Company(ticker:'DASHET', name:'Dashen Bank',
      sector:'Banking',   price:35.20, change:0.80,  changePercent:2.32,  positive:true),
  _Company(ticker:'ABYET',  name:'Abyssinia Bank',
      sector:'Banking',   price:29.60, change:-0.30, changePercent:1.00,  positive:false),
  _Company(ticker:'NBET',   name:'Nib Bank',
      sector:'Banking',   price:24.10, change:0.55,  changePercent:2.33,  positive:true),
  _Company(ticker:'ETHINS', name:'Ethiopian Insurance',
      sector:'Insurance', price:18.90, change:0.10,  changePercent:0.53,  positive:true),
  _Company(ticker:'AWINS',  name:'Awash Insurance',
      sector:'Insurance', price:15.40, change:-0.20, changePercent:1.28,  positive:false),
  _Company(ticker:'ETBREW', name:'Ethiopian Breweries',
      sector:'FMCG',      price:55.00, change:2.50,  changePercent:4.76,  positive:true),
  _Company(ticker:'MBET',   name:'Meta Abo Brewery',
      sector:'FMCG',      price:46.30, change:-1.10, changePercent:2.32,  positive:false),
  _Company(ticker:'ETTEL',  name:'Ethio Telecom',
      sector:'Telecom',   price:88.00, change:3.00,  changePercent:3.53,  positive:true),
];

// ─── Enums ────────────────────────────────────────────────────────────────────
enum _TradeType { buy, sell }
enum _TimeInForce { day, gtc, ioc, fok }
enum _OrderType  { market, limit, stopLoss }

// ─── Trade Screen ─────────────────────────────────────────────────────────────
class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});
  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset>  _slide;

  _TradeType    _tradeType   = _TradeType.buy;
  _TimeInForce  _tif         = _TimeInForce.day;
  _OrderType    _orderType   = _OrderType.market;
  _Company?     _selected;

  final _qtyCtrl   = TextEditingController();
  final _priceCtrl = TextEditingController();

  bool _companyOpen = false;
  bool _tifOpen     = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Color get _accent => _tradeType == _TradeType.buy ? _C.teal : _C.red;

  double get _unitPrice =>
      _orderType == _OrderType.market
          ? (_selected?.price ?? 0.0)
          : (double.tryParse(_priceCtrl.text) ?? (_selected?.price ?? 0.0));
  int    get _qty        => int.tryParse(_qtyCtrl.text)  ?? 0;
  double get _estimated  => _unitPrice * _qty;
  double get _commission => _estimated  * 0.0025;
  double get _grandTotal => _estimated  + _commission;

  List<_Company> get _filtered => _searchQuery.isEmpty
      ? _companies
      : _companies.where((c) =>
  c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      c.ticker.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

  String get _tifLabel {
    switch (_tif) {
      case _TimeInForce.day: return 'Day';
      case _TimeInForce.gtc: return 'Good Till Cancelled (GTC)';
      case _TimeInForce.ioc: return 'Immediate or Cancel (IOC)';
      case _TimeInForce.fok: return 'Fill or Kill (FOK)';
    }
  }

  String get _orderTypeLabel {
    switch (_orderType) {
      case _OrderType.market:   return 'Market';
      case _OrderType.limit:    return 'Limit';
      case _OrderType.stopLoss: return 'Stop Loss';
    }
  }

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
      body: Stack(children: [
        Positioned(top: -40, right: -60,
            child: _GlowOrb(size: 220, color: _accent, opacity: 0.06)),
        Positioned(bottom: 120, left: -60,
            child: _GlowOrb(size: 180, color: _C.blue, opacity: 0.06)),

        FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: GestureDetector(
              onTap: () {
                setState(() { _companyOpen = false; _tifOpen = false; });
                FocusScope.of(context).unfocus();
              },
              behavior: HitTestBehavior.translucent,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
                  bottom: 110,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // ── Section header ────────────────────────────────
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
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _C.textPrim,
                                letterSpacing: -0.3)),
                      ]),
                    ),

                    // ── 1. Company ────────────────────────────────────
                    _FieldCard(
                      label: 'Company',
                      labelColor: _accent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() {
                              _companyOpen = !_companyOpen;
                              _tifOpen = false;
                            }),
                            child: Row(children: [
                              Expanded(
                                child: Text(
                                  _selected?.name ?? 'Please Select',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _selected == null
                                          ? _C.textMuted : _C.textPrim),
                                ),
                              ),
                              AnimatedRotation(
                                turns: _companyOpen ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: _accent, size: 22),
                              ),
                            ]),
                          ),

                          // Dropdown
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            child: _companyOpen
                                ? Column(children: [
                              const SizedBox(height: 12),
                              Container(
                                height: 1,
                                color: _C.border,
                              ),
                              const SizedBox(height: 10),
                              // Search
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _C.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _C.border),
                                ),
                                child: Row(children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Icon(Icons.search_rounded,
                                        color: _C.textMuted, size: 16),
                                  ),
                                  Expanded(child: TextField(
                                    autofocus: true,
                                    onChanged: (q) =>
                                        setState(() => _searchQuery = q),
                                    style: const TextStyle(
                                        fontSize: 13, color: _C.textPrim),
                                    decoration: InputDecoration(
                                      hintText: 'Search…',
                                      hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: _C.textMuted),
                                      border: InputBorder.none,
                                      contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10),
                                    ),
                                  )),
                                ]),
                              ),
                              const SizedBox(height: 8),
                              ConstrainedBox(
                                constraints:
                                const BoxConstraints(maxHeight: 260),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _filtered.length,
                                  itemBuilder: (_, i) {
                                    final c = _filtered[i];
                                    final sel = c.ticker ==
                                        (_selected?.ticker ?? '');
                                    return GestureDetector(
                                      onTap: () => setState(() {
                                        _selected = c;
                                        _companyOpen = false;
                                        _searchQuery = '';
                                        if (_orderType ==
                                            _OrderType.market) {
                                          _priceCtrl.text =
                                              c.price.toStringAsFixed(2);
                                        }
                                      }),
                                      behavior: HitTestBehavior.opaque,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 150),
                                        margin: const EdgeInsets.only(
                                            bottom: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: sel
                                              ? _accent.withOpacity(0.10)
                                              : Colors.transparent,
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          border: Border.all(
                                            color: sel
                                                ? _accent.withOpacity(0.28)
                                                : Colors.transparent,
                                          ),
                                        ),
                                        child: Row(children: [
                                          Container(
                                            width: 48,
                                            padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _C.surface,
                                              borderRadius:
                                              BorderRadius.circular(6),
                                              border: Border.all(
                                                  color: _C.border),
                                            ),
                                            child: Text(c.ticker,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight:
                                                    FontWeight.w800,
                                                    color: sel
                                                        ? _accent
                                                        : _C.textSub,
                                                    letterSpacing: 0.4)),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(c.name,
                                                    style: const TextStyle(
                                                        fontSize: 12.5,
                                                        fontWeight:
                                                        FontWeight.w600,
                                                        color: _C.textPrim),
                                                    overflow:
                                                    TextOverflow.ellipsis),
                                                Text(c.sector,
                                                    style: const TextStyle(
                                                        fontSize: 9.5,
                                                        color: _C.textSub)),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                  'E ${c.price.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                      FontWeight.w700,
                                                      color: _C.textPrim)),
                                              Text(
                                                '${c.positive ? '+' : ''}${c.changePercent.toStringAsFixed(2)}%',
                                                style: TextStyle(
                                                    fontSize: 9.5,
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    color: c.positive
                                                        ? _C.teal
                                                        : _C.red),
                                              ),
                                            ],
                                          ),
                                        ]),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ])
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── 2. Order Time (Time in Force) ─────────────────
                    _FieldCard(
                      label: 'Order Time',
                      labelColor: _accent,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _tifOpen = !_tifOpen;
                          _companyOpen = false;
                        }),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                child: Text(_tifLabel,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: _C.textPrim)),
                              ),
                              AnimatedRotation(
                                turns: _tifOpen ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: _accent, size: 22),
                              ),
                            ]),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              child: _tifOpen
                                  ? Column(children: [
                                const SizedBox(height: 12),
                                Container(height: 1, color: _C.border),
                                const SizedBox(height: 8),
                                ...[
                                  (_TimeInForce.day, 'Day',
                                  'Order expires at end of trading day'),
                                  (_TimeInForce.gtc, 'Good Till Cancelled',
                                  'Order stays open until cancelled'),
                                  (_TimeInForce.ioc, 'Immediate or Cancel',
                                  'Fill immediately or cancel'),
                                  (_TimeInForce.fok, 'Fill or Kill',
                                  'Fill entire order or cancel'),
                                ].map((t) {
                                  final active = _tif == t.$1;
                                  return GestureDetector(
                                    onTap: () => setState(() {
                                      _tif = t.$1;
                                      _tifOpen = false;
                                    }),
                                    behavior: HitTestBehavior.opaque,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 150),
                                      margin: const EdgeInsets.only(
                                          bottom: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: active
                                            ? _accent.withOpacity(0.10)
                                            : Colors.transparent,
                                        borderRadius:
                                        BorderRadius.circular(10),
                                        border: Border.all(
                                          color: active
                                              ? _accent.withOpacity(0.28)
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Row(children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(t.$2,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      color: active
                                                          ? _accent
                                                          : _C.textPrim)),
                                              Text(t.$3,
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: _C.textSub)),
                                            ],
                                          ),
                                        ),
                                        if (active)
                                          Icon(Icons.check_circle_rounded,
                                              color: _accent, size: 18),
                                      ]),
                                    ),
                                  );
                                }),
                              ])
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── 3. Order Type ─────────────────────────────────
                    _FieldCard(
                      label: 'Order Type',
                      labelColor: _accent,
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
                                if (t.$1 == _OrderType.market &&
                                    _selected != null) {
                                  _priceCtrl.text =
                                      _selected!.price.toStringAsFixed(2);
                                } else if (t.$1 != _OrderType.market) {
                                  _priceCtrl.clear();
                                }
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(
                                    right: t.$1 != _OrderType.stopLoss
                                        ? 8 : 0),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                decoration: BoxDecoration(
                                  color: active
                                      ? _accent.withOpacity(0.12)
                                      : _C.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: active
                                        ? _accent.withOpacity(0.35)
                                        : _C.border,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(t.$3,
                                        color: active
                                            ? _accent : _C.textMuted,
                                        size: 16),
                                    const SizedBox(height: 4),
                                    Text(t.$2,
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: active
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                            color: active
                                                ? _accent : _C.textSub)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── 4. Buy / Sell (Order Side) ────────────────────
                    _FieldCard(
                      label: 'Order Side',
                      labelColor: _accent,
                      child: Row(children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                                    () => _tradeType = _TradeType.buy),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              decoration: BoxDecoration(
                                color: _tradeType == _TradeType.buy
                                    ? _C.teal.withOpacity(0.14)
                                    : _C.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _tradeType == _TradeType.buy
                                      ? _C.teal.withOpacity(0.45)
                                      : _C.border,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.trending_up_rounded,
                                        color: _tradeType == _TradeType.buy
                                            ? _C.teal : _C.textMuted,
                                        size: 18),
                                    const SizedBox(width: 8),
                                    Text('BUY',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color:
                                            _tradeType == _TradeType.buy
                                                ? _C.teal
                                                : _C.textMuted,
                                            letterSpacing: 1)),
                                  ]),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                                    () => _tradeType = _TradeType.sell),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              decoration: BoxDecoration(
                                color: _tradeType == _TradeType.sell
                                    ? _C.red.withOpacity(0.14)
                                    : _C.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _tradeType == _TradeType.sell
                                      ? _C.red.withOpacity(0.45)
                                      : _C.border,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.trending_down_rounded,
                                        color: _tradeType == _TradeType.sell
                                            ? _C.red : _C.textMuted,
                                        size: 18),
                                    const SizedBox(width: 8),
                                    Text('SELL',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color:
                                            _tradeType == _TradeType.sell
                                                ? _C.red
                                                : _C.textMuted,
                                            letterSpacing: 1)),
                                  ]),
                            ),
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 10),

                    // ── 5. Quantity ───────────────────────────────────
                    _FieldCard(
                      label: 'Quantity',
                      labelColor: _accent,
                      child: _InlineInput(
                        controller: _qtyCtrl,
                        hint: 'Enter quantity',
                        inputType: TextInputType.number,
                        suffix: 'shares',
                        onChanged: (_) => setState(() {}),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── 6. Price ──────────────────────────────────────
                    _FieldCard(
                      label: 'Price',
                      labelColor: _accent,
                      child: _InlineInput(
                        controller: _priceCtrl,
                        hint: _orderType == _OrderType.market
                            ? 'Market price'
                            : 'Enter price',
                        inputType: const TextInputType.numberWithOptions(
                            decimal: true),
                        prefix: 'E',
                        readOnly: _orderType == _OrderType.market,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),

                    // ── Order summary if filled ────────────────────────
                    if (_selected != null && _qty > 0) ...[
                      const SizedBox(height: 10),
                      _SummaryCard(
                        company:    _selected!,
                        qty:        _qty,
                        unitPrice:  _unitPrice,
                        estimated:  _estimated,
                        commission: _commission,
                        grandTotal: _grandTotal,
                        tradeType:  _tradeType,
                        accent:     _accent,
                      ),
                    ],

                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Orders processed during ESE market hours  ·  Sun–Thu  09:00–15:30 EAT',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 9.5,
                            color: _C.textMuted, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),

      // ── Sticky POST button ─────────────────────────────────────────────────
      bottomNavigationBar: _PostButton(
        tradeType: _tradeType,
        accent:    _accent,
        enabled:   _selected != null && _qty > 0,
        onTap:     () => _confirmOrder(context),
      ),
    );
  }

  void _confirmOrder(BuildContext context) {
    if (_selected == null || _qty <= 0) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ConfirmSheet(
        company:   _selected!,
        tradeType: _tradeType,
        orderType: _orderType,
        tif:       _tif,
        qty:       _qty,
        grandTotal: _grandTotal,
        accent:    _accent,
        onConfirm: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: _accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            content: Row(children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                '${_tradeType == _TradeType.buy ? "Buy" : "Sell"} '
                    'order placed for ${_selected!.ticker}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ]),
          ));
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
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.border, width: 1),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: _C.textSub, size: 15),
                ),
              ),
            ),
            title: const Text('Post Order',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: _C.textPrim, letterSpacing: 0.2)),
          ),
        ),
      ),
    );
  }
}

// ─── Field Card ───────────────────────────────────────────────────────────────
class _FieldCard extends StatelessWidget {
  final String label;
  final Color  labelColor;
  final Widget child;
  const _FieldCard({
    required this.label,
    required this.labelColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.18),
              blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                  letterSpacing: 0.5)),
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
  final String? prefix;
  final String? suffix;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const _InlineInput({
    required this.controller,
    required this.hint,
    required this.inputType,
    this.prefix,
    this.suffix,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      if (prefix != null) ...[
        Text(prefix!,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: _C.textSub)),
        const SizedBox(width: 8),
      ],
      Expanded(
        child: TextField(
          controller: controller,
          keyboardType: inputType,
          readOnly: readOnly,
          onChanged: onChanged,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: readOnly ? _C.textSub : _C.textPrim),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                fontSize: 15, color: _C.textMuted,
                fontWeight: FontWeight.w400),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
      if (suffix != null) ...[
        const SizedBox(width: 8),
        Text(suffix!,
            style: const TextStyle(
                fontSize: 11, color: _C.textSub,
                fontWeight: FontWeight.w500)),
      ],
    ]);
  }
}

// ─── Order Summary Card ───────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final _Company company;
  final int qty;
  final double unitPrice, estimated, commission, grandTotal;
  final _TradeType tradeType;
  final Color accent;

  const _SummaryCard({
    required this.company, required this.qty,
    required this.unitPrice, required this.estimated,
    required this.commission, required this.grandTotal,
    required this.tradeType, required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.22), width: 1),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 10),
          child: Row(children: [
            Container(width: 3, height: 14,
                decoration: BoxDecoration(color: accent,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text('Order Summary',
                style: TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accent, letterSpacing: 0.4)),
          ]),
        ),
        Container(height: 1, color: _C.border),
        _SumRow('Company',         company.ticker),
        _SumRow('Action',
            tradeType == _TradeType.buy ? 'BUY' : 'SELL',
            valueColor: accent),
        _SumRow('Qty',
            '$qty share${qty != 1 ? "s" : ""}'),
        _SumRow('Price / Share',
            'E ${unitPrice.toStringAsFixed(2)}'),
        _SumRow('Subtotal',
            'E ${estimated.toStringAsFixed(2)}'),
        _SumRow('Commission (0.25%)',
            'E ${commission.toStringAsFixed(2)}',
            valueColor: _C.textSub),
        Container(height: 1, color: _C.border,
            margin: const EdgeInsets.symmetric(horizontal: 16)),
        _SumRow('Total',
            'E ${grandTotal.toStringAsFixed(2)}',
            valueColor: accent, bold: true, last: true),
      ]),
    );
  }
}

class _SumRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool bold, last;
  const _SumRow(this.label, this.value,
      {this.valueColor, this.bold = false, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, last ? 11 : 9, 16, last ? 11 : 9),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 12,
            color: _C.textSub,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
        Text(value, style: TextStyle(
            fontSize: bold ? 14.5 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? _C.textPrim,
            letterSpacing: bold ? -0.3 : 0)),
      ]),
    );
  }
}

// ─── Sticky POST Button ───────────────────────────────────────────────────────
class _PostButton extends StatelessWidget {
  final _TradeType tradeType;
  final Color accent;
  final bool enabled;
  final VoidCallback onTap;

  const _PostButton({
    required this.tradeType, required this.accent,
    required this.enabled, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                  ? [const Color(0xFF0D3320), const Color(0xFF155229)]
                  : [const Color(0xFF3D0808), const Color(0xFF6B1111)]
                  : [_C.surface, _C.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: enabled ? accent.withOpacity(0.50) : _C.border,
              width: 1,
            ),
            boxShadow: enabled
                ? [BoxShadow(color: accent.withOpacity(0.28),
                blurRadius: 18, offset: const Offset(0, 6))]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                tradeType == _TradeType.buy
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: enabled ? accent : _C.textMuted,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                tradeType == _TradeType.buy ? 'POST BUY ORDER' : 'POST SELL ORDER',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: enabled ? accent : _C.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Confirm Bottom Sheet ─────────────────────────────────────────────────────
class _ConfirmSheet extends StatelessWidget {
  final _Company   company;
  final _TradeType tradeType;
  final _OrderType orderType;
  final _TimeInForce tif;
  final int        qty;
  final double     grandTotal;
  final Color      accent;
  final VoidCallback onConfirm;

  const _ConfirmSheet({
    required this.company, required this.tradeType,
    required this.orderType, required this.tif,
    required this.qty, required this.grandTotal,
    required this.accent, required this.onConfirm,
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
    return Container(
      decoration: const BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: _C.border,
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
              color: _C.textPrim),
        ),
        const SizedBox(height: 4),
        Text(_orderTypeLabel,
            style: const TextStyle(fontSize: 12, color: _C.textSub)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.border, width: 1),
          ),
          child: Column(children: [
            _SheetRow(label: 'Company',
                value: '${company.name} (${company.ticker})'),
            const SizedBox(height: 10),
            _SheetRow(label: 'Shares',
                value: '$qty share${qty != 1 ? "s" : ""}'),
            const SizedBox(height: 10),
            _SheetRow(label: 'Total Amount',
                value: 'E ${grandTotal.toStringAsFixed(2)}',
                bold: true, valueColor: accent),
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
                    ? [const Color(0xFF0D3320), const Color(0xFF155229)]
                    : [const Color(0xFF3D0808), const Color(0xFF6B1111)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withOpacity(0.45), width: 1),
              boxShadow: [BoxShadow(color: accent.withOpacity(0.28),
                  blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Center(
              child: Text('Confirm & Post Order',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                      color: accent, letterSpacing: 0.3)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text('Cancel',
              style: TextStyle(fontSize: 13, color: _C.textSub,
                  fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  final Color? valueColor;
  const _SheetRow({required this.label, required this.value,
    this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: _C.textSub)),
      Text(value, style: TextStyle(
          fontSize: bold ? 15 : 13,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          color: valueColor ?? _C.textPrim)),
    ]);
  }
}

// ─── Glow Orb ─────────────────────────────────────────────────────────────────
class _GlowOrb extends StatelessWidget {
  final double size, opacity;
  final Color color;
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