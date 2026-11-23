import 'dart:ui';
import 'package:flutter/material.dart';

const Color _primaryTextColor = Color(0xFFF1F5F9);
const Color _mutedTextColor = Color(0xFF8FA0BF);
const Color _brandAccent = Color(0xFF5CC8FF);
const Color _cardBorderColor = Color(0xFF2A3D66);
const List<Color> _cardGradient = [Color(0xCC1C2A4A), Color(0xCC101A30)];
const List<Color> _tileGradient = [Color(0xFF3D7BFF), Color(0xFF1E4FD8)];

class UserSelectionContent extends StatelessWidget {
  final VoidCallback onAdminSelected;
  final VoidCallback onDriverSelected;

  const UserSelectionContent({
    super.key,
    required this.onAdminSelected,
    required this.onDriverSelected,
  });

  Widget buildHero() {
    return const _FloatingLogo();
  }

  Widget buildTitle() {
    return const Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Driver', style: TextStyle(color: _primaryTextColor)),
          TextSpan(text: 'Hub', style: TextStyle(color: _brandAccent)),
        ],
      ),
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    );
  }

  Widget buildSubtitle() {
    return const Text(
      'Choose how you want to continue',
      style: TextStyle(fontSize: 14, color: _mutedTextColor),
    );
  }

  Widget buildRoleCard(IconData icon, String label, String description, VoidCallback onTap) {
    const radius = BorderRadius.all(Radius.circular(22));
    return Container(
      decoration: const BoxDecoration(
        borderRadius: radius,
        boxShadow: [BoxShadow(color: Color(0x88000000), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: _cardBorderColor),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _cardGradient,
                ),
              ),
              child: InkWell(
                borderRadius: radius,
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _tileGradient,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x662F6BFF),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(icon, size: 28, color: Colors.white),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: _primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              description,
                              style: const TextStyle(fontSize: 12.5, color: _mutedTextColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0x0FFFFFFF),
                        ),
                        child: const Icon(Icons.chevron_right, size: 18, color: Color(0xFFB6C6E6)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAdminButton() {
    return buildRoleCard(
      Icons.admin_panel_settings_outlined,
      'Admin',
      'Manage drivers, vehicles and trips',
      onAdminSelected,
    );
  }

  Widget buildDriverButton() {
    return buildRoleCard(
      Icons.directions_car_outlined,
      'Driver',
      'View the trips assigned to you',
      onDriverSelected,
    );
  }

  Widget buildFooter() {
    const line = SizedBox(
      width: 28,
      height: 1,
      child: ColoredBox(color: _cardBorderColor),
    );
    return const Padding(
      padding: EdgeInsets.only(top: 18, bottom: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          line,
          SizedBox(width: 10),
          Text('Every journey matters', style: TextStyle(fontSize: 12, color: Color(0xFF5F7092))),
          SizedBox(width: 10),
          line,
        ],
      ),
    );
  }

  Widget buildContent(double topGap) {
    return Column(
      children: [
        SizedBox(height: topGap),
        buildHero(),
        const SizedBox(height: 18),
        buildTitle(),
        const SizedBox(height: 6),
        buildSubtitle(),
        const SizedBox(height: 52),
        buildAdminButton(),
        const SizedBox(height: 14),
        buildDriverButton(),
        const Spacer(),
        buildFooter(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Logo + name start just below the map (about 40% down the screen)
        final topGap = constraints.maxHeight * 0.40;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(child: buildContent(topGap)),
          ),
        );
      },
    );
  }
}

/// App logo with a soft glow and a gentle floating animation.
class _FloatingLogo extends StatefulWidget {
  const _FloatingLogo();

  @override
  State<_FloatingLogo> createState() => _FloatingLogoState();
}

class _FloatingLogoState extends State<_FloatingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dy = -5 * Curves.easeInOut.transform(_controller.value);
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(color: Color(0x662F6BFF), blurRadius: 40, offset: Offset(0, 12)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Image.asset('lib/assets/app_icon.png', fit: BoxFit.cover),
        ),
      ),
    );
  }
}
