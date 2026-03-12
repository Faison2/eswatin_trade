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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  bool _biometricsEnabled = true;
  bool _priceAlerts       = true;
  bool _orderUpdates      = true;
  bool _newsletter        = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
          Positioned(top: -40, right: -60,
              child: _GlowOrb(size: 240, color: _C.gold, opacity: 0.06)),
          Positioned(top: 320, left: -80,
              child: _GlowOrb(size: 200, color: _C.blue, opacity: 0.07)),
          Positioned(bottom: 80, right: -40,
              child: _GlowOrb(size: 160, color: _C.teal, opacity: 0.05)),
          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
                  bottom: 48,
                ),
                child: Column(
                  children: [
                    const _AvatarHero(),
                    const SizedBox(height: 24),
                    const _KpiStrip(),
                    const SizedBox(height: 28),

                    _SectionHeader(title: 'Account Information'),
                    _InfoGroup(tiles: [
                      _InfoTileData(icon: Icons.badge_outlined,
                          label: 'Full Name', value: 'John Doe'),
                      _InfoTileData(icon: Icons.email_outlined,
                          label: 'Email', value: 'john.doe@ese.et'),
                      _InfoTileData(icon: Icons.phone_outlined,
                          label: 'Phone', value: '+251 91 234 5678'),
                      _InfoTileData(icon: Icons.credit_card_outlined,
                          label: 'Member ID', value: 'ESE-20240389'),
                    ]),
                    const SizedBox(height: 20),

                    _SectionHeader(title: 'Verification'),
                    _VerificationCard(),
                    const SizedBox(height: 20),

                    _SectionHeader(title: 'Security'),
                    _TileGroup(children: [
                      _ToggleTile(
                        icon: Icons.fingerprint_rounded,
                        label: 'Biometric Login',
                        sub: 'Use fingerprint or face ID',
                        value: _biometricsEnabled,
                        onChanged: (v) =>
                            setState(() => _biometricsEnabled = v),
                      ),
                      const _TileDivider(),
                      _ActionTile(
                        icon: Icons.lock_outline_rounded,
                        label: 'Change PIN',
                        sub: 'Last changed 30 days ago',
                        onTap: () {},
                      ),
                      const _TileDivider(),
                      _ActionTile(
                        icon: Icons.shield_outlined,
                        label: 'Two-Factor Authentication',
                        sub: 'Enabled via authenticator app',
                        badge: 'ON', badgeColor: _C.teal,
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 20),

                    _SectionHeader(title: 'Notifications'),
                    _TileGroup(children: [
                      _ToggleTile(
                        icon: Icons.trending_up_rounded,
                        label: 'Price Alerts',
                        sub: 'Notify on watchlist moves',
                        value: _priceAlerts,
                        onChanged: (v) => setState(() => _priceAlerts = v),
                      ),
                      const _TileDivider(),
                      _ToggleTile(
                        icon: Icons.receipt_long_outlined,
                        label: 'Order Updates',
                        sub: 'Confirmations & fills',
                        value: _orderUpdates,
                        onChanged: (v) => setState(() => _orderUpdates = v),
                      ),
                      const _TileDivider(),
                      _ToggleTile(
                        icon: Icons.campaign_outlined,
                        label: 'ESE Newsletter',
                        sub: 'Weekly market digest',
                        value: _newsletter,
                        onChanged: (v) => setState(() => _newsletter = v),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    _SectionHeader(title: 'Support & Legal'),
                    _TileGroup(children: [
                      _ActionTile(
                        icon: Icons.headset_mic_outlined,
                        label: 'Contact Support',
                        sub: 'Chat or call 24/7',
                        onTap: () {},
                      ),
                      const _TileDivider(),
                      _ActionTile(
                        icon: Icons.description_outlined,
                        label: 'Terms & Conditions',
                        sub: 'Updated Jan 2026',
                        onTap: () {},
                      ),
                      const _TileDivider(),
                      _ActionTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        sub: 'How we handle your data',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 28),

                    _SignOutButton(),
                    const SizedBox(height: 12),
                    Text('ESE Trading App  •  v2.4.1',
                        style: TextStyle(fontSize: 9.5,
                            color: _C.textMuted, letterSpacing: 0.5)),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: _C.bg.withOpacity(0.60),
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
            title: const Text('Profile',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: _C.textPrim, letterSpacing: 0.2)),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.border, width: 1),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: _C.textSub, size: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Avatar Hero ──────────────────────────────────────────────────────────────
class _AvatarHero extends StatelessWidget {
  const _AvatarHero();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 92, height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                border: Border.all(
                    color: _C.gold.withOpacity(0.45), width: 2.5),
                boxShadow: [BoxShadow(color: _C.gold.withOpacity(0.22),
                    blurRadius: 28, offset: const Offset(0, 6))],
              ),
              child: const Center(
                child: Text('JD', style: TextStyle(fontSize: 30,
                    fontWeight: FontWeight.w900, color: Colors.white,
                    letterSpacing: 1)),
              ),
            ),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: _C.teal,
                  border: Border.all(color: _C.bg, width: 2.5)),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 12),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text('John Doe',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800,
                color: _C.textPrim, letterSpacing: -0.3)),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Badge(icon: Icons.workspace_premium_rounded,
                label: 'Premium Trader', color: _C.gold),
            const SizedBox(width: 8),
            _Badge(icon: Icons.verified_rounded,
                label: 'KYC Verified', color: _C.teal),
          ],
        ),
        const SizedBox(height: 6),
        Text('Member since March 2022',
            style: TextStyle(fontSize: 10.5, color: _C.textMuted)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.30), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 11),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 10,
            fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

