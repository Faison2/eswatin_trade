import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../settings /settings.dart';

// ─── Dark tokens ──────────────────────────────────────────────────────────────
class _Dark {
  static const bg       = Color(0xFF060C1A);
  static const surface  = Color(0xFF0D1728);
  static const card     = Color(0xFF0F1D32);
  static const border   = Color(0xFF1A2A40);
  static const gold     = Color(0xFFD4A030);
  static const goldSoft = Color(0xFFF5D98B);
  static const blue     = Color(0xFF1565C0);
  static const red      = Color(0xFFEF5350);
  static const textPrim = Color(0xFFEEF2FF);
  static const textSub  = Color(0xFF5A7090);
  static const textDim  = Color(0xFF2A3F58);
  static const avatarBg1 = Color(0xFF0D1A33);
  static const avatarBg2 = Color(0xFF142444);
}

// ─── Light tokens ─────────────────────────────────────────────────────────────
class _Light {
  static const bg       = Color(0xFFF0F4FB);
  static const surface  = Color(0xFFFFFFFF);
  static const card     = Color(0xFFFFFFFF);
  static const border   = Color(0xFFDDE3EF);
  static const gold     = Color(0xFFC49020);
  static const goldSoft = Color(0xFF8B6010);
  static const blue     = Color(0xFF1565C0);
  static const red      = Color(0xFFD43F3C);
  static const textPrim = Color(0xFF0D1728);
  static const textSub  = Color(0xFF64748B);
  static const textDim  = Color(0xFFADB5C7);
  static const avatarBg1 = Color(0xFFFFF8EE);
  static const avatarBg2 = Color(0xFFFFF3DC);
}

