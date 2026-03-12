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
    required this.ticker,
    required this.name,
    required this.sector,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.positive,
  });
}

// ─── ESE Listed Companies ─────────────────────────────────────────────────────
const List<_Company> _companies = [
  _Company(ticker: 'CBEET',  name: 'Commercial Bank of Ethiopia',
      sector: 'Banking',      price: 42.50,  change: 1.20,  changePercent: 2.91,  positive: true),
  _Company(ticker: 'AWBET',  name: 'Awash Bank',
      sector: 'Banking',      price: 38.75,  change: -0.45, changePercent: 1.15,  positive: false),
  _Company(ticker: 'DASHET', name: 'Dashen Bank',
      sector: 'Banking',      price: 35.20,  change: 0.80,  changePercent: 2.32,  positive: true),
  _Company(ticker: 'ABYET',  name: 'Abyssinia Bank',
      sector: 'Banking',      price: 29.60,  change: -0.30, changePercent: 1.00,  positive: false),
  _Company(ticker: 'NBET',   name: 'Nib Bank',
      sector: 'Banking',      price: 24.10,  change: 0.55,  changePercent: 2.33,  positive: true),
  _Company(ticker: 'ETHINS', name: 'Ethiopian Insurance',
      sector: 'Insurance',    price: 18.90,  change: 0.10,  changePercent: 0.53,  positive: true),
  _Company(ticker: 'AWINS',  name: 'Awash Insurance',
      sector: 'Insurance',    price: 15.40,  change: -0.20, changePercent: 1.28,  positive: false),
  _Company(ticker: 'ETBREW', name: 'Ethiopian Breweries',
      sector: 'FMCG',         price: 55.00,  change: 2.50,  changePercent: 4.76,  positive: true),
  _Company(ticker: 'MBET',   name: 'Meta Abo Brewery',
      sector: 'FMCG',         price: 46.30,  change: -1.10, changePercent: 2.32,  positive: false),
  _Company(ticker: 'ETTEL',  name: 'Ethio Telecom',
      sector: 'Telecom',      price: 88.00,  change: 3.00,  changePercent: 3.53,  positive: true),
];

// ─── Trade Type ───────────────────────────────────────────────────────────────
enum _TradeType { buy, sell }

