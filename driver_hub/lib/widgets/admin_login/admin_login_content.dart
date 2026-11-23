import 'dart:ui';

import 'package:flutter/material.dart';

import '../../configs/app_theme.dart';

const Color _mutedTextColor = Color(0xFF8FA0BF);
const Color _brandAccent = Color(0xFF5CC8FF);
const Color _lineColor = Color(0xFF2A3D66);
const List<Color> _buttonGradient = [Color(0xFF3D7BFF), Color(0xFF1E4FD8)];
const List<Color> _glassGradient = [Color(0xCC1C2A4A), Color(0xCC101A30)];

class AdminLoginContent extends StatelessWidget {
  final String role;
  final VoidCallback handleGoogleSignIn;
  final VoidCallback? handleAdminRegistration;

  const AdminLoginContent({
    super.key,
    required this.role,
    required this.handleGoogleSignIn,
    this.handleAdminRegistration,
  });

  // Role-specific heading
  String get screenTitle {
    return role == 'admin' ? 'Admin' : 'Driver';
  }

  // Role-specific icon
  IconData get screenIcon {
    return role == 'admin' ? Icons.admin_panel_settings_outlined : Icons.directions_car_outlined;
  }

  // Main icon badge
  Widget buildIconBadge() {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _buttonGradient,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x222F6BFF), spreadRadius: 6),
          BoxShadow(color: Color(0x772F6BFF), blurRadius: 40, offset: Offset(0, 14)),
        ],
      ),
      child: Icon(screenIcon, size: 42, color: Colors.white),
    );
  }

  // Small brand label above the title
  Widget buildBrandLabel() {
    return const Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'DRIVER', style: TextStyle(color: Color(0xFFE6EEFF))),
          TextSpan(text: 'HUB', style: TextStyle(color: _brandAccent)),
        ],
      ),
      style: TextStyle(fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.w600),
    );
  }

  // Screen heading and subtitle
  Widget buildHeader() {
    return Column(
      children: [
        buildIconBadge(),
        const SizedBox(height: 20),
        buildBrandLabel(),
        const SizedBox(height: 6),
        Text(
          screenTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 6),
        const Text('Sign in to continue', style: TextStyle(fontSize: 14, color: _mutedTextColor)),
      ],
    );
  }

  // Google authentication button
  Widget buildLoginButton() {
    const radius = BorderRadius.all(Radius.circular(18));
    return Container(
      width: double.infinity,
      height: 56,
      decoration: const BoxDecoration(
        borderRadius: radius,
        boxShadow: [BoxShadow(color: Color(0x552F6BFF), blurRadius: 28, offset: Offset(0, 10))],
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: const BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _buttonGradient,
            ),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: handleGoogleSignIn,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Text(
                    'G',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Login with Google',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // OR divider
  Widget buildOrDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: _lineColor, thickness: 1),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text('or', style: TextStyle(fontSize: 13, color: _mutedTextColor)),
        ),
        const Expanded(
          child: Divider(color: _lineColor, thickness: 1),
        ),
      ],
    );
  }

  // Admin registration button
  Widget buildRegistrationButton() {
    if (role != 'admin' || handleAdminRegistration == null) {
      return const SizedBox.shrink();
    }

    const radius = BorderRadius.all(Radius.circular(18));
    return Container(
      width: double.infinity,
      height: 56,
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
                border: Border.all(color: _lineColor),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _glassGradient,
                ),
              ),
              child: InkWell(
                borderRadius: radius,
                onTap: handleAdminRegistration,
                child: const Center(
                  child: Text(
                    'Register admin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Authentication actions
  Widget buildActionButtons() {
    return Column(
      children: [
        buildLoginButton(),
        if (role == 'admin') ...[
          const SizedBox(height: 14),
          buildOrDivider(),
          const SizedBox(height: 14),
          buildRegistrationButton(),
        ],
      ],
    );
  }

  Widget buildFooter() {
    const line = SizedBox(
      width: 28,
      height: 1,
      child: ColoredBox(color: _lineColor),
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Icon badge starts just below the map. The driver screen has fewer
        // buttons, so its content sits lower to balance the empty space.
        final topGap = constraints.maxHeight * (role == 'admin' ? 0.40 : 0.46);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  SizedBox(height: topGap),
                  buildHeader(),
                  const SizedBox(height: 34),
                  buildActionButtons(),
                  const Spacer(),
                  buildFooter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