// ─── Profile Screen ───────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  final AppThemeNotifier themeNotifier;
  const ProfileScreen({super.key, required this.themeNotifier});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  String _fullName  = '';
  String _forenames = '';
  String _surname   = '';
  String _email     = '';
  String _phone     = '';
  String _cdsNumber = '';
  String _initials  = '';
  bool   _loading   = true;

  // ── Theme helpers ────────────────────────────────────────────────────────
  bool   get _isLight  => widget.themeNotifier.isLight;
  Color  get _bg       => _isLight ? _Light.bg       : _Dark.bg;
  Color  get _surface  => _isLight ? _Light.surface  : _Dark.surface;
  Color  get _card     => _isLight ? _Light.card     : _Dark.card;
  Color  get _border   => _isLight ? _Light.border   : _Dark.border;
  Color  get _gold     => _isLight ? _Light.gold     : _Dark.gold;
  Color  get _goldSoft => _isLight ? _Light.goldSoft : _Dark.goldSoft;
  Color  get _red      => _isLight ? _Light.red      : _Dark.red;
  Color  get _textPrim => _isLight ? _Light.textPrim : _Dark.textPrim;
  Color  get _textSub  => _isLight ? _Light.textSub  : _Dark.textSub;
  Color  get _textDim  => _isLight ? _Light.textDim  : _Dark.textDim;

  void _rebuild() => setState(() {});

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    widget.themeNotifier.addListener(_rebuild);
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _fullName  = p.getString('full_name')    ?? 'Unknown';
      _forenames = p.getString('forenames')    ?? '';
      _surname   = p.getString('surname')      ?? '';
      _email     = p.getString('email')        ?? '—';
      _phone     = p.getString('phone_number') ?? '—';
      _cdsNumber = p.getString('cds_number')   ?? '—';
      _initials  = '${_forenames.isNotEmpty ? _forenames[0] : ''}'
          '${_surname.isNotEmpty ? _surname[0] : ''}'.toUpperCase();
      if (_initials.isEmpty) _initials = 'U';
      _loading = false;
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    widget.themeNotifier.removeListener(_rebuild);
    super.dispose();
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _SignOutDialog(
        isLight:  _isLight,
        card:     _card,
        surface:  _surface,
        border:   _border,
        red:      _red,
        textPrim: _textPrim,
        textSub:  _textSub,
      ),
    );
    if (confirmed == true && mounted) {
      final p = await SharedPreferences.getInstance();
      await p.clear();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: _isLight ? Brightness.dark : Brightness.light,
    ));

    if (_loading) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: _bg,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(color: _gold, strokeWidth: 2),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: _bg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _AppBar(
          onBack:   () => Navigator.pop(context),
          isLight:  _isLight,
          bg:       _bg,
          surface:  _surface,
          border:   _border,
          textPrim: _textPrim,
          textSub:  _textSub,
        ),
        body: Stack(children: [
          // Ambient orbs
          Positioned(top: -60, right: -80,
              child: _Orb(size: 280,
                  color: _gold,
                  opacity: _isLight ? 0.04 : 0.055)),
          Positioned(top: 260, left: -100,
              child: _Orb(size: 220,
                  color: _isLight ? _Light.blue : _Dark.blue,
                  opacity: _isLight ? 0.04 : 0.065)),

          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top +
                      kToolbarHeight + 12,
                  bottom: 48,
                ),
                child: Column(children: [

                  // ── Hero avatar card ──────────────────────────────
                  _HeroCard(
                    initials:  _initials,
                    fullName:  _fullName,
                    email:     _email,
                    isLight:   _isLight,
                    card:      _card,
                    surface:   _surface,
                    border:    _border,
                    gold:      _gold,
                    goldSoft:  _goldSoft,
                    textPrim:  _textPrim,
                    textSub:   _textSub,
                  ),

                  const SizedBox(height: 28),

                  // ── Section label ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: Row(children: [
                      Text('ACCOUNT DETAILS',
                          style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: _textSub,
                              letterSpacing: 1.8)),
                      const SizedBox(width: 12),
                      Expanded(child: Container(height: 1, color: _border)),
                    ]),
                  ),

                  // ── Details card ──────────────────────────────────
                  _DetailsCard(
                    fields: [
                      _Field(Icons.person_rounded,      'First Name',  _forenames),
                      _Field(Icons.person_outline,      'Surname',     _surname),
                      _Field(Icons.email_outlined,      'Email',       _email),
                      _Field(Icons.phone_outlined,      'Phone',       _phone),
                      _Field(Icons.credit_card_rounded, 'CDS Number',  _cdsNumber),
                    ],
                    isLight:  _isLight,
                    card:     _card,
                    border:   _border,
                    gold:     _gold,
                    textPrim: _textPrim,
                    textSub:  _textSub,
                  ),

                  const SizedBox(height: 36),

                  _SignOutBtn(onTap: _signOut, red: _red),

                  const SizedBox(height: 16),
                  Text('© 2025 Eswatini Stock Exchange',
                      style: TextStyle(fontSize: 9.5,
                          color: _textDim, letterSpacing: 0.4)),
                  const SizedBox(height: 8),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final bool  isLight;
  final Color bg, surface, border, textPrim, textSub;

  const _AppBar({
    required this.onBack, required this.isLight,
    required this.bg, required this.surface, required this.border,
    required this.textPrim, required this.textSub,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: bg.withOpacity(isLight ? 0.85 : 0.55),
            border: Border(
                bottom: BorderSide(color: border.withOpacity(0.5), width: 1)),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: Row(children: [
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: border),
                      boxShadow: isLight ? [BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8, offset: const Offset(0, 2))] : [],
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: textSub, size: 14),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text('My Profile',
                        style: TextStyle(fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrim, letterSpacing: 0.2)),
                  ),
                ),
                const SizedBox(width: 52),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hero Card ────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final String initials, fullName, email;
  final bool   isLight;
  final Color  card, surface, border, gold, goldSoft, textPrim, textSub;

  const _HeroCard({
    required this.initials, required this.fullName, required this.email,
    required this.isLight, required this.card, required this.surface,
    required this.border, required this.gold, required this.goldSoft,
    required this.textPrim, required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    final avatarBg1 = isLight ? _Light.avatarBg1 : _Dark.avatarBg1;
    final avatarBg2 = isLight ? _Light.avatarBg2 : _Dark.avatarBg2;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
              color: isLight
                  ? Colors.black.withOpacity(0.07)
                  : gold.withOpacity(0.07),
              blurRadius: 40, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(children: [
        // Avatar with gold ring
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFD4A030), Color(0xFF8B5E10)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: gold.withOpacity(0.35),
                  blurRadius: 32, spreadRadius: 2),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [avatarBg1, avatarBg2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(initials,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                        color: gold, letterSpacing: 2)),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(fullName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                color: textPrim, letterSpacing: -0.3)),

        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: Text(email,
              style: TextStyle(fontSize: 11.5, color: textSub)),
        ),

        const SizedBox(height: 20),

        // Gold shimmer divider
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent,
              gold.withOpacity(0.40),
              Colors.transparent,
            ]),
          ),
        ),

        const SizedBox(height: 18),

        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.verified_rounded,
              color: gold.withOpacity(0.85), size: 14),
          const SizedBox(width: 6),
          Text('ESE MEMBER',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                  color: gold, letterSpacing: 2.5)),
        ]),
      ]),
    );
  }
}