// ─── Order Type ───────────────────────────────────────────────────────────────
enum _OrderType { market, limit, stopLoss }

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
  late Animation<Offset> _slide;

  _TradeType _tradeType  = _TradeType.buy;
  _OrderType _orderType  = _OrderType.market;
  _Company?  _selected;

  final _qtyCtrl   = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController();

  bool _dropdownOpen = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 700));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.06), end: Offset.zero)
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

  // ── Computed values ──────────────────────────────────────────────────────────
  double get _unitPrice {
    if (_orderType == _OrderType.market) {
      return _selected?.price ?? 0.0;
    }
    return double.tryParse(_priceCtrl.text) ?? (_selected?.price ?? 0.0);
  }

  int get _qty => int.tryParse(_qtyCtrl.text) ?? 0;

  double get _estimatedTotal => _unitPrice * _qty;

  double get _commission => _estimatedTotal * 0.0025; // 0.25 %

  double get _grandTotal => _estimatedTotal + _commission;

  List<_Company> get _filtered => _searchQuery.isEmpty
      ? _companies
      : _companies.where((c) =>
  c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      c.ticker.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

  // ── Accent color based on buy/sell ───────────────────────────────────────────
  Color get _accent => _tradeType == _TradeType.buy ? _C.teal : _C.red;

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
          // Glow orbs
          Positioned(top: -40, right: -60,
              child: _GlowOrb(size: 220, color: _accent, opacity: 0.06)),
          Positioned(bottom: 120, left: -60,
              child: _GlowOrb(size: 180, color: _C.blue, opacity: 0.06)),

          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: GestureDetector(
                // Close dropdown on tap outside
                onTap: () {
                  if (_dropdownOpen) setState(() => _dropdownOpen = false);
                  FocusScope.of(context).unfocus();
                },
                behavior: HitTestBehavior.translucent,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        kToolbarHeight + 12,
                    bottom: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Buy / Sell toggle ──────────────────────────────
                      _BuySellToggle(
                        selected: _tradeType,
                        onChanged: (t) => setState(() => _tradeType = t),
                      ),
                      const SizedBox(height: 22),

                      // ── Company selector ───────────────────────────────
                      _sectionLabel('Select Company'),
                      const SizedBox(height: 8),
                      _CompanyDropdown(
                        selected: _selected,
                        open: _dropdownOpen,
                        query: _searchQuery,
                        filtered: _filtered,
                        onToggle: () =>
                            setState(() => _dropdownOpen = !_dropdownOpen),
                        onSearch: (q) =>
                            setState(() => _searchQuery = q),
                        onSelect: (c) => setState(() {
                          _selected = c;
                          _dropdownOpen = false;
                          _searchQuery = '';
                          if (_orderType == _OrderType.market) {
                            _priceCtrl.text =
                                c.price.toStringAsFixed(2);
                          }
                        }),
                      ),

                      // ── Selected company card ──────────────────────────
                      if (_selected != null && !_dropdownOpen) ...[
                        const SizedBox(height: 14),
                        _SelectedCompanyCard(company: _selected!),
                      ],

                      if (!_dropdownOpen) ...[
                        const SizedBox(height: 22),

                        // ── Order type ─────────────────────────────────
                        _sectionLabel('Order Type'),
                        const SizedBox(height: 8),
                        _OrderTypeSelector(
                          selected: _orderType,
                          onChanged: (t) => setState(() => _orderType = t),
                        ),

                        const SizedBox(height: 22),

                        // ── Quantity & Price ───────────────────────────
                        _sectionLabel('Trade Details'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _InputField(
                                label: 'Quantity (Shares)',
                                controller: _qtyCtrl,
                                prefix: Icons.numbers_rounded,
                                inputType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InputField(
                                label: _orderType == _OrderType.market
                                    ? 'Market Price'
                                    : 'Limit Price (E)',
                                controller: _priceCtrl,
                                prefix: Icons.attach_money_rounded,
                                inputType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                                readOnly:
                                _orderType == _OrderType.market,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ── Order summary ──────────────────────────────
                        if (_selected != null) ...[
                          _sectionLabel('Order Summary'),
                          const SizedBox(height: 8),
                          _OrderSummary(
                            company: _selected!,
                            qty: _qty,
                            unitPrice: _unitPrice,
                            estimated: _estimatedTotal,
                            commission: _commission,
                            grandTotal: _grandTotal,
                            tradeType: _tradeType,
                            accent: _accent,
                          ),
                          const SizedBox(height: 24),
                        ] else ...[
                          const SizedBox(height: 24),
                          _EmptyState(),
                          const SizedBox(height: 24),
                        ],

                        // ── Place Order button ─────────────────────────
                        _PlaceOrderButton(
                          tradeType: _tradeType,
                          accent: _accent,
                          enabled: _selected != null && _qty > 0,
                          onTap: () => _confirmOrder(context),
                        ),

                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Orders are processed during ESE market hours\n'
                                'Sun–Thu  09:00–15:30 EAT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10,
                                color: _C.textMuted,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(text.toUpperCase(),
        style: const TextStyle(
            fontSize: 9.5, fontWeight: FontWeight.w700,
            color: _C.textMuted, letterSpacing: 1.2)),
  );

  void _confirmOrder(BuildContext context) {
    if (_selected == null || _qty <= 0) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ConfirmSheet(
        company: _selected!,
        tradeType: _tradeType,
        orderType: _orderType,
        qty: _qty,
        grandTotal: _grandTotal,
        accent: _accent,
        onConfirm: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: _accent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              content: Row(children: [
                Icon(
                  _tradeType == _TradeType.buy
                      ? Icons.check_circle_rounded
                      : Icons.check_circle_rounded,
                  color: Colors.white, size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  '${_tradeType == _TradeType.buy ? "Buy" : "Sell"} '
                      'order placed for ${_selected!.ticker}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ]),
            ),
          );
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
            elevation: 0,
            centerTitle: true,
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
            title: const Text('Place Trade',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: _C.textPrim, letterSpacing: 0.2)),
          ),
        ),
      ),
    );
  }
}

// ─── Buy / Sell Toggle ────────────────────────────────────────────────────────
class _BuySellToggle extends StatelessWidget {
  final _TradeType selected;
  final ValueChanged<_TradeType> onChanged;
  const _BuySellToggle(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border, width: 1),
        ),
        child: Row(children: [
          _ToggleOption(
            label: 'Buy',
            icon: Icons.trending_up_rounded,
            active: selected == _TradeType.buy,
            activeColor: _C.teal,
            onTap: () => onChanged(_TradeType.buy),
          ),
          _ToggleOption(
            label: 'Sell',
            icon: Icons.trending_down_rounded,
            active: selected == _TradeType.sell,
            activeColor: _C.red,
            onTap: () => onChanged(_TradeType.sell),
          ),
        ]),
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  const _ToggleOption({
    required this.label, required this.icon,
    required this.active, required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: active ? activeColor.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? activeColor.withOpacity(0.40) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: active ? activeColor : _C.textMuted,
                  size: 18),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: active ? activeColor : _C.textMuted,
                  letterSpacing: 0.3,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Company Dropdown ─────────────────────────────────────────────────────────
class _CompanyDropdown extends StatelessWidget {
  final _Company? selected;
  final bool open;
  final String query;
  final List<_Company> filtered;
  final VoidCallback onToggle;
  final ValueChanged<String> onSearch;
  final ValueChanged<_Company> onSelect;

  const _CompanyDropdown({
    required this.selected, required this.open,
    required this.query, required this.filtered,
    required this.onToggle, required this.onSearch,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Selector button
          GestureDetector(
            onTap: onToggle,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _C.card,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(16),
                  bottom: Radius.circular(open ? 0 : 16),
                ),
                border: Border.all(
                  color: open
                      ? _C.gold.withOpacity(0.35)
                      : _C.border,
                  width: 1,
                ),
              ),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: _C.gold.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.business_rounded,
                      color: _C.gold.withOpacity(0.80), size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: selected == null
                      ? Text('Select a company…',
                      style: TextStyle(
                          fontSize: 13.5, color: _C.textMuted))
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(selected!.name,
                          style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: _C.textPrim),
                          overflow: TextOverflow.ellipsis),
                      Text(selected!.ticker,
                          style: TextStyle(
                              fontSize: 10,
                              color: _C.gold.withOpacity(0.85),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: _C.textSub, size: 22),
                ),
              ]),
            ),
          ),

          // Dropdown panel
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: open
                ? Container(
              constraints: const BoxConstraints(maxHeight: 340),
              decoration: BoxDecoration(
                color: _C.card,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16)),
                border: Border.all(
                    color: _C.gold.withOpacity(0.25), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.40),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search field
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: _C.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _C.border, width: 1),
                      ),
                      child: Row(children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(Icons.search_rounded,
                              color: _C.textMuted, size: 16),
                        ),
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            onChanged: onSearch,
                            style: const TextStyle(
                                fontSize: 13, color: _C.textPrim),
                            decoration: InputDecoration(
                              hintText: 'Search companies…',
                              hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: _C.textMuted),
                              border: InputBorder.none,
                              contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 10),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),

                  // Company list
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding:
                      const EdgeInsets.only(bottom: 6),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        final isSelected = c.ticker ==
                            (selected?.ticker ?? '');
                        return GestureDetector(
                          onTap: () => onSelect(c),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration:
                            const Duration(milliseconds: 150),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _C.gold.withOpacity(0.10)
                                  : Colors.transparent,
                              borderRadius:
                              BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? _C.gold.withOpacity(0.25)
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Row(children: [
                              // Ticker badge
                              Container(
                                width: 44,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4),
                                decoration: BoxDecoration(
                                  color: _C.surface,
                                  borderRadius:
                                  BorderRadius.circular(6),
                                  border: Border.all(
                                      color: _C.border, width: 1),
                                ),
                                child: Text(c.ticker,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 8,
                                        fontWeight:
                                        FontWeight.w800,
                                        color: isSelected
                                            ? _C.gold
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
                                        style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight:
                                            FontWeight.w600,
                                            color: isSelected
                                                ? _C.textPrim
                                                : _C.textPrim),
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
                                  Text('E ${c.price.toStringAsFixed(2)}',
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
                ],
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Selected Company Card ────────────────────────────────────────────────────
class _SelectedCompanyCard extends StatelessWidget {
  final _Company company;
  const _SelectedCompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border, width: 1),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(company.name,
                  style: const TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w700, color: _C.textPrim)),
              const SizedBox(height: 3),
              Text('${company.ticker}  •  ${company.sector}',
                  style: TextStyle(fontSize: 10, color: _C.textSub)),
            ],
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('E ${company.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w900, color: _C.textPrim,
                  letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (company.positive ? _C.teal : _C.red)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (company.positive ? _C.teal : _C.red)
                    .withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                company.positive
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: company.positive ? _C.teal : _C.red,
                size: 10,
              ),
              const SizedBox(width: 3),
              Text(
                '${company.positive ? '+' : ''}${company.change.toStringAsFixed(2)}  '
                    '(${company.positive ? '+' : ''}${company.changePercent.toStringAsFixed(2)}%)',
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: company.positive ? _C.teal : _C.red),
              ),
            ]),
          ),
        ]),
      ]),
    );
  }
}

