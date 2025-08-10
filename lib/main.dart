import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cfdptest/screens/login_screen.dart';
import 'package:cfdptest/screens/signup_screen.dart';
import 'package:cfdptest/screens/profile_screen.dart';
import 'package:cfdptest/mock_practice.dart';

void main() => runApp(const SATPrepApp());

class SATPrepApp extends StatelessWidget {
  const SATPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAT Prep Pro',
      theme: _buildLightTheme(),
      themeMode: ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SATPrepHomePage(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/profile': (context) {
          final userData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          return ProfileScreen(userData: userData);
        },
        '/mock-practice': (context) => const MockPracticeScreen(),
      },
    );
  }

  ThemeData _buildLightTheme() {
    const primaryColor = Color(0xFF2B463C); // Deep forest green
    const secondaryColor = Color(0xFF4A7C59); // Vibrant emerald green
    const accentColor = Color(0xFF8FCB9B);    // Soft mint green
    const surfaceColor = Color(0xFFF5F9F2);  // Light green tinted surface
    const backgroundColor = Color(0xFFF8F9F5); // Off-white with green undertone
    const errorColor = Color(0xFFE57373);     // Soft red for errors

    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF333333),
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: primaryColor,
          letterSpacing: -1.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: secondaryColor,
          letterSpacing: -0.8,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          height: 1.6,
          color: Color(0xFF444444),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: secondaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: secondaryColor.withOpacity(0.3),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 3,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        color: surfaceColor,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      useMaterial3: true,
      fontFamily: 'Inter',
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 20,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class SATPrepHomePage extends StatelessWidget {
  const SATPrepHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final loggedIn = userData != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SAT Prep Pro', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                _buildNavButton(context, 'Mock Practice', Icons.assignment),
                _buildNavButton(context, 'Practice', Icons.school),
                _buildNavButton(context, 'Colleges', Icons.account_balance),
                _buildNavButton(context, 'Doubts', Icons.help_outline),
                _buildAccountButton(context, loggedIn, userData),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeroSection(),
            const SizedBox(height: 40),
            const KeyFeaturesSection(),
            const SizedBox(height: 40),
            const PracticeBySection(),
            const SizedBox(height: 40),
            const RankingCountdownSection(),
            const SizedBox(height: 40),
            const QuickNavigationSection(),
            const SizedBox(height: 40),
            ProgressTrackerSection(isLoggedIn: loggedIn),
            const SizedBox(height: 40),
            const TestimonialsSection(),
            const SizedBox(height: 40),
            const FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, IconData icon) {
    return TextButton.icon(
      onPressed: () => Navigator.pushNamed(context, '/${title.toLowerCase().replaceAll(' ', '-')}'),
      icon: Icon(icon, color: Colors.white),
      label: Text(title, style: const TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  Widget _buildAccountButton(BuildContext context, bool loggedIn, Map<String, dynamic>? userData) {
    return IconButton(
      icon: const Row(
        children: [
          Icon(Icons.account_circle, color: Colors.white),
          SizedBox(width: 8),
          Text('Account', style: TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
      onPressed: () => loggedIn
          ? Navigator.pushNamed(
        context,
        '/profile',
        arguments: userData,
      )
          : Navigator.pushNamed(context, '/login'),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const NetworkImage(
            'https://images.unsplash.com/photo-1509062522246-3755977927d7?auto=format&fit=crop&w=1200&q=80',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            const Color(0xFF2B463C).withOpacity(0.7),
            BlendMode.darken,
          ),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ace the SAT – Your Path to Top Scores Starts Here',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Expert-led lessons, realistic mock tests, and proven strategies to boost your score',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(context, '/mock-test'),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                      Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Start a Mock Test',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/study-plans'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side:
                      const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'View Study Plans',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KeyFeaturesSection extends StatelessWidget {
  const KeyFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Why Choose SAT Prep Pro?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Our proven approach helps students achieve their target scores',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          LayoutBuilder(
            builder: (context, constraints) {
              return constraints.maxWidth < 600
                  ? const MobileFeatureGrid()
                  : const DesktopFeatureGrid();
            },
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A7C59), Color(0xFF8FCB9B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A7C59).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DesktopFeatureGrid extends StatelessWidget {
  const DesktopFeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FeatureCard(
            icon: Icons.assignment,
            title: 'Full-Length Mock Tests',
            description: 'Simulate real SAT exam conditions with timed, realistic tests that mirror the actual testing experience',
          ),
        ),
        Expanded(
          child: FeatureCard(
            icon: Icons.timeline,
            title: 'Personalized Study Roadmaps',
            description: 'Custom learning paths based on your strengths and weaknesses to maximize your study efficiency',
          ),
        ),
        Expanded(
          child: FeatureCard(
            icon: Icons.menu_book,
            title: 'Section-Wise Drills',
            description: 'Targeted practice for Math, Reading, and Writing sections with detailed explanations',
          ),
        ),
        Expanded(
          child: FeatureCard(
            icon: Icons.analytics,
            title: 'Performance Analytics',
            description: 'Track progress, accuracy, speed, and improvement trends with comprehensive dashboards',
          ),
        ),
      ],
    );
  }
}

class MobileFeatureGrid extends StatelessWidget {
  const MobileFeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        FeatureCard(
          icon: Icons.assignment,
          title: 'Full-Length Mock Tests',
          description: 'Simulate real exam conditions with timed tests',
        ),
        SizedBox(height: 20),
        FeatureCard(
          icon: Icons.school,
          title: 'Personalized Study Plans',
          description: 'Custom plans based on your strengths & weaknesses',
        ),
        SizedBox(height: 20),
        FeatureCard(
          icon: Icons.analytics,
          title: 'Detailed Analytics',
          description: 'Performance insights to target weak areas',
        ),
        SizedBox(height: 20),
        FeatureCard(
          icon: Icons.lightbulb,
          title: 'Expert Strategies',
          description: 'Proven techniques from top SAT coaches',
        ),
      ],
    );
  }
}

class PracticeBySection extends StatelessWidget {
  const PracticeBySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book, size: 32, color: Color(0xFF4A7C59)),
              const SizedBox(width: 12),
              Text(
                'Practice by SAT Section',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a section and dive into targeted mock tests',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return const Column(
                  children: [
                    SectionCard(
                      icon: Icons.calculate,
                      title: 'Math',
                      description: 'Algebra, problem solving, advanced math concepts',
                      topics: [
                        'Heart of Algebra',
                        'Problem Solving & Data Analysis',
                        'Passport to Advanced Math',
                        'Additional Topics in Math'
                      ],
                      buttonText: 'Start Math Mock Test',
                    ),
                    SizedBox(height: 20),
                    SectionCard(
                      icon: Icons.auto_stories,
                      title: 'Reading',
                      description: 'Comprehension and analysis of various passages',
                      topics: [
                        'Literature Passages',
                        'History/Social Studies Passages',
                        'Science Passages',
                        'Evidence-Based Reading Questions'
                      ],
                      buttonText: 'Start Reading Mock Test',
                    ),
                    SizedBox(height: 20),
                    SectionCard(
                      icon: Icons.edit,
                      title: 'Writing & Language',
                      description: 'Grammar, sentence structure, and editing skills',
                      topics: [
                        'Grammar & Usage',
                        'Sentence Structure',
                        'Style & Tone Improvement',
                        'Punctuation Rules'
                      ],
                      buttonText: 'Start Writing Mock Test',
                    ),
                  ],
                );
              } else {
                return const Row(
                  children: [
                    Expanded(
                      child: SectionCard(
                        icon: Icons.calculate,
                        title: 'Math',
                        description: 'Algebra, problem solving, advanced math concepts',
                        topics: [
                          'Heart of Algebra',
                          'Problem Solving & Data Analysis',
                          'Passport to Advanced Math',
                          'Additional Topics in Math'
                        ],
                        buttonText: 'Start Math Mock Test',
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: SectionCard(
                        icon: Icons.auto_stories,
                        title: 'Reading',
                        description: 'Comprehension and analysis of various passages',
                        topics: [
                          'Literature Passages',
                          'History/Social Studies Passages',
                          'Science Passages',
                          'Evidence-Based Reading Questions'
                        ],
                        buttonText: 'Start Reading Mock Test',
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: SectionCard(
                        icon: Icons.edit,
                        title: 'Writing & Language',
                        description: 'Grammar, sentence structure, and editing skills',
                        topics: [
                          'Grammar & Usage',
                          'Sentence Structure',
                          'Style & Tone Improvement',
                          'Punctuation Rules'
                        ],
                        buttonText: 'Start Writing Mock Test',
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> topics;
  final String buttonText;

  const SectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.topics,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 36, color: const Color(0xFF4A7C59)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 24,
                    color: const Color(0xFF2B463C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            const Text(
              'What\'s Included:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2B463C),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            ...topics.map((topic) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, size: 18, color: Color(0xFF4A7C59)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      topic,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )).toList(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RankingCountdownSection extends StatefulWidget {
  const RankingCountdownSection({super.key});

  @override
  State<RankingCountdownSection> createState() =>
      _RankingCountdownSectionState();
}

class _RankingCountdownSectionState extends State<RankingCountdownSection> {
  late DateTime _nextEvent;
  Duration _remaining = Duration.zero;
  late Timer _timer;
  bool _eventLive = false;

  @override
  void initState() {
    super.initState();
    _calculateNextEvent();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remaining = _nextEvent.difference(DateTime.now());
        if (_remaining.isNegative) {
          _eventLive = true;
          _timer.cancel();
        }
      });
    });
  }

  void _calculateNextEvent() {
    final now = DateTime.now();
    // Next Saturday at 8:00 AM (bi-weekly event)
    int daysUntilSaturday = (DateTime.saturday - now.weekday) % 7;
    daysUntilSaturday = daysUntilSaturday == 0 ? 14 : daysUntilSaturday;

    _nextEvent = DateTime(
      now.year,
      now.month,
      now.day + daysUntilSaturday,
      8, // 8 AM
    ).add(const Duration(days: 7)); // Make it bi-weekly

    _remaining = _nextEvent.difference(now);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 700;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5F9F2),
            Color(0xFFE8F5E9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Simplified decorative elements
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF8FCB9B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Positioned(
            bottom: -15,
            left: -15,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF4A7C59).withOpacity(0.08),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A7C59), Color(0xFF5A9C69)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A7C59).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            "GLOBAL RANKINGS",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Main content row
                isSmallScreen
                    ? _buildMobileLayout(context)
                    : _buildDesktopLayout(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Event info and CTA
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A7C59).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.leaderboard,
                          size: 28, color: Color(0xFF4A7C59)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "Global Ranking Test",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          color: const Color(0xFF1A3C27),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Event details
                _buildEventDetails(),

                const SizedBox(height: 20),

                // Participants info
                Row(
                  children: [
                    _buildParticipantCount(),
                    const SizedBox(width: 16),
                    _buildPrizeInfo(),
                  ],
                ),

                const SizedBox(height: 24),

                // CTA Button
                _buildCtaButton(),
              ],
            ),
          ),
        ),

        const SizedBox(width: 30),

        // Right side: Countdown timer - More compact design
        Expanded(
          flex: 4,
          child: _eventLive
              ? _buildLiveState(context)
              : _buildCountdown(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with icon
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4A7C59).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.leaderboard,
                  size: 28, color: Color(0xFF4A7C59)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                "Global Ranking Test",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: const Color(0xFF1A3C27),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Countdown timer
        _eventLive
            ? _buildLiveState(context)
            : _buildCountdown(context),

        const SizedBox(height: 20),

        // Event details
        _buildEventDetails(),

        const SizedBox(height: 20),

        // Participants info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildParticipantCount(),
            _buildPrizeInfo(),
          ],
        ),

        const SizedBox(height: 24),

        // CTA Button
        _buildCtaButton(),
      ],
    );
  }

  Widget _buildEventDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(Icons.schedule, "Duration: 60 Minutes"),
        const SizedBox(height: 10),
        _buildDetailRow(Icons.format_list_numbered, "Questions: 30 MCQs"),
        const SizedBox(height: 10),
        _buildDetailRow(Icons.emoji_events, "Level: Intermediate to Advanced"),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4A7C59)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF444444),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantCount() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFE6F4EA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.people, size: 18, color: Color(0xFF4A7C59)),
        ),
        const SizedBox(width: 8),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "2.8K+",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A3C27),
              ),
            ),
            Text(
              "Participants",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A7C59),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrizeInfo() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.emoji_events,
              size: 18, color: Color(0xFFD4AF37)),
        ),
        const SizedBox(width: 8),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Top 50",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A3C27),
              ),
            ),
            Text(
              "Win Prizes",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFD4AF37),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCtaButton() {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, '/join-ranking'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A7C59),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        elevation: 4,
        shadowColor: const Color(0xFF4A7C59).withOpacity(0.4),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_eventLive
              ? "Join Live Ranking Test"
              : "Set Reminder"),
          const SizedBox(width: 10),
          const Icon(Icons.arrow_forward, size: 18),
        ],
      ),
    );
  }

  Widget _buildLiveState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4EA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF4A7C59), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A7C59),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "LIVE NOW • JOIN BEFORE IT ENDS",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A7C59),
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Ranking Test is Live!",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF2B463C),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Compete in real-time with students worldwide",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD54F), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, size: 18, color: Color(0xFFD4AF37)),
                const SizedBox(width: 8),
                Text(
                  "Ends in ${_remaining.inHours.remainder(24)}h ${_remaining.inMinutes.remainder(60)}m",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "TEST STARTS IN",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A7C59),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 14),

          // Compact countdown timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TimeUnit(value: days, label: "Days"),
              const Text(":", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A7C59))),
              _TimeUnit(value: hours, label: "Hours"),
              const Text(":", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A7C59))),
              _TimeUnit(value: minutes, label: "Mins"),
              const Text(":", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A7C59))),
              _TimeUnit(value: seconds, label: "Secs"),
            ],
          ),

          const SizedBox(height: 20),

          // Event date and time
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0EDD6), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today,
                    size: 18, color: Color(0xFF4A7C59)),
                const SizedBox(width: 10),
                Text(
                  DateFormat('EEE, MMM d • h:mm a').format(_nextEvent),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2B463C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Next test in 2 weeks",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeUnit extends StatelessWidget {
  final int value;
  final String label;

  const _TimeUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A7C59), Color(0xFF5A9C69)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A7C59).withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2B463C),
          ),
        ),
      ],
    );
  }
}

