import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class _C {
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
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  // ── SharedPreferences data ────────────────────────────────────────────────
  String _fullName  = '';
  String _forenames = '';
  String _surname   = '';
  String _email     = '';
  String _phone     = '';
  String _cdsNumber = '';
  String _initials  = '';
  bool   _loading   = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
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
          '${_surname.isNotEmpty   ? _surname[0]   : ''}'
          .toUpperCase();
      if (_initials.isEmpty) _initials = 'U';
      _loading = false;
    });
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _SignOutDialog(),
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    if (_loading) {
      return const Scaffold(
        backgroundColor: _C.bg,
        body: Center(
          child: CircularProgressIndicator(color: _C.gold, strokeWidth: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _C.bg,
      extendBodyBehindAppBar: true,
      appBar: _AppBar(onBack: () => Navigator.pop(context)),
      body: Stack(children: [
        Positioned(top: -60, right: -80,
            child: _Orb(size: 280, color: _C.gold, opacity: 0.055)),
        Positioned(top: 260, left: -100,
            child: _Orb(size: 220, color: _C.blue, opacity: 0.065)),

        FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight + 12,
                bottom: 48,
              ),
              child: Column(children: [

                // ── Hero avatar card ──────────────────────────────────
                _HeroCard(
                    initials: _initials,
                    fullName: _fullName,
                    email:    _email),

                const SizedBox(height: 28),

                // ── Section label ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Row(children: [
                    const Text('ACCOUNT DETAILS',
                        style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: _C.textSub,
                            letterSpacing: 1.8)),
                    const SizedBox(width: 12),
                    Expanded(child: Container(height: 1, color: _C.border)),
                  ]),
                ),

                // ── Details card ──────────────────────────────────────
                _DetailsCard(fields: [
                  _Field(Icons.person_rounded,      'First Name',  _forenames),
                  _Field(Icons.person_outline,      'Surname',     _surname),
                  _Field(Icons.email_outlined,      'Email',       _email),
                  _Field(Icons.phone_outlined,      'Phone',       _phone),
                  _Field(Icons.credit_card_rounded, 'CDS Number',  _cdsNumber),
                ]),

                const SizedBox(height: 36),

                _SignOutBtn(onTap: _signOut),

                const SizedBox(height: 16),
                Text('© 2025 Eswatini Stock Exchange',
                    style: TextStyle(fontSize: 9.5,
                        color: _C.textDim, letterSpacing: 0.4)),
                const SizedBox(height: 8),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  const _AppBar({required this.onBack});
  @override Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          color: _C.bg.withOpacity(0.55),
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
                      color: _C.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _C.border),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: _C.textSub, size: 14),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text('My Profile',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _C.textPrim,
                            letterSpacing: 0.2)),
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
  const _HeroCard({required this.initials, required this.fullName, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.border, width: 1),
        boxShadow: [
          BoxShadow(
              color: _C.gold.withOpacity(0.07),
              blurRadius: 40,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(children: [

        // ── Avatar with gold ring ───────────────────────────────────
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
              BoxShadow(color: _C.gold.withOpacity(0.35),
                  blurRadius: 32, spreadRadius: 2),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF0D1A33), Color(0xFF142444)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(initials,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: _C.goldSoft,
                        letterSpacing: 2)),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(fullName,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _C.textPrim,
                letterSpacing: -0.3)),

        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.border),
          ),
          child: Text(email,
              style: const TextStyle(fontSize: 11.5, color: _C.textSub)),
        ),

        const SizedBox(height: 20),

        // ── Gold shimmer divider ────────────────────────────────────
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent,
              _C.gold.withOpacity(0.40),
              Colors.transparent,
            ]),
          ),
        ),

        const SizedBox(height: 18),

        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.verified_rounded,
              color: _C.gold.withOpacity(0.85), size: 14),
          const SizedBox(width: 6),
          const Text('ESE MEMBER',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _C.gold,
                  letterSpacing: 2.5)),
        ]),
      ]),
    );
  }
}

// ─── Field model ──────────────────────────────────────────────────────────────
class _Field {
  final IconData icon;
  final String   label;
  final String   value;
  const _Field(this.icon, this.label, this.value);
}

// ─── Details Card ─────────────────────────────────────────────────────────────
class _DetailsCard extends StatelessWidget {
  final List<_Field> fields;
  const _DetailsCard({required this.fields});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border, width: 1),
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
                      color: _C.gold.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _C.gold.withOpacity(0.15), width: 1),
                    ),
                    child: Icon(f.icon,
                        color: _C.gold.withOpacity(0.70), size: 16),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.label,
                            style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: _C.textSub,
                                letterSpacing: 0.8)),
                        const SizedBox(height: 3),
                        Text(f.value,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _C.textPrim)),
                      ],
                    ),
                  ),
                ]),
              ),
              if (!isLast)
                Container(
                    height: 1,
                    color: _C.border.withOpacity(0.6),
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
  const _SignOutBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 50,
        decoration: BoxDecoration(
          color: _C.red.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.red.withOpacity(0.25), width: 1),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.logout_rounded,
              color: _C.red.withOpacity(0.85), size: 17),
          const SizedBox(width: 8),
          Text('Sign Out',
              style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _C.red.withOpacity(0.85),
                  letterSpacing: 0.3)),
        ]),
      ),
    );
  }
}

// ─── Sign Out Dialog ──────────────────────────────────────────────────────────
class _SignOutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _C.border, width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.55),
                blurRadius: 48, offset: const Offset(0, 20))
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: _C.red.withOpacity(0.09),
              shape: BoxShape.circle,
              border: Border.all(color: _C.red.withOpacity(0.22), width: 1.5),
            ),
            child: const Icon(Icons.logout_rounded, color: _C.red, size: 22),
          ),
          const SizedBox(height: 16),
          const Text('Sign Out?',
              style: TextStyle(fontSize: 17,
                  fontWeight: FontWeight.w800, color: _C.textPrim)),
          const SizedBox(height: 8),
          Text('You will be returned to the login screen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: _C.textSub.withOpacity(0.75))),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                    color: _C.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border)),
                child: const Center(
                  child: Text('Cancel',
                      style: TextStyle(fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: _C.textSub)),
                ),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context, true),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: _C.red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _C.red.withOpacity(0.32), width: 1),
                ),
                child: const Center(
                  child: Text('Sign Out',
                      style: TextStyle(fontSize: 13.5,
                          fontWeight: FontWeight.w700, color: _C.red)),
                ),
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