// ─── Order Type Selector ──────────────────────────────────────────────────────
class _OrderTypeSelector extends StatelessWidget {
  final _OrderType selected;
  final ValueChanged<_OrderType> onChanged;
  const _OrderTypeSelector(
      {required this.selected, required this.onChanged});

  static const _types = [
    (_OrderType.market,  'Market',    Icons.flash_on_rounded),
    (_OrderType.limit,   'Limit',     Icons.tune_rounded),
    (_OrderType.stopLoss,'Stop Loss', Icons.shield_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _types.map((t) {
          final active = selected == t.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(t.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: t == _types.last ? 0 : 10),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: active
                      ? _C.blue.withOpacity(0.15)
                      : _C.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active
                        ? _C.blue.withOpacity(0.40)
                        : _C.border,
                    width: 1,
                  ),
                ),
                child: Column(children: [
                  Icon(t.$3,
                      color: active ? _C.blue : _C.textMuted,
                      size: 18),
                  const SizedBox(height: 4),
                  Text(t.$2,
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: active ? _C.blue : _C.textSub)),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Input Field ──────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData prefix;
  final TextInputType inputType;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.label,
    required this.controller,
    required this.prefix,
    required this.inputType,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: readOnly ? _C.surface.withOpacity(0.60) : _C.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border, width: 1),
      ),
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Icon(prefix, color: _C.gold.withOpacity(0.60), size: 16),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: inputType,
            readOnly: readOnly,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 15,
                fontWeight: FontWeight.w700, color: _C.textPrim),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(fontSize: 10, color: _C.textSub),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Order Summary ────────────────────────────────────────────────────────────
class _OrderSummary extends StatelessWidget {
  final _Company company;
  final int qty;
  final double unitPrice, estimated, commission, grandTotal;
  final _TradeType tradeType;
  final Color accent;