class QuickNavigationSection extends StatelessWidget {
  const QuickNavigationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Quick Navigation',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Access key features in one click',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              NavigationTile(
                icon: Icons.quiz,
                label: 'Practice Questions',
                onTap: () => Navigator.pushNamed(context, '/practice'),
              ),
              NavigationTile(
                icon: Icons.assignment_turned_in,
                label: 'Mock Exams',
                onTap: () => Navigator.pushNamed(context, '/exams'),
              ),
              NavigationTile(
                icon: Icons.bar_chart,
                label: 'Score Reports',
                onTap: () => Navigator.pushNamed(context, '/reports'),
              ),
              NavigationTile(
                icon: Icons.menu_book,
                label: 'Prep Resources',
                onTap: () => Navigator.pushNamed(context, '/resources'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NavigationTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const NavigationTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF4A7C59).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: const Color(0xFF4A7C59)),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressTrackerSection extends StatelessWidget {
  final bool isLoggedIn;

  const ProgressTrackerSection({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF5F9F2), Color(0xFFE8F5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: isLoggedIn
            ? const SizedBox.shrink()
            : _buildLoggedOutView(context),
      ),
    );
  }

  Widget _buildLoggedOutView(BuildContext context) {
    return Column(
      children: [
        Text(
          'Track Your Progress',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        Text(
          'Sign up to unlock personalized study plans, progress tracking, and score analytics',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 30),
        FilledButton(
          onPressed: () => Navigator.pushNamed(context, '/signup'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4A7C59),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Create Account', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          child: const Text('Already have an account? Log in',
              style: TextStyle(color: Color(0xFF2B463C), fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Success Stories',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Hear from students who achieved their dream scores',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return const TestimonialsCarousel();
              } else {
                return const TestimonialsGrid();
              }
            },
          ),
          const SizedBox(height: 30),
          const TrustBadges(),
        ],
      ),
    );
  }
}

