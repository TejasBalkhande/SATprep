import 'package:flutter/material.dart';
import 'package:cfdptest/screens/login_screen.dart';
import 'package:cfdptest/screens/signup_screen.dart';
import 'package:cfdptest/screens/profile_screen.dart'; // <-- Add this line


void main() => runApp(const SATPrepApp());

class SATPrepApp extends StatelessWidget {
  const SATPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAT Prep Pro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            height: 1.5,
            color: Colors.black87,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D47A1),
          ),
        ),
      ),
      initialRoute: '/',
        routes: {
          '/': (context) => const SATPrepHomePage(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/profile': (context) {
            final userData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
            return ProfileScreen(userData: userData);
          },
        }

    );
  }
}

// main.dart (partial update)
class SATPrepHomePage extends StatelessWidget {
  const SATPrepHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user data if passed from login
    final userData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final loggedIn = userData != null;



    return Scaffold(
      appBar: AppBar(
        title: const Text('SAT Prep Pro', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D47A1),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => loggedIn
                ? Navigator.pushNamed(
              context,
              '/profile',
              arguments: userData, // Pass user data to profile
            )
                : Navigator.pushNamed(context, '/login'),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(),
            const SizedBox(height: 40),
            const KeyFeaturesSection(),
            const SizedBox(height: 40),
            const QuickNavigationSection(),
            const SizedBox(height: 40),
            ProgressTrackerSection(isLoggedIn: loggedIn), // Use actual login state
            const SizedBox(height: 40),
            const TestimonialsSection(),
            const SizedBox(height: 40),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1509062522246-3755977927d7?auto=format&fit=crop&w=1200&q=80',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ace the SAT – Your Path to Top Scores Starts Here',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Expert-led lessons, realistic mock tests, and proven strategies to boost your score',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(context, '/mock-test'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 20),
                    ),
                    child: const Text(
                      'Start a Mock Test',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/study-plans'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 20),
                    ),
                    child: const Text(
                      'View Study Plans',
                      style: TextStyle(color: Colors.white, fontSize: 18),
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
    return Column(
      children: [
        Text(
          'Why Choose SAT Prep Pro?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 30),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return const MobileFeatureGrid();
            } else {
              return const DesktopFeatureGrid();
            }
          },
        ),
      ],
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
      elevation: 4,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 50, color: const Color(0xFF0D47A1)),
            const SizedBox(height: 15),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: FeatureCard(
            icon: Icons.assignment,
            title: 'Full-Length Mock Tests',
            description: 'Simulate real exam conditions',
          ),
        ),
        Expanded(
          child: FeatureCard(
            icon: Icons.school,
            title: 'Personalized Study Plans',
            description: 'Based on your strengths & weaknesses',
          ),
        ),
        Expanded(
          child: FeatureCard(
            icon: Icons.analytics,
            title: 'Detailed Analytics',
            description: 'Know exactly where to improve',
          ),
        ),
        Expanded(
          child: FeatureCard(
            icon: Icons.lightbulb,
            title: 'Expert Strategies',
            description: 'Tips from SAT coaches',
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
          description: 'Simulate real exam conditions',
        ),
        FeatureCard(
          icon: Icons.school,
          title: 'Personalized Study Plans',
          description: 'Based on your strengths & weaknesses',
        ),
        FeatureCard(
          icon: Icons.analytics,
          title: 'Detailed Analytics',
          description: 'Know exactly where to improve',
        ),
        FeatureCard(
          icon: Icons.lightbulb,
          title: 'Expert Strategies',
          description: 'Tips from SAT coaches',
        ),
      ],
    );
  }
}

class QuickNavigationSection extends StatelessWidget {
  const QuickNavigationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Quick Navigation',
          style: Theme.of(context).textTheme.headlineMedium,
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: const Color(0xFF0D47A1)),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
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
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: isLoggedIn
          ? _buildLoggedInView(context)
          : _buildLoggedOutView(context),
    );
  }

  Widget _buildLoggedInView(BuildContext context) {
    return Column(
      children: [
        Text(
          'Your Progress',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'Score Trend Chart',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Next Recommended Action: Practice Algebra Questions',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () {},
          child: const Text('Continue Studying'),
        ),
      ],
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
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: const Text('Create Account'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          child: const Text('Already have an account? Log in'),
        ),
      ],
    );
  }
}

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Success Stories',
          style: Theme.of(context).textTheme.headlineMedium,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.format_quote, color: Colors.grey, size: 40),
            const SizedBox(height: 10),
            Text(
              quote,
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              author,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              score,
              style: const TextStyle(color: Colors.blue),
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
      height: 300,
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
        _buildBadge('College Board®'),
        _buildBadge('Princeton Review®'),
        _buildBadge('Forbes Education'),
        _buildBadge('US News'),
      ],
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF0D47A1),
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
      color: const Color(0xFF0D47A1),
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
          const Text(
            '© 2023 SAT Prep Pro. All rights reserved.',
            style: TextStyle(color: Colors.white70),
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
            fontWeight: FontWeight.bold,
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
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        )),
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