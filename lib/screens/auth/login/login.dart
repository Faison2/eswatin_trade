import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading       = false;
  bool _rememberMe      = false;

  late AnimationController _entranceCtrl;
  late AnimationController _bgCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _tickerCtrl;

  late Animation<double> _bgAnim;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoFadeAnim;
  late Animation<double> _cardFadeAnim;
  late Animation<Offset> _cardSlideAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _tickerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);

    _logoScaleAnim = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _logoFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    _cardFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
      ),
    );

    _cardSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _glowAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 60), _entranceCtrl.forward);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _entranceCtrl.dispose();
    _bgCtrl.dispose();
    _logoCtrl.dispose();
    _tickerCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) setState(() => _isLoading = false);
    // TODO: Navigate to dashboard
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF060C1A),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Animated dark background ────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnim,
              builder: (_, __) => CustomPaint(
                painter: _PremiumBgPainter(t: _bgAnim.value),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Top hero: logo + branding ──────────────────
                Expanded(
                  flex: 38,
                  child: _LogoHero(
                    logoScaleAnim: _logoScaleAnim,
                    logoFadeAnim:  _logoFadeAnim,
                    glowAnim:      _glowAnim,
                    bgAnim:        _bgAnim,
                    tickerAnim:    _tickerCtrl,
                    size:          size,
                  ),
                ),

                // ── Bottom card ───────────────────────────────
                Expanded(
                  flex: 62,
                  child: FadeTransition(
                    opacity: _cardFadeAnim,
                    child: SlideTransition(
                      position: _cardSlideAnim,
                      child: _LoginCard(
                        formKey:            _formKey,
                        emailController:    _emailController,
                        passwordController: _passwordController,
                        obscurePassword:    _obscurePassword,
                        rememberMe:         _rememberMe,
                        isLoading:          _isLoading,
                        onTogglePassword:   () => setState(
                                () => _obscurePassword = !_obscurePassword),
                        onToggleRemember:   (v) => setState(
                                () => _rememberMe = v ?? false),
                        onLogin: _handleLogin,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Logo Hero Section ────────────────────────────────────────────────────────
class _LogoHero extends StatelessWidget {
  final Animation<double> logoScaleAnim;
  final Animation<double> logoFadeAnim;
  final Animation<double> glowAnim;
  final Animation<double> bgAnim;
  final AnimationController tickerAnim;
  final Size size;

  const _LogoHero({
    required this.logoScaleAnim,
    required this.logoFadeAnim,
    required this.glowAnim,
    required this.bgAnim,
    required this.tickerAnim,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated rings behind logo
        AnimatedBuilder(
          animation: glowAnim,
          builder: (_, __) => CustomPaint(
            size: Size(size.width, double.infinity),
            painter: _RingsPainter(glow: glowAnim.value),
          ),
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Full logo display ──────────────────────────────
            FadeTransition(
              opacity: logoFadeAnim,
              child: ScaleTransition(
                scale: logoScaleAnim,
                child: AnimatedBuilder(
                  animation: glowAnim,
                  builder: (_, child) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4A030)
                              .withOpacity(0.45 * glowAnim.value),
                          blurRadius: 60,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: const Color(0xFF1565C0)
                              .withOpacity(0.30 * glowAnim.value),
                          blurRadius: 40,
                          spreadRadius: -4,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: child,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 150,
                      height: 150,
                    //  fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _FallbackLogo(),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Exchange name & tagline ────────────────────────
            FadeTransition(
              opacity: logoFadeAnim,
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFF5D98B),
                        Color(0xFFFFFFFF),
                        Color(0xFFD4A030),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      'ESWATINI STOCK EXCHANGE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 3.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Gold shimmer divider
                  AnimatedBuilder(
                    animation: bgAnim,
                    builder: (_, __) => Container(
                      width: 200,
                      height: 1.5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          colors: const [
                            Colors.transparent,
                            Color(0xFFD4A030),
                            Color(0xFFF5D98B),
                            Color(0xFFD4A030),
                            Colors.transparent,
                          ],
                          stops: [
                            0.0,
                            (bgAnim.value * 0.4).clamp(0.0, 0.4),
                            bgAnim.value.clamp(0.0, 1.0),
                            ((bgAnim.value * 0.4) + 0.5).clamp(0.0, 1.0),
                            1.0,
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Member Portal',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 4,
                      color: Colors.white.withOpacity(0.38),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Live ticker at bottom of hero
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _TickerBar(animation: tickerAnim),
        ),
      ],
    );
  }
}

// ─── Fallback Logo ────────────────────────────────────────────────────────────
class _FallbackLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 148,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1A33), Color(0xFF1A2F55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFD4A030).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFFF5D98B), Color(0xFFD4A030)],
          ).createShader(b),
          child: const Text(
            'ESE',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 5,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Ticker Bar ───────────────────────────────────────────────────────────────
class _TickerBar extends StatelessWidget {
  final Animation<double> animation;
  const _TickerBar({required this.animation});

  static const _stocks = [
    ('SWAZIL', '+1.8%', true),  ('RNB', '-0.5%', false),
    ('AFB', '+3.2%', true),     ('SBC', '-1.2%', false),
    ('NEL', '+0.9%', true),     ('MFL', '+2.7%', true),
    ('SGS', '-0.8%', false),    ('SVCB', '+1.1%', true),
    ('SWBP', '-1.9%', false),   ('GRYS', '+4.0%', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.55),
            Colors.black.withOpacity(0.55),
            Colors.transparent,
          ],
          stops: const [0.0, 0.08, 0.92, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) {
          return ClipRect(
            child: OverflowBox(
              maxWidth: double.infinity,
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: Offset(-animation.value * 560, 0),
                child: Row(
                  children: List.generate(4, (_) => _stocks)
                      .expand((e) => e)
                      .map((s) => Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          s.$1,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFCCCCCC),
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: s.$3
                                ? const Color(0xFF1B5E20)
                                .withOpacity(0.7)
                                : const Color(0xFF7F0000)
                                .withOpacity(0.7),
                          ),
                          child: Text(
                            s.$2,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: s.$3
                                  ? const Color(0xFF69F0AE)
                                  : const Color(0xFFFF8A80),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 1,
                          height: 10,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ],
                    ),
                  ))
                      .toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Login Card ───────────────────────────────────────────────────────────────
class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState>  formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool                  obscurePassword;
  final bool                  rememberMe;
  final bool                  isLoading;
  final VoidCallback          onTogglePassword;
  final ValueChanged<bool?>   onToggleRemember;
  final VoidCallback          onLogin;

  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onToggleRemember,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F3EC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          // Subtle top-right decorative corner accent
          Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(110, 110),
              painter: _CornerAccentPainter(),
            ),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Drag handle ──────────────────────────────
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: const Color(0xFF0A1628).withOpacity(0.15),
                        ),
                      ),
                    ),

                    // ── Heading row ──────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF09152A),
                                  letterSpacing: -1,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Access your investment account',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7C7C8E),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Market open pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF0A1628),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _PulsingDot(),
                              const SizedBox(width: 5),
                              const Text(
                                'LIVE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF69F0AE),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Email ────────────────────────────────────
                    _Label('EMAIL ADDRESS'),
                    const SizedBox(height: 8),
                    _Field(
                      controller: emailController,
                      hint: 'you@example.com',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // ── Password ─────────────────────────────────
                    _Label('PASSWORD'),
                    const SizedBox(height: 8),
                    _Field(
                      controller: passwordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: obscurePassword,
                      suffixIcon: GestureDetector(
                        onTap: onTogglePassword,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            key: ValueKey(obscurePassword),
                            color: const Color(0xFFAAAAAA),
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        if (v.length < 6) return 'Min. 6 characters';
                        return null;
                      },
                    ),

                    const SizedBox(height: 10),

                    // ── Remember / Forgot ────────────────────────
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: rememberMe,
                            onChanged: onToggleRemember,
                            activeColor: const Color(0xFFB8922A),
                            checkColor: Colors.white,
                            side: const BorderSide(
                                color: Color(0xFFBBBBCC), width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Remember me',
                          style: TextStyle(
                              fontSize: 12.5, color: Color(0xFF7C7C8E)),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFFB8922A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Sign in button ───────────────────────────
                    _SignInButton(
                        isLoading: isLoading, onPressed: onLogin),

                    const SizedBox(height: 12),

                    // ── Divider ──────────────────────────────────
                    Row(children: [
                      Expanded(
                        child: Divider(
                          color: const Color(0xFF09152A).withOpacity(0.10),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or',
                          style: TextStyle(
                            fontSize: 11.5,
                            color:
                            const Color(0xFF9A9AAB).withOpacity(0.6),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: const Color(0xFF09152A).withOpacity(0.10),
                          thickness: 1,
                        ),
                      ),
                    ]),

                    const SizedBox(height: 12),

                    // ── Register CTA ─────────────────────────────
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFB8922A).withOpacity(0.28),
                            width: 1.5,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFB8922A).withOpacity(0.06),
                              const Color(0xFFD4A030).withOpacity(0.03),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0D1A33),
                                    Color(0xFF142444),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0D1A33)
                                        .withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_rounded,
                                color: Color(0xFFD4A030),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF09152A),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Begin your investment journey today',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF9A9AAB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Color(0xFFB8922A),
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Footer ───────────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shield_outlined,
                                  size: 10,
                                  color: const Color(0xFF9A9AAB)
                                      .withOpacity(0.45)),
                              const SizedBox(width: 5),
                              Text(
                                '256-bit SSL secured',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: const Color(0xFF9A9AAB)
                                      .withOpacity(0.45),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '© 2025 Eswatini Stock Exchange. All rights reserved.',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: const Color(0xFF9A9AAB).withOpacity(0.3),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pulsing green dot ─────────────────────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.lerp(
            const Color(0xFF69F0AE).withOpacity(0.5),
            const Color(0xFF69F0AE),
            _anim.value,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF69F0AE).withOpacity(0.5 * _anim.value),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Field label ──────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 9.5,
      fontWeight: FontWeight.w800,
      color: Color(0xFF555568),
      letterSpacing: 1.5,
    ),
  );
}