class TestimonialCard extends StatelessWidget {
  final String quote;
  final String author;
  final String score;

  const TestimonialCard({
    super.key,
    required this.quote,
    required this.author,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Icon(Icons.format_quote, color: Color(0xFF8FCB9B), size: 40),
            const SizedBox(height: 10),
            Text(
              quote,
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16, color: Color(0xFF444444), height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFE0E0E0), height: 1),
            const SizedBox(height: 20),
            Text(
              author,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B463C), fontSize: 16),
            ),
            Text(
              score,
              style: const TextStyle(color: Color(0xFF4A7C59), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class TestimonialsGrid extends StatelessWidget {
  const TestimonialsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: TestimonialCard(
            quote: 'SAT Prep Pro helped me increase my score by 250 points! The mock tests were incredibly realistic.',
            author: 'Emily R.',
            score: 'Scored: 1550',
          ),
        ),
        Expanded(
          child: TestimonialCard(
            quote: 'The personalized study plan identified my weak areas and helped me focus my efforts efficiently.',
            author: 'Michael T.',
            score: 'Scored: 1480',
          ),
        ),
        Expanded(
          child: TestimonialCard(
            quote: 'The expert strategies for time management completely changed how I approached the exam.',
            author: 'Sophia K.',
            score: 'Scored: 1520',
          ),
        ),
      ],
    );
  }
}

