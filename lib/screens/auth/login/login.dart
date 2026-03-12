import 'package:flutter/material.dart';
import '../../../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading       = false;
  bool _rememberMe      = false;

  late AnimationController _entranceController;
  late AnimationController _shimmerController;
  late List<Animation<Offset>> _slideAnims;
  late List<Animation<double>>  _fadeAnims;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Staggered entrance for 5 elements
    _slideAnims = List.generate(5, (i) {
      final start = i * 0.12;
      final end   = (start + 0.55).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.35),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });
    _fadeAnims = List.generate(5, (i) {
      final start = i * 0.12;
      final end   = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _entranceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // Simulate network call
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) setState(() => _isLoading = false);
    // TODO: Navigate to dashboard
  }

  Widget _animatedChild(int index, Widget child) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (_, __) => SlideTransition(
        position: _slideAnims[index],
        child: FadeTransition(
          opacity: _fadeAnims[index],
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ESEColors.darkNavy,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Background ──────────────────────────────────────────────
          Positioned.fill(child: _LoginBackground()),

          // ── Scrollable content ──────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                height: size.height - MediaQuery.of(context).padding.top,
                child: Column(
                  children: [
                    // ── Header section ───────────────────────────────
                    Expanded(
                      flex: 4,
                      child: _HeaderSection(
                        slideAnim: _slideAnims[0],
                        fadeAnim:  _fadeAnims[0],
                        shimmerController: _shimmerController,
                      ),
                    ),

                    // ── Card section ─────────────────────────────────
                    Expanded(
                      flex: 7,
                      child: _animatedChild(
                        1,
                        _LoginCard(
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
                          onLogin:            _handleLogin,
                          fadeAnims:          _fadeAnims,
                          slideAnims:         _slideAnims,
                          entranceController: _entranceController,
                        ),
                      ),
                    ),

                    // ── Footer ───────────────────────────────────────
                    _animatedChild(
                      4,
                      _Footer(),
                    ),
                    const SizedBox(height: 16),
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

// ─── Background ──────────────────────────────────────────────────────────────
class _LoginBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base
        Container(color: ESEColors.darkNavy),

        // Top gradient blob (blue)
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                ESEColors.primary.withOpacity(0.22),
                Colors.transparent,
              ]),
            ),
          ),
        ),

        // Bottom gradient blob (orange)
        Positioned(
          bottom: -60,
          left: -40,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                ESEColors.accent.withOpacity(0.14),
                Colors.transparent,
              ]),
            ),
          ),
        ),

        // Subtle grid
        Positioned.fill(
          child: CustomPaint(painter: _SubtleGridPainter()),
        ),

        // Candlestick chart silhouette at top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 120,
          child: CustomPaint(painter: _CandlestickPainter()),
        ),
      ],
    );
  }
}