  const _OrderSummary({
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
        border: Border.all(color: accent.withOpacity(0.20), width: 1),
      ),
      child: Column(children: [
        _SummaryRow(label: 'Company',  value: company.ticker),
        _SummaryRow(label: 'Action',
            value: tradeType == _TradeType.buy ? 'BUY' : 'SELL',
            valueColor: accent),
        _SummaryRow(label: 'Quantity',
            value: '$qty share${qty != 1 ? 's' : ''}'),
        _SummaryRow(label: 'Price / Share',
            value: 'E ${unitPrice.toStringAsFixed(2)}'),
        _SummaryRow(label: 'Subtotal',
            value: 'E ${estimated.toStringAsFixed(2)}'),
        _SummaryRow(label: 'Commission (0.25%)',
            value: 'E ${commission.toStringAsFixed(2)}',
            valueColor: _C.textSub),
        Container(height: 1, color: _C.border,
            margin: const EdgeInsets.symmetric(horizontal: 16)),
        _SummaryRow(
          label: 'Total',
          value: 'E ${grandTotal.toStringAsFixed(2)}',
          valueColor: accent,
          bold: true,
          last: true,
        ),
      ]),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool bold, last;
  const _SummaryRow({
    required this.label, required this.value,
    this.valueColor, this.bold = false, this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, last ? 12 : 10, 16, last ? 12 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12,
                  color: _C.textSub,
                  fontWeight:
                  bold ? FontWeight.w700 : FontWeight.w400)),
          Text(value,
              style: TextStyle(
                  fontSize: bold ? 15 : 13,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: valueColor ?? _C.textPrim,
                  letterSpacing: bold ? -0.3 : 0)),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: _C.card,
            shape: BoxShape.circle,
            border: Border.all(color: _C.border, width: 1),
          ),
          child: Icon(Icons.candlestick_chart_outlined,
              color: _C.textMuted, size: 28),
        ),
        const SizedBox(height: 12),
        Text('Select a company to continue',
            style: TextStyle(fontSize: 13, color: _C.textMuted)),
      ]),
    );
  }
}