class TestimonialsCarousel extends StatelessWidget {
  const TestimonialsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: PageView(
        children: const [
          TestimonialCard(
            quote: 'SAT Prep Pro helped me increase my score by 250 points! The mock tests were incredibly realistic.',
            author: 'Emily R.',
            score: 'Scored: 1550',
          ),
          TestimonialCard(
            quote: 'The personalized study plan identified my weak areas and helped me focus my efforts efficiently.',
            author: 'Michael T.',
            score: 'Scored: 1480',
          ),
          TestimonialCard(
            quote: 'The expert strategies for time management completely changed how I approached the exam.',
            author: 'Sophia K.',
            score: 'Scored: 1520',
          ),
        ],
      ),
    );
  }
}

class TrustBadges extends StatelessWidget {
  const TrustBadges({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 30,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: [
        _buildBadge('College Board®', context),
        _buildBadge('Princeton Review®', context),
        _buildBadge('Forbes Education', context),
        _buildBadge('US News', context),
      ],
    );
  }

  Widget _buildBadge(String text, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2B463C).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF2B463C),
        ),
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      color: const Color(0xFF2B463C),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return const MobileFooter();
              } else {
                return const DesktopFooter();
              }
            },
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white30),

          const SizedBox(height: 20),
          Text(
            '© 2023 SAT Prep Pro. All rights reserved.',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}

