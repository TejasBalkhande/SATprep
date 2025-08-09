// profile_screen.dart
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
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFFC8E6C9);
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color secondaryColor = Color(0xFF81C784);
  static const Color accentColor = Color(0xFF7CB342);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color errorColor = Color(0xFFD32F2F);

  bool _isPremium = false;
  bool _isLoading = false;

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('My Account', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column - Account Info
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Info Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryLight,
                                  border: Border.all(color: primaryColor, width: 2),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.userData['username'] ?? 'User Name',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      widget.userData['email'] ?? 'user@example.com',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildAccountStatusBadge(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _logout,
                              icon: _isLoading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                                  : const Icon(Icons.logout),
                              label: const Text('Log Out'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: errorColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: errorColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Premium Features Section
                  const Text(
                    'Premium Features',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Upgrade to unlock all features and maximize your SAT prep',
                    style: TextStyle(
                      fontSize: 16,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Feature Cards
                  _buildFeatureCard(
                    icon: Icons.analytics,
                    title: 'Advanced Progress Tracking',
                    description: 'Detailed analytics and performance insights',
                    isLocked: !_isPremium,
                  ),
                  _buildFeatureCard(
                    icon: Icons.timeline,
                    title: 'Personalized Study Roadmap',
                    description: 'AI-powered study plan tailored to your goals',
                    isLocked: !_isPremium,
                  ),
                  _buildFeatureCard(
                    icon: Icons.assignment,
                    title: 'Weekly Full-Length Tests',
                    description: '8 full-length exams with detailed explanations',
                    isLocked: !_isPremium,
                  ),
                  _buildFeatureCard(
                    icon: Icons.library_books,
                    title: 'Unlimited Question Bank',
                    description: '12,000+ practice questions with video solutions',
                    isLocked: !_isPremium,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 30),

            // Right Column - Premium Membership
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Premium Membership',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryDark,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$29.99',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          '/month',
                          style: TextStyle(
                            fontSize: 16,
                            color: textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$19.99/month',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const Text(' if billed annually'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Includes all premium features:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildFeatureItem('Full access to all practice tests'),
                    _buildFeatureItem('Detailed performance analytics'),
                    _buildFeatureItem('Personalized study roadmap'),
                    _buildFeatureItem('Priority support'),
                    _buildFeatureItem('Weekly progress reports'),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Upgrade to Premium',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isPremium ? primaryColor.withOpacity(0.2) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isPremium ? primaryColor : Colors.grey,
        ),
      ),
      child: Text(
        _isPremium ? 'PREMIUM MEMBER' : 'FREE ACCOUNT',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _isPremium ? primaryDark : textSecondary,
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isLocked,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isLocked ? textSecondary : primaryColor,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isLocked ? textSecondary : textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isLocked ? Colors.grey : textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              const Icon(Icons.lock, color: Colors.grey, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}