// ─── Field model ──────────────────────────────────────────────────────────────
class _Field {
  final IconData icon;
  final String   label, value;
  const _Field(this.icon, this.label, this.value);
}

// ─── Details Card ─────────────────────────────────────────────────────────────
class _DetailsCard extends StatelessWidget {
  final List<_Field> fields;
  final bool  isLight;
  final Color card, border, gold, textPrim, textSub;

  const _DetailsCard({
    required this.fields, required this.isLight,
    required this.card, required this.border, required this.gold,
    required this.textPrim, required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
        boxShadow: isLight ? [BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16, offset: const Offset(0, 4))] : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: fields.asMap().entries.map((e) {
            final isLast = e.key == fields.length - 1;
            final f = e.value;
            return Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 15),
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: gold.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: gold.withOpacity(0.15), width: 1),
                    ),
                    child: Icon(f.icon,
                        color: gold.withOpacity(0.70), size: 16),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.label,
                          style: TextStyle(fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: textSub, letterSpacing: 0.8)),
                      const SizedBox(height: 3),
                      Text(f.value,
                          style: TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textPrim)),
                    ],
                  )),
                ]),
              ),
              if (!isLast)
                Container(
                    height: 1,
                    color: border.withOpacity(0.6),
                    margin: const EdgeInsets.only(left: 68)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Sign Out Button ──────────────────────────────────────────────────────────
class _SignOutBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Color red;
  const _SignOutBtn({required this.onTap, required this.red});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 50,
        decoration: BoxDecoration(
          color: red.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: red.withOpacity(0.25), width: 1),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.logout_rounded, color: red.withOpacity(0.85), size: 17),
          const SizedBox(width: 8),
          Text('Sign Out',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700,
                  color: red.withOpacity(0.85), letterSpacing: 0.3)),
        ]),
      ),
    );
  }
}

// ─── Sign Out Dialog ──────────────────────────────────────────────────────────
class _SignOutDialog extends StatelessWidget {
  final bool  isLight;
  final Color card, surface, border, red, textPrim, textSub;

  const _SignOutDialog({
    required this.isLight, required this.card, required this.surface,
    required this.border, required this.red,
    required this.textPrim, required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    final cancelBg = isLight ? const Color(0xFFF0F4FB) : surface;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border, width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isLight ? 0.12 : 0.55),
                blurRadius: 48, offset: const Offset(0, 20)),
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: red.withOpacity(0.09), shape: BoxShape.circle,
              border: Border.all(color: red.withOpacity(0.22), width: 1.5),
            ),
            child: Icon(Icons.logout_rounded, color: red, size: 22),
          ),
          const SizedBox(height: 16),
          Text('Sign Out?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                  color: textPrim)),
          const SizedBox(height: 8),
          Text('You will be returned to the login screen.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12,
                  color: textSub.withOpacity(0.75))),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                height: 44,
                decoration: BoxDecoration(color: cancelBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border)),
                child: Center(child: Text('Cancel',
                    style: TextStyle(fontSize: 13.5,
                        fontWeight: FontWeight.w600, color: textSub))),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context, true),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: red.withOpacity(0.32), width: 1),
                ),
                child: Center(child: Text('Sign Out',
                    style: TextStyle(fontSize: 13.5,
                        fontWeight: FontWeight.w700, color: red))),
              ),
            )),
          ]),
        ]),
      ),
    );
  }
}

// ─── Glow Orb ─────────────────────────────────────────────────────────────────
class _Orb extends StatelessWidget {
  final double size, opacity;
  final Color  color;
  const _Orb({required this.size, required this.color, required this.opacity});

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