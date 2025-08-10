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
  bool _isPremium = false;
  bool _isLoading = false;

  // Mock data for dashboard
  final Map<String, dynamic> _progressData = {
    'testsTaken': 12,
    'questionsSolved': 346,
    'accuracy': 78.5,
    'streak': 7,
    'targetScore': 1500,
    'currentScore': 1320,
  };

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
    // In a real app, this would navigate to purchase screen
    setState(() => _isPremium = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Premium features unlocked!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
        // Enhanced App Bar
        SliverAppBar(
        expandedHeight: 220,
        floating: false,
        pinned: true,
        backgroundColor: theme.colorScheme.primary,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(bottom: 16, left: 16),
          title: Text(
            widget.userData['username'] ?? 'User Profile',
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white
            ),
          ),
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.7),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
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
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.userData['email'] ?? 'user@example.com',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              _buildAccountStatusBadge(theme),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16, right: 8),
                        child: ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('Log Out'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.white.withOpacity(0.5)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // Main content
      SliverToBoxAdapter(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Dashboard Header
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Study Dashboard',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildProgressCard(
                  context,
                  icon: Icons.assignment,
                  label: 'Tests Taken',
                  value: _progressData['testsTaken'].toString(),
                  color: Colors.blue,
                ),
                _buildProgressCard(
                  context,
                  icon: Icons.check_circle,
                  label: 'Questions Solved',
                  value: _progressData['questionsSolved'].toString(),
                  color: Colors.green,
                ),
                _buildProgressCard(
                  context,
                  icon: Icons.trending_up,
                  label: 'Accuracy',
                  value: '${_progressData['accuracy']}%',
                  color: Colors.orange,
                ),
                _buildProgressCard(
                  context,
                  icon: Icons.local_fire_department,
                  label: 'Current Streak',
                  value: '${_progressData['streak']} days',
                  color: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Score Progress Card
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Score Progress',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Chip(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          label: Text(
                            '${_progressData['currentScore']}/${_progressData['targetScore']}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: _progressData['currentScore'] / _progressData['targetScore'],
                      minHeight: 16,
                      backgroundColor: Colors.grey[200],
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Score',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${_progressData['currentScore']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Target Score',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${_progressData['targetScore']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_progressData['targetScore'] - _progressData['currentScore']} points to reach your target',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Premium Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Premium Features',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!_isPremium)
                  TextButton(
                    onPressed: _navigateToPremium,
                    child: const Text('Upgrade Now'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Unlock advanced features to boost your preparation',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // Premium Features Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3,
              children: [
                _buildFeatureChip(
                  context,
                  icon: Icons.analytics,
                  title: 'Advanced Analytics',
                  isLocked: !_isPremium,
                ),
                _buildFeatureChip(
                  context,
                  icon: Icons.timeline,
                  title: 'Study Roadmap',
                  isLocked: !_isPremium,
                ),
                _buildFeatureChip(
                  context,
                  icon: Icons.assignment,
                  title: 'Weekly Tests',
                  isLocked: !_isPremium,
                ),
                _buildFeatureChip(
                  context,
                  icon: Icons.library_books,
                  title: 'Question Bank',
                  isLocked: !_isPremium,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Upgrade Card - Only show if not premium
            if (!_isPremium)
        GestureDetector(
        onTap: _navigateToPremium,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Go Premium',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Full access to all features',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '\$14.99',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: '/month',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'SAVE 25%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _navigateToPremium,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Get Premium',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),)
        ],
      ),
    ),
    ),
    ],
    ),
    );
  }

  Widget _buildAccountStatusBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isPremium
            ? Colors.amber[800]!.withOpacity(0.2)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isPremium ? Colors.amber : Colors.white,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isPremium)
            Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 6),
          Text(
            _isPremium ? 'PREMIUM MEMBER' : 'FREE ACCOUNT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _isPremium ? Colors.amber : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
      }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(
      BuildContext context, {
        required IconData icon,
        required String title,
        required bool isLocked,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: isLocked ? Colors.grey : Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isLocked ? Colors.grey : null,
              ),
            ),
          ),
          if (isLocked)
            Icon(Icons.lock_outline, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}