// ─── KPI Strip ────────────────────────────────────────────────────────────────
class _KpiStrip extends StatelessWidget {
  const _KpiStrip();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(color: _C.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.border, width: 1)),
      child: Row(children: const [
        _Kpi(label: 'Total Trades', value: '284'),
        _KpiDiv(),
        _Kpi(label: 'Win Rate', value: '67%', valueColor: _C.teal),
        _KpiDiv(),
        _Kpi(label: 'Total Return', value: '+14.6%', valueColor: _C.teal),
        _KpiDiv(),
        _Kpi(label: 'Rank', value: '#38', valueColor: _C.gold),
      ]),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _Kpi({required this.label, required this.value, this.valueColor});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
          color: valueColor ?? _C.textPrim, letterSpacing: -0.3)),
      const SizedBox(height: 3),
      Text(label, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 8.5,
              color: _C.textSub, letterSpacing: 0.4)),
    ]),
  );
}

class _KpiDiv extends StatelessWidget {
  const _KpiDiv();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: _C.border);
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(children: [
        Text(title.toUpperCase(),
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700,
                color: _C.textMuted, letterSpacing: 1.2)),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: _C.border)),
      ]),
    );
  }
}

// ─── Tile Group ───────────────────────────────────────────────────────────────
class _TileGroup extends StatelessWidget {
  final List<Widget> children;
  const _TileGroup({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _C.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.border, width: 1)),
      child: ClipRRect(borderRadius: BorderRadius.circular(18),
          child: Column(children: children)),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: _C.border.withOpacity(0.5),
          margin: const EdgeInsets.only(left: 58));
}

// ─── Info Group ───────────────────────────────────────────────────────────────
class _InfoTileData {
  final IconData icon;
  final String label, value;
  const _InfoTileData(
      {required this.icon, required this.label, required this.value});
}

class _InfoGroup extends StatelessWidget {
  final List<_InfoTileData> tiles;
  const _InfoGroup({required this.tiles});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _C.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.border, width: 1)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: tiles.asMap().entries.map((e) {
            final isLast = e.key == tiles.length - 1;
            return Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                child: Row(children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                        color: _C.gold.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(e.value.icon,
                        color: _C.gold.withOpacity(0.75), size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.value.label,
                          style: const TextStyle(fontSize: 9.5,
                              color: _C.textSub, letterSpacing: 0.4)),
                      const SizedBox(height: 2),
                      Text(e.value.value,
                          style: const TextStyle(fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: _C.textPrim)),
                    ],
                  )),
                ]),
              ),
              if (!isLast)
                Container(height: 1,
                    color: _C.border.withOpacity(0.5),
                    margin: const EdgeInsets.only(left: 58)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Action Tile ──────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label,
    required this.sub, this.badge, this.badgeColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
                color: _C.blue.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: _C.blue.withOpacity(0.85), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13.5,
                  fontWeight: FontWeight.w600, color: _C.textPrim)),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(
                  fontSize: 10, color: _C.textSub)),
            ],
          )),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (badgeColor ?? _C.teal).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: (badgeColor ?? _C.teal).withOpacity(0.30),
                    width: 1),
              ),
              child: Text(badge!, style: TextStyle(fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: badgeColor ?? _C.teal, letterSpacing: 0.5)),
            )
          else
            const Icon(Icons.chevron_right_rounded,
                color: _C.textMuted, size: 18),
        ]),
      ),
    );
  }
}