class FooterColumn extends StatelessWidget {
  final String title;
  final List<String> items;

  const FooterColumn({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 15),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {},
            child: Text(
              item,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
              ),
            ),
          ),
        )).toList(),
      ],
    );
  }
}

class DesktopFooter extends StatelessWidget {
  const DesktopFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FooterColumn(
          title: 'Company',
          items: ['About Us', 'Careers', 'Press'],
        ),
        FooterColumn(
          title: 'Resources',
          items: ['Pricing/Plans', 'Study Materials', 'FAQs'],
        ),
        FooterColumn(
          title: 'Support',
          items: ['Contact Us', 'Help Center', 'System Status'],
        ),
        FooterColumn(
          title: 'Legal',
          items: ['Privacy Policy', 'Terms of Service', 'Cookie Policy'],
        ),
      ],
    );
  }
}

class MobileFooter extends StatelessWidget {
  const MobileFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        FooterColumn(
          title: 'Company',
          items: ['About Us', 'Careers', 'Press'],
        ),
        SizedBox(height: 30),
        FooterColumn(
          title: 'Resources',
          items: ['Pricing/Plans', 'Study Materials', 'FAQs'],
        ),
        SizedBox(height: 30),
        FooterColumn(
          title: 'Support',
          items: ['Contact Us', 'Help Center', 'System Status'],
        ),
        SizedBox(height: 30),
        FooterColumn(
          title: 'Legal',
          items: ['Privacy Policy', 'Terms of Service', 'Cookie Policy'],
        ),
      ],
    );
  }
}