class _SubtleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = ESEColors.primary.withOpacity(0.03)
      ..strokeWidth = 0.6;
    for (double x = 0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CandlestickPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final greenPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.12)
      ..strokeWidth = 1.5;
    final redPaint = Paint()
      ..color = const Color(0xFFEF5350).withOpacity(0.12)
      ..strokeWidth = 1.5;

    final candles = [
      (40.0,  55.0, 30.0, 65.0, true),
      (70.0,  50.0, 45.0, 72.0, true),
      (100.0, 65.0, 55.0, 70.0, false),
      (130.0, 60.0, 48.0, 80.0, true),
      (160.0, 45.0, 35.0, 65.0, false),
      (190.0, 55.0, 42.0, 68.0, true),
      (220.0, 40.0, 30.0, 58.0, true),
      (250.0, 60.0, 50.0, 75.0, false),
      (280.0, 35.0, 25.0, 55.0, true),
      (310.0, 55.0, 45.0, 70.0, true),
      (340.0, 42.0, 30.0, 60.0, false),
    ];

    for (final c in candles) {
      final paint = c.$5 ? greenPaint : redPaint;
      // Wick
      canvas.drawLine(
        Offset(c.$1, size.height - c.$4),
        Offset(c.$1, size.height - c.$2),
        paint,
      );
      // Body
      final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(c.$1 - 6, size.height - c.$4, 12,
            (c.$4 - c.$3).abs()),
        const Radius.circular(2),
      );
      canvas.drawRRect(
          body, paint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _HeaderSection extends StatelessWidget {
  final Animation<Offset> slideAnim;
  final Animation<double>  fadeAnim;
  final AnimationController shimmerController;

  const _HeaderSection({
    required this.slideAnim,
    required this.fadeAnim,
    required this.shimmerController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SlideTransition(
            position: slideAnim,
            child: FadeTransition(
              opacity: fadeAnim,
              child: Column(
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    height: 72,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _InlineLogo(),
                  ),
                  const SizedBox(height: 16),

                  // Shimmer divider
                  AnimatedBuilder(
                    animation: shimmerController,
                    builder: (_, __) {
                      return Container(
                        width: 180,
                        height: 1.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              ESEColors.accent.withOpacity(0.1),
                              ESEColors.accent,
                              ESEColors.primary,
                              ESEColors.primary.withOpacity(0.1),
                            ],
                            stops: [
                              0.0,
                              shimmerController.value,
                              (shimmerController.value + 0.3).clamp(0, 1),
                              1.0,
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),
                  Text(
                    'Member Portal',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 3.5,
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                      color: ESEColors.gold.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ESE',
          style: const TextStyle(
            fontSize: 48,
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            color: ESEColors.primary,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 3, height: 38, color: ESEColors.accent),
          ],
        ),
      ],
    );
  }
}

// ─── Login Card ───────────────────────────────────────────────────────────────
class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState>    formKey;
  final TextEditingController   emailController;
  final TextEditingController   passwordController;
  final bool                    obscurePassword;
  final bool                    rememberMe;
  final bool                    isLoading;
  final VoidCallback            onTogglePassword;
  final ValueChanged<bool?>     onToggleRemember;
  final VoidCallback            onLogin;
  final List<Animation<double>> fadeAnims;
  final List<Animation<Offset>> slideAnims;
  final AnimationController     entranceController;

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
    required this.fadeAnims,
    required this.slideAnims,
    required this.entranceController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: ESEColors.midNavy.withOpacity(0.85),
        border: Border.all(
          color: ESEColors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ESEColors.primary.withOpacity(0.12),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              _Animate(
                index: 1,
                slideAnims: slideAnims,
                fadeAnims: fadeAnims,
                controller: entranceController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold,
                        color: ESEColors.cream,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in to your trading account',
                      style: TextStyle(
                        fontSize: 13,
                        color: ESEColors.cream.withOpacity(0.45),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Email field
              _Animate(
                index: 2,
                slideAnims: slideAnims,
                fadeAnims: fadeAnims,
                controller: entranceController,
                child: _ESETextField(
                  controller: emailController,
                  label: 'Email Address',
                  hint: 'you@example.com',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your email';
                    if (!v.contains('@')) return 'Invalid email address';
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Password field
              _Animate(
                index: 3,
                slideAnims: slideAnims,
                fadeAnims: fadeAnims,
                controller: entranceController,
                child: _ESETextField(
                  controller: passwordController,
                  label: 'Password',
                  hint: '••••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscureText: obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: ESEColors.cream.withOpacity(0.4),
                      size: 20,
                    ),
                    onPressed: onTogglePassword,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your password';
                    if (v.length < 6) return 'Password too short';
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 14),

              // Remember me + Forgot password
              _Animate(
                index: 4,
                slideAnims: slideAnims,
                fadeAnims: fadeAnims,
                controller: entranceController,
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: rememberMe,
                        onChanged: onToggleRemember,
                        activeColor: ESEColors.accent,
                        checkColor: Colors.white,
                        side: BorderSide(
                          color: ESEColors.cream.withOpacity(0.3),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remember me',
                      style: TextStyle(
                        fontSize: 12,
                        color: ESEColors.cream.withOpacity(0.55),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 12,
                          color: ESEColors.lightBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Login button
              _Animate(
                index: 4,
                slideAnims: slideAnims,
                fadeAnims: fadeAnims,
                controller: entranceController,
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: _LoginButton(
                    isLoading: isLoading,
                    onPressed: onLogin,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Register link
              _Animate(
                index: 4,
                slideAnims: slideAnims,
                fadeAnims: fadeAnims,
                controller: entranceController,
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: ESEColors.cream.withOpacity(0.45),
                      ),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 13,
                                color: ESEColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Reusable text field ──────────────────────────────────────────────────────
class _ESETextField extends StatelessWidget {
  final TextEditingController controller;
  final String  label;
  final String  hint;
  final IconData icon;
  final bool    obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _ESETextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText   = false,
    this.suffixIcon,
    this.keyboardType  = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
            color: ESEColors.cream.withOpacity(0.55),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            color: ESEColors.cream,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: ESEColors.cream.withOpacity(0.2),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: ESEColors.primary.withOpacity(0.7),
              size: 18,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: ESEColors.darkNavy.withOpacity(0.6),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ESEColors.primary.withOpacity(0.15),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ESEColors.primary.withOpacity(0.15),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ESEColors.primary.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ESEColors.accent,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ESEColors.accent,
                width: 1.5,
              ),
            ),
            errorStyle: const TextStyle(
              color: ESEColors.accent,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Login button with loading state ─────────────────────────────────────────
class _LoginButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  const _LoginButton({required this.isLoading, required this.onPressed});

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) {
        return GestureDetector(
          onTap: widget.isLoading ? null : widget.onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  ESEColors.primary,
                  ESEColors.lightBlue,
                  ESEColors.primary,
                ],
                stops: [
                  0.0,
                  (_shimmer.value).clamp(0.0, 1.0),
                  1.0,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: ESEColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: widget.isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.2,
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SIGN IN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded,
                  size: 11, color: ESEColors.cream.withOpacity(0.3)),
              const SizedBox(width: 5),
              Text(
                'Secured with 256-bit SSL encryption',
                style: TextStyle(
                  fontSize: 10.5,
                  color: ESEColors.cream.withOpacity(0.3),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '© 2025 Eswatini Stock Exchange. All rights reserved.',
            style: TextStyle(
              fontSize: 9.5,
              color: ESEColors.cream.withOpacity(0.18),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Staggered animation helper ───────────────────────────────────────────────
class _Animate extends StatelessWidget {
  final int index;
  final List<Animation<Offset>> slideAnims;
  final List<Animation<double>>  fadeAnims;
  final AnimationController      controller;
  final Widget child;

  const _Animate({
    required this.index,
    required this.slideAnims,
    required this.fadeAnims,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final i = index.clamp(0, slideAnims.length - 1);
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => SlideTransition(
        position: slideAnims[i],
        child: FadeTransition(opacity: fadeAnims[i], child: child),
      ),
    );
  }
}