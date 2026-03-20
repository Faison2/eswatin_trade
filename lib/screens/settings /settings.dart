import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ─────────────────────────────────────────────────────────────────────────────
// THEME NOTIFIER  (put this in a shared file; import where needed)
// ─────────────────────────────────────────────────────────────────────────────
class AppThemeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;
  bool get isLight => _mode == ThemeMode.light;

  AppThemeNotifier() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getString('theme_mode') ?? 'dark';
    _mode = saved == 'light' ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  Future<void> toggle() async {
    _mode = isLight ? ThemeMode.dark : ThemeMode.light;
    final p = await SharedPreferences.getInstance();
    await p.setString('theme_mode', isLight ? 'light' : 'dark');
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME TOKENS
// ─────────────────────────────────────────────────────────────────────────────
class _Dark {
  static const bg        = Color(0xFF060C1A);
  static const surface   = Color(0xFF0D1728);
  static const card      = Color(0xFF111F35);
  static const border    = Color(0xFF1E2E45);
  static const gold      = Color(0xFFD4A030);
  static const goldLight = Color(0xFFF5D98B);
  static const teal      = Color(0xFF26A69A);
  static const red       = Color(0xFFEF5350);
  static const textPrim  = Color(0xFFEEF2FF);
  static const textSub   = Color(0xFF7A8BA8);
  static const textMuted = Color(0xFF3D5470);
  static const inputFill = Color(0xFF0D1728);
}

class _Light {
  static const bg        = Color(0xFFF0F4FB);
  static const surface   = Color(0xFFFFFFFF);
  static const card      = Color(0xFFFFFFFF);
  static const border    = Color(0xFFDDE3EF);
  static const gold      = Color(0xFFC49020);
  static const goldLight = Color(0xFF8B6010);
  static const teal      = Color(0xFF1A8A80);
  static const red       = Color(0xFFD43F3C);
  static const textPrim  = Color(0xFF0D1728);
  static const textSub   = Color(0xFF64748B);
  static const textMuted = Color(0xFFADB5C7);
  static const inputFill = Color(0xFFF8FAFD);
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  final AppThemeNotifier themeNotifier;

  const SettingsScreen({super.key, required this.themeNotifier});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  // Profile
  String _fullName  = '';
  String _email     = '';
  String _cdsNumber = '';
  String _initials  = '';
  String _token     = '';

  // Change password form
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl      = TextEditingController();
  final _confirmPwCtrl  = TextEditingController();

  bool _showCurrent = false;
  bool _showNew     = false;
  bool _showConfirm = false;
  bool _pwLoading   = false;
  String? _pwError;
  String? _pwSuccess;

  // Active section for accordion feel
  bool _pwExpanded = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
    widget.themeNotifier.addListener(_rebuild);
    _loadProfile();
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _ctrl.dispose();
    widget.themeNotifier.removeListener(_rebuild);
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _fullName  = p.getString('full_name')      ?? 'ESE Member';
      _email     = p.getString('email')           ?? '—';
      _cdsNumber = p.getString('cds_number')      ?? '—';
      _token     = p.getString('session_token')   ?? '';
      final f    = p.getString('forenames')       ?? '';
      final s    = p.getString('surname')         ?? '';
      _initials  = '${f.isNotEmpty ? f[0] : ''}${s.isNotEmpty ? s[0] : ''}'
          .toUpperCase();
      if (_initials.isEmpty) _initials = 'U';
    });
  }

  // ── Colours resolved by theme ──────────────────────────────────────────────
  bool get _isLight => widget.themeNotifier.isLight;

  Color get _bg        => _isLight ? _Light.bg        : _Dark.bg;
  Color get _surface   => _isLight ? _Light.surface   : _Dark.surface;
  Color get _card      => _isLight ? _Light.card      : _Dark.card;
  Color get _border    => _isLight ? _Light.border    : _Dark.border;
  Color get _gold      => _isLight ? _Light.gold      : _Dark.gold;
  Color get _goldLight => _isLight ? _Light.goldLight : _Dark.goldLight;
  Color get _teal      => _isLight ? _Light.teal      : _Dark.teal;
  Color get _red       => _isLight ? _Light.red       : _Dark.red;
  Color get _textPrim  => _isLight ? _Light.textPrim  : _Dark.textPrim;
  Color get _textSub   => _isLight ? _Light.textSub   : _Dark.textSub;
  Color get _textMuted => _isLight ? _Light.textMuted : _Dark.textMuted;
  Color get _inputFill => _isLight ? _Light.inputFill : _Dark.inputFill;

  // ── Change password ────────────────────────────────────────────────────────
  Future<void> _changePassword() async {
    setState(() { _pwError = null; _pwSuccess = null; });

    if (_currentPwCtrl.text.isEmpty ||
        _newPwCtrl.text.isEmpty ||
        _confirmPwCtrl.text.isEmpty) {
      setState(() => _pwError = 'All fields are required.');
      return;
    }
    if (_newPwCtrl.text.length < 8) {
      setState(() => _pwError = 'New password must be at least 8 characters.');
      return;
    }
    if (_newPwCtrl.text != _confirmPwCtrl.text) {
      setState(() => _pwError = 'New passwords do not match.');
      return;
    }

    setState(() => _pwLoading = true);
    try {
      // Replace with your real change-password endpoint
      final res = await http.post(
        Uri.parse('https://app.trading-ese.com/eseapi/Home/ChangePassword'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type':  'application/json',
        },
        body: jsonEncode({
          'OldPassword': _currentPwCtrl.text,
          'NewPassword': _newPwCtrl.text,
        }),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200 && data['responseCode'] == 200) {
        setState(() {
          _pwSuccess = 'Password updated successfully.';
          _pwLoading = false;
        });
        _currentPwCtrl.clear();
        _newPwCtrl.clear();
        _confirmPwCtrl.clear();
      } else {
        setState(() {
          _pwError   = data['responseMessage']?.toString() ??
              'Failed to update password.';
          _pwLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _pwError   = 'Network error. Please try again.';
        _pwLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
      _isLight ? Brightness.dark : Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 12,
              bottom: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── Profile card ─────────────────────────────────────────
                _profileCard(),

                const SizedBox(height: 24),
                _sectionLabel('APPEARANCE'),
                const SizedBox(height: 8),

                // ── Theme toggle ─────────────────────────────────────────
                _themeToggleCard(),

                const SizedBox(height: 24),
                _sectionLabel('SECURITY'),
                const SizedBox(height: 8),

                // ── Change password card ─────────────────────────────────
                _changePasswordCard(),

                const SizedBox(height: 24),
                _sectionLabel('ABOUT'),
                const SizedBox(height: 8),

                // ── App info ─────────────────────────────────────────────
                _infoCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── App Bar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: _bg.withOpacity(0.80),
              border: Border(
                  bottom: BorderSide(color: _border.withOpacity(0.5))),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _border),
                        boxShadow: _isLight ? [
                          BoxShadow(color: Colors.black.withOpacity(0.06),
                              blurRadius: 8, offset: const Offset(0, 2)),
                        ] : [],
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: _textSub, size: 15),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('Settings',
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _textPrim, letterSpacing: 0.2)),
                    ),
                  ),
                  // Spacer to balance the back button
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section label ────────────────────────────────────────────────────────────
  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Text(label,
          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700,
              color: _textMuted, letterSpacing: 1.4)),
    );
  }

  // ── Profile card ─────────────────────────────────────────────────────────────
  Widget _profileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(children: [
        // Avatar
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFD4A030), Color(0xFF8B5E10)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [BoxShadow(
                color: _gold.withOpacity(0.30),
                blurRadius: 14, offset: const Offset(0, 3))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isLight ? const Color(0xFFFFF8EE) : const Color(0xFF0D1A33),
              ),
              child: Center(
                child: Text(_initials,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                        color: _gold, letterSpacing: 0.5)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Info
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_fullName,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                    color: _textPrim, letterSpacing: 0.1)),
            const SizedBox(height: 3),
            Text(_email, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: _textSub)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _gold.withOpacity(_isLight ? 0.08 : 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _gold.withOpacity(0.22)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.credit_card_rounded,
                    color: _gold.withOpacity(0.75), size: 11),
                const SizedBox(width: 6),
                Text(_cdsNumber,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                        color: _isLight ? _Light.goldLight : _Dark.goldLight,
                        letterSpacing: 0.5)),
              ]),
            ),
          ],
        )),
      ]),
    );
  }

  // ── Theme toggle card ─────────────────────────────────────────────────────────
  Widget _themeToggleCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _cardDecoration(),
      child: Column(children: [
        _toggleRow(
          icon: _isLight ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          iconColor: _isLight ? const Color(0xFFE8A020) : const Color(0xFF7CB9F5),
          title: _isLight ? 'Light Mode' : 'Dark Mode',
          subtitle: _isLight
              ? 'Switch to dark for low-light viewing'
              : 'Switch to light for bright environments',
          value: _isLight,
          activeColor: _isLight ? const Color(0xFFE8A020) : const Color(0xFF26A69A),
          onChanged: (_) => widget.themeNotifier.toggle(),
          isLast: false,
        ),
        Divider(height: 1, color: _border),
        _previewRow(),
      ]),
    );
  }

  Widget _previewRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(children: [
        Icon(Icons.palette_outlined, color: _textMuted, size: 16),
        const SizedBox(width: 12),
        Expanded(child: Text('Preview',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                color: _textSub))),
        // Mini theme preview chips
        Row(children: [
          _previewChip(
            label: 'Dark',
            active: !_isLight,
            bg: const Color(0xFF060C1A),
            fg: const Color(0xFFEEF2FF),
            accent: const Color(0xFFD4A030),
            onTap: () {
              if (_isLight) widget.themeNotifier.toggle();
            },
          ),
          const SizedBox(width: 8),
          _previewChip(
            label: 'Light',
            active: _isLight,
            bg: const Color(0xFFF0F4FB),
            fg: const Color(0xFF0D1728),
            accent: const Color(0xFFC49020),
            onTap: () {
              if (!_isLight) widget.themeNotifier.toggle();
            },
          ),
        ]),
      ]),
    );
  }

  Widget _previewChip({
    required String label,
    required bool active,
    required Color bg,
    required Color fg,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? accent : _border,
            width: active ? 1.5 : 1,
          ),
          boxShadow: active ? [
            BoxShadow(color: accent.withOpacity(0.25),
                blurRadius: 8, offset: const Offset(0, 2))
          ] : [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 8, height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: accent)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: fg)),
        ]),
      ),
    );
  }

  // ── Change password card ──────────────────────────────────────────────────────
  Widget _changePasswordCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row (accordion toggle)
        GestureDetector(
          onTap: () => setState(() {
            _pwExpanded = !_pwExpanded;
            _pwError    = null;
            _pwSuccess  = null;
          }),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: _teal.withOpacity(_isLight ? 0.09 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _teal.withOpacity(0.25)),
                ),
                child: Icon(Icons.lock_outline_rounded,
                    color: _teal, size: 15),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Change Password',
                        style: TextStyle(fontSize: 13.5,
                            fontWeight: FontWeight.w700, color: _textPrim)),
                    const SizedBox(height: 2),
                    Text('Update your account password',
                        style: TextStyle(fontSize: 10.5, color: _textSub)),
                  ])),
              AnimatedRotation(
                turns: _pwExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    color: _teal, size: 22),
              ),
            ]),
          ),
        ),

        // Expandable form
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: _pwExpanded
              ? Column(children: [
            Divider(height: 1, color: _border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(children: [
                // Status messages
                if (_pwError != null) ...[
                  _statusBanner(
                      message: _pwError!,
                      isError: true),
                  const SizedBox(height: 12),
                ],
                if (_pwSuccess != null) ...[
                  _statusBanner(
                      message: _pwSuccess!,
                      isError: false),
                  const SizedBox(height: 12),
                ],

                _passwordField(
                  controller: _currentPwCtrl,
                  label: 'Current Password',
                  hint: 'Enter your current password',
                  show: _showCurrent,
                  onToggle: () =>
                      setState(() => _showCurrent = !_showCurrent),
                ),
                const SizedBox(height: 12),
                _passwordField(
                  controller: _newPwCtrl,
                  label: 'New Password',
                  hint: 'Min. 8 characters',
                  show: _showNew,
                  onToggle: () =>
                      setState(() => _showNew = !_showNew),
                ),
                const SizedBox(height: 12),
                _passwordField(
                  controller: _confirmPwCtrl,
                  label: 'Confirm New Password',
                  hint: 'Re-enter new password',
                  show: _showConfirm,
                  onToggle: () =>
                      setState(() => _showConfirm = !_showConfirm),
                ),
                const SizedBox(height: 18),

                // Submit button
                GestureDetector(
                  onTap: _pwLoading ? null : _changePassword,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isLight
                            ? [const Color(0xFF1A6A64),
                          const Color(0xFF26A69A)]
                            : [const Color(0xFF0D3330),
                          const Color(0xFF155250)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _teal.withOpacity(0.40), width: 1),
                      boxShadow: [
                        BoxShadow(color: _teal.withOpacity(0.22),
                            blurRadius: 14, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Center(
                      child: _pwLoading
                          ? SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _isLight
                                  ? Colors.white : _teal))
                          : Text('Update Password',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _isLight
                                  ? Colors.white
                                  : _teal,
                              letterSpacing: 0.3)),
                    ),
                  ),
                ),
              ]),
            ),
          ])
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool show,
    required VoidCallback onToggle,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700,
              color: _teal, letterSpacing: 0.5)),
      const SizedBox(height: 7),
      Container(
        height: 46,
        decoration: BoxDecoration(
          color: _inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
          boxShadow: _isLight ? [
            BoxShadow(color: Colors.black.withOpacity(0.04),
                blurRadius: 6, offset: const Offset(0, 2)),
          ] : [],
        ),
        child: Row(children: [
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: !show,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                  color: _textPrim),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontSize: 13, color: _textMuted,
                    fontWeight: FontWeight.w400),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(show ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
                  color: _textMuted, size: 17),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _statusBanner({required String message, required bool isError}) {
    final color = isError ? _red : _teal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(children: [
        Icon(isError ? Icons.error_outline_rounded
            : Icons.check_circle_outline_rounded,
            color: color, size: 15),
        const SizedBox(width: 8),
        Expanded(child: Text(message,
            style: TextStyle(fontSize: 12, color: color,
                fontWeight: FontWeight.w500))),
      ]),
    );
  }

  // ── App info card ─────────────────────────────────────────────────────────────
  Widget _infoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _cardDecoration(),
      child: Column(children: [
        _infoRow(Icons.info_outline_rounded, 'App Version', '1.0.0'),
        Divider(height: 1, color: _border),
        _infoRow(Icons.gavel_rounded, 'Terms of Service', null,
            trailing: Icon(Icons.open_in_new_rounded,
                color: _textMuted, size: 13),
            onTap: () {}),
        Divider(height: 1, color: _border),
        _infoRow(Icons.privacy_tip_outlined, 'Privacy Policy', null,
            trailing: Icon(Icons.open_in_new_rounded,
                color: _textMuted, size: 13),
            onTap: () {}),
        Divider(height: 1, color: _border),
        _infoRow(Icons.business_rounded, 'ESE – Eswatini Stock Exchange', null),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String title, String? value, {
    Widget? trailing, VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
        child: Row(children: [
          Icon(icon, color: _textMuted, size: 16),
          const SizedBox(width: 12),
          Expanded(child: Text(title,
              style: TextStyle(fontSize: 13, color: _textSub,
                  fontWeight: FontWeight.w500))),
          if (value != null)
            Text(value,
                style: TextStyle(fontSize: 13, color: _textPrim,
                    fontWeight: FontWeight.w700)),
          if (trailing != null) trailing,
        ]),
      ),
    );
  }

  // ── Toggle row ────────────────────────────────────────────────────────────────
  Widget _toggleRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
    required bool isLast,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: iconColor.withOpacity(0.25)),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700,
                      color: _textPrim)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(fontSize: 10.5, color: _textSub)),
            ])),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor,
          inactiveThumbColor: _textMuted,
          inactiveTrackColor: _border,
        ),
      ]),
    );
  }

  // ── Shared card decoration ────────────────────────────────────────────────────
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _border),
      boxShadow: _isLight
          ? [BoxShadow(color: Colors.black.withOpacity(0.07),
          blurRadius: 16, offset: const Offset(0, 4))]
          : [BoxShadow(color: Colors.black.withOpacity(0.18),
          blurRadius: 10, offset: const Offset(0, 3))],
    );
  }
}