// ─── Place Order Button ───────────────────────────────────────────────────────
class _PlaceOrderButton extends StatelessWidget {
  final _TradeType tradeType;
  final Color accent;
  final bool enabled;
  final VoidCallback onTap;
  const _PlaceOrderButton({
    required this.tradeType, required this.accent,
    required this.enabled, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled
                ? tradeType == _TradeType.buy
                ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                : [const Color(0xFF7F0000), const Color(0xFFC62828)]
                : [_C.surface, _C.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: enabled ? accent.withOpacity(0.45) : _C.border,
            width: 1,
          ),
          boxShadow: enabled
              ? [
            BoxShadow(
              color: accent.withOpacity(0.30),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ]
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
              tradeType == _TradeType.buy
                  ? 'Place Buy Order'
                  : 'Place Sell Order',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: enabled ? accent : _C.textMuted,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Confirm Bottom Sheet ─────────────────────────────────────────────────────
class _ConfirmSheet extends StatelessWidget {
  final _Company company;
  final _TradeType tradeType;
  final _OrderType orderType;
  final int qty;
  final double grandTotal;
  final Color accent;
  final VoidCallback onConfirm;

  const _ConfirmSheet({
    required this.company, required this.tradeType,
    required this.orderType, required this.qty,
    required this.grandTotal, required this.accent,
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
    return Container(
      decoration: const BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),

          // Icon
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.12),
              border: Border.all(
                  color: accent.withOpacity(0.30), width: 1.5),
            ),
            child: Icon(
              tradeType == _TradeType.buy
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: accent, size: 26,
            ),
          ),
          const SizedBox(height: 14),

          Text('Confirm ${tradeType == _TradeType.buy ? "Buy" : "Sell"} Order',
              style: const TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w800, color: _C.textPrim)),
          const SizedBox(height: 4),
          Text(_orderTypeLabel,
              style: TextStyle(fontSize: 12, color: _C.textSub)),
          const SizedBox(height: 20),

          // Summary
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

          // Confirm button
          GestureDetector(
            onTap: onConfirm,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: tradeType == _TradeType.buy
                      ? [const Color(0xFF1B5E20),
                    const Color(0xFF2E7D32)]
                      : [const Color(0xFF7F0000),
                    const Color(0xFFC62828)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: accent.withOpacity(0.45), width: 1),
                boxShadow: [
                  BoxShadow(color: accent.withOpacity(0.30),
                      blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Center(
                child: Text(
                  'Confirm & Place Order',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800,
                      color: accent, letterSpacing: 0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(fontSize: 13,
                    color: _C.textSub,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
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
  final double size;
  final Color color;
  final double opacity;
  const _GlowOrb(
      {required this.size, required this.color, required this.opacity});
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