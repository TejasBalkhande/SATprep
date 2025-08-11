import 'package:flutter/material.dart';
import 'package:cfdptest/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileScreen({
    super.key,
    required this.userData,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isPremium = false;
  bool _isLoading = false;

  // Color palette
  static const Color primaryColor = Color(0xFF2B463C);
  static const Color secondaryColor = Color(0xFF4A7C59);
  static const Color accentColor = Color(0xFF8FCB9B);
  static const Color surfaceColor = Color(0xFFF5F9F2);
  static const Color backgroundColor = Color(0xFFF8F9F5);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF444444);
  static const Color prizeGold = Color(0xFFD4AF37);
  static const Color lightGreen = Color(0xFFE6F4EA);
  static const Color cardColor = Colors.white;

  // Typography
  static const String fontFamily = 'Inter';

  TextStyle get headlineLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: primaryColor,
  );

  TextStyle get headlineMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: secondaryColor,
  );

  TextStyle get bodyLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    color: textSecondary,
  );

  TextStyle get titleMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: primaryColor,
  );

  TextStyle get labelLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  void _navigateToPremium() {
    setState(() => _isPremium = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Premium features unlocked!'),
        backgroundColor: secondaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Custom Header - Adjusted layout
          Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryColor,
                  const Color(0xFF3A5E4A),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: fontFamily,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile icon
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                                color: Colors.white,
                                width: 2
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.userData['username'] ?? 'User',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  _buildAccountStatusBadge(),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.userData['email'] ?? 'user@example.com',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isLargeScreen
                  ? _buildDesktopLayout()
                  : _buildMobileLayout(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column - Account Card and Stats
          Expanded(
            flex: 5,
            child: Column(
              children: [
                _buildAccountCard(),
                const SizedBox(height: 16),
                _buildStatsSection(),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Right Column - Premium Section
          Expanded(
            flex: 5,
            child: Column(
              children: [
                if (!_isPremium) _buildPremiumCard(),
                if (_isPremium) _buildPremiumStatus(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAccountCard(),
          const SizedBox(height: 16),
          _buildStatsSection(),
          const SizedBox(height: 16),
          if (!_isPremium) _buildPremiumCard(),
          if (_isPremium) _buildPremiumStatus(),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Account Details',
                style: headlineLarge.copyWith(fontSize: 22),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey, size: 22),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Account Status
          _buildDetailItem(
            title: 'Account Status',
            value: _isPremium ? 'Premium' : 'Free',
            icon: Icons.verified_user,
            color: _isPremium ? prizeGold : secondaryColor,
          ),

          const Divider(height: 32, color: Color(0xFFEEEEEE)),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, size: 18),
              label: Text(
                'Log Out',
                style: labelLarge.copyWith(fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2B463C),
            Color(0xFF3A5E4A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars, color: prizeGold, size: 28),
              const SizedBox(width: 10),
              Text(
                'Unlock Premium',
                style: headlineMedium.copyWith(
                    fontSize: 18,
                    color: Colors.white
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Get full access to all features and resources',
            style: bodyLarge.copyWith(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9)
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '\$14.99',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: '/month',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: prizeGold,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'SAVE 25%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: _navigateToPremium,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: prizeGold,
                    foregroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'Get Premium',
                      style: labelLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor),
      ),
      child: Row(
        children: [
          Icon(Icons.verified, color: prizeGold, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Member',
                  style: headlineMedium.copyWith(
                      fontSize: 18,
                      color: primaryColor
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Full access to all premium features',
                  style: bodyLarge.copyWith(
                      fontSize: 14,
                      color: textSecondary
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Your Activity',
                  style: headlineLarge.copyWith(fontSize: 22)
              ),
              Text(
                'Last 30 days',
                style: bodyLarge.copyWith(
                    fontSize: 14,
                    color: textSecondary
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('24', 'Courses', Icons.school),
              _buildStatItem('87%', 'Progress', Icons.trending_up),
              _buildStatItem('12', 'Achievements', Icons.emoji_events),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: lightGreen.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 26, color: secondaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isPremium
            ? prizeGold.withOpacity(0.15)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isPremium ? prizeGold : Colors.white,
        ),
      ),
      child: Text(
        _isPremium ? 'PREMIUM MEMBER' : 'FREE ACCOUNT',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _isPremium ? prizeGold : Colors.white,
        ),
      ),
    );
  }
}