// ─── Input Field ──────────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText  = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF09152A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        const TextStyle(color: Color(0xFFBBBBCC), fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(icon, color: const Color(0xFFAAAABB), size: 20),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: Color(0xFFE8E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: Color(0xFFB8922A), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: Color(0xFFEF5350), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: Color(0xFFEF5350), width: 2),
        ),
        errorStyle: const TextStyle(
            color: Color(0xFFEF5350), fontSize: 11),
      ),
    );
  }
}

// ─── Sign In Button ───────────────────────────────────────────────────────────
class _SignInButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  const _SignInButton({required this.isLoading, required this.onPressed});

  @override
  State<_SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<_SignInButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: 0.965)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF09152A), Color(0xFF152240)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0xFFD4A030).withOpacity(0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF09152A).withOpacity(0.55),
                blurRadius: 24,
                offset: const Offset(0, 10),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: const Color(0xFFD4A030).withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.isLoading
              ? const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFF5D98B)],
                ).createShader(b),
                child: const Text(
                  'SIGN  IN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 3.5,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD4A030).withOpacity(0.15),
                  border: Border.all(
                    color: const Color(0xFFD4A030).withOpacity(0.35),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFFD4A030),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Background painter ───────────────────────────────────────────────────────
class _PremiumBgPainter extends CustomPainter {
  final double t;
  _PremiumBgPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    // Deep navy base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF060C1A), Color(0xFF0A1426), Color(0xFF060C1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Subtle dot grid
    final dotP = Paint()
      ..color = const Color(0xFFD4A030).withOpacity(0.035)
      ..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += 30) {
      for (double y = 0; y < size.height * 0.55; y += 30) {
        final d = math.sin((x + y + t * 80) * 0.038) * 1.6;
        canvas.drawCircle(Offset(x, y + d), 1.0, dotP);
      }
    }

    // Animated flowing chart line
    final linePaint = Paint()
      ..color = const Color(0xFFD4A030).withOpacity(0.07)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final baseY = size.height * 0.44;
    path.moveTo(0, baseY);
    for (int i = 0; i <= 30; i++) {
      final x = i * (size.width / 30);
      final y = baseY +
          math.sin(i * 0.7 + t * math.pi * 2) * 20 +
          math.cos(i * 0.4 + t * math.pi) * 12;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, linePaint);

    // Second subtler chart line
    final linePaint2 = Paint()
      ..color = const Color(0xFF1565C0).withOpacity(0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final path2 = Path();
    final baseY2 = size.height * 0.38;
    path2.moveTo(0, baseY2);
    for (int i = 0; i <= 30; i++) {
      final x = i * (size.width / 30);
      final y = baseY2 +
          math.sin(i * 0.5 + t * math.pi * 1.5 + 1.2) * 15 +
          math.cos(i * 0.8 + t * math.pi * 0.7) * 10;
      path2.lineTo(x, y);
    }
    canvas.drawPath(path2, linePaint2);

    // Thin horizontal grid lines
    final gridP = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 0.6;
    for (double y = 30; y < size.height * 0.5; y += 38) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridP);
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumBgPainter old) => old.t != t;
}

// ─── Rings painter ────────────────────────────────────────────────────────────
class _RingsPainter extends CustomPainter {
  final double glow;
  _RingsPainter({required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (int i = 3; i >= 1; i--) {
      final r = 90.0 + i * 46;
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = const Color(0xFFD4A030).withOpacity(0.028 * glow * (4 - i))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) => old.glow != glow;
}

// ─── Corner accent painter ────────────────────────────────────────────────────
class _CornerAccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.6)
      ..quadraticBezierTo(
          size.width * 0.6, size.height * 0.3, 0, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFD4A030).withOpacity(0.055)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}