// ─── Toggle Tile ──────────────────────────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.icon, required this.label,
    required this.sub, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: _C.teal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: _C.teal.withOpacity(0.80), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13.5,
                fontWeight: FontWeight.w600, color: _C.textPrim)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(
                fontSize: 10, color: _C.textSub)),
          ],
        )),
        Transform.scale(
          scale: 0.80,
          child: Switch(
            value: value, onChanged: onChanged,
            activeColor: _C.gold,
            activeTrackColor: _C.gold.withOpacity(0.25),
            inactiveThumbColor: _C.textMuted,
            inactiveTrackColor: _C.surface,
          ),
        ),
      ]),
    );
  }
}

// ─── Verification Card ────────────────────────────────────────────────────────
enum _VerifState { done, pending, todo }

class _VerificationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _C.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.border, width: 1)),
      child: Column(children: [
        _VerifStep(icon: Icons.person_outline_rounded,
            label: 'Identity Verified', sub: 'National ID uploaded',
            state: _VerifState.done),
        const SizedBox(height: 12),
        _VerifStep(icon: Icons.home_outlined,
            label: 'Address Verified', sub: 'Utility bill accepted',
            state: _VerifState.done),
        const SizedBox(height: 12),
        _VerifStep(icon: Icons.account_balance_outlined,
            label: 'Bank Account Linked', sub: 'CBE ****4832',
            state: _VerifState.done),
        const SizedBox(height: 12),
        _VerifStep(icon: Icons.workspace_premium_outlined,
            label: 'Upgrade to Premium', sub: 'Tap to explore benefits',
            state: _VerifState.pending),
      ]),
    );
  }
}

class _VerifStep extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final _VerifState state;
  const _VerifStep({required this.icon, required this.label,
    required this.sub, required this.state});

  @override
  Widget build(BuildContext context) {
    final color = state == _VerifState.done
        ? _C.teal
        : state == _VerifState.pending ? _C.gold : _C.textMuted;
    return Row(children: [
      Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 16),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13,
              fontWeight: FontWeight.w600, color: _C.textPrim)),
          Text(sub, style: const TextStyle(
              fontSize: 10, color: _C.textSub)),
        ],
      )),
      Icon(
        state == _VerifState.done
            ? Icons.check_circle_rounded
            : state == _VerifState.pending
            ? Icons.chevron_right_rounded
            : Icons.radio_button_unchecked_rounded,
        color: color,
        size: state == _VerifState.done ? 20 : 18,
      ),
    ]);
  }
}

// ─── Sign Out Button ──────────────────────────────────────────────────────────
class _SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
          context: context, builder: (_) => _SignOutDialog()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 52,
        decoration: BoxDecoration(
          color: _C.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.red.withOpacity(0.28), width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: _C.red, size: 18),
            SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w700, color: _C.red,
                letterSpacing: 0.3)),
          ],
        ),
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _C.border, width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.50),
              blurRadius: 40, offset: const Offset(0, 16))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: _C.red.withOpacity(0.10), shape: BoxShape.circle,
              border: Border.all(color: _C.red.withOpacity(0.25), width: 1.5),
            ),
            child: const Icon(Icons.logout_rounded, color: _C.red, size: 24),
          ),
          const SizedBox(height: 16),
          const Text('Sign Out?', style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.w800, color: _C.textPrim)),
          const SizedBox(height: 8),
          const Text('You will be logged out of your ESE account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: _C.textSub)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 46,
                decoration: BoxDecoration(color: _C.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border, width: 1)),
                child: const Center(child: Text('Cancel',
                    style: TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w600, color: _C.textSub))),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                // TODO: auth sign-out
              },
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: _C.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _C.red.withOpacity(0.35), width: 1),
                ),
                child: const Center(child: Text('Sign Out',
                    style: TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w700, color: _C.red))),
              ),
            )),
          ]),
        ]),
      ),
    );
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