import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:cfdptest/main.dart';


const primaryColor = Color(0xFF2B463C);
const secondaryColor = Color(0xFF4A7C59);
const accentColor = Color(0xFF8FCB9B);
const surfaceColor = Color(0xFFF5F9F2);
const backgroundColor = Color(0xFFF8F9F5);
const errorColor = Color(0xFFE57373);

class InfoPage extends StatefulWidget {
  final String? selectedItem;

  const InfoPage({super.key, this.selectedItem});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  late AutoScrollController _scrollController;
  final Map<String, int> _sectionIndices = {
    'About Us': 0,
    'Careers': 1,
    'Press': 2,
    'Pricing/Plans': 3,
    'Study Materials': 4,
    'FAQs': 5,
    'Contact Us': 6,
    'Help Center': 7,
    'System Status': 8,
    'Privacy Policy': 9,
    'Terms of Service': 10,
    'Cookie Policy': 11,
  };

  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedItem != null && _sectionIndices.containsKey(widget.selectedItem)) {
        _scrollController.scrollToIndex(
          _sectionIndices[widget.selectedItem]!,
          duration: const Duration(milliseconds: 500),
          preferPosition: AutoScrollPosition.begin,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Information'),
        backgroundColor: primaryColor,
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          // Company Section
          AutoScrollTag(
            key: const ValueKey(0),
            controller: _scrollController,
            index: 0,
            child: _buildSectionHeader('Company'),
          ),
          AutoScrollTag(
            key: const ValueKey(1),
            controller: _scrollController,
            index: 1,
            child: _buildInfoCard(
              'About Us',
              'Mock SAT Exam is a premier online SAT preparation platform founded in 2018 by a team of Ivy League graduates and education experts. We specialize in providing realistic practice tests, personalized study plans, and comprehensive resources to help students achieve their target SAT scores. Our mission is to make high-quality SAT prep accessible to all students, regardless of their background or location.',
            ),
          ),
          AutoScrollTag(
            key: const ValueKey(2),
            controller: _scrollController,
            index: 2,
            child: _buildInfoCard(
              'Careers',
              'Join our passionate team of educators and technologists! We\'re always looking for talented individuals who share our vision of transforming SAT preparation. Current openings include:\n\n• SAT Content Developers\n• Flutter Developers\n• Student Success Coaches\n• Marketing Specialists\n\nBenefits include competitive salaries, flexible schedules, professional development opportunities, and the satisfaction of helping students achieve their college dreams. Send your resume to careers@mocksatexam.com',
            ),
          ),
          AutoScrollTag(
            key: const ValueKey(3),
            controller: _scrollController,
            index: 3,
            child: _buildInfoCard(
              'Press',
              'Mock SAT Exam has been featured in leading education publications:\n\n• "Revolutionizing Test Prep" - Education Today (2023)\n• "Top 10 EdTech Startups to Watch" - Tech & Learning (2022)\n• "Bridging the SAT Preparation Gap" - The Chronicle of Higher Education (2021)\n\nWe\'ve also been recognized for our innovative approach:\n• National Education Innovation Award (2022)\n• EdTech Excellence Finalist (2023)\n\nFor media inquiries, contact press@mocksatexam.com',
            ),
          ),

          // Resources Section
          AutoScrollTag(
            key: const ValueKey(4),
            controller: _scrollController,
            index: 4,
            child: _buildSectionHeader('Resources'),
          ),
          AutoScrollTag(
            key: const ValueKey(5),
            controller: _scrollController,
            index: 5,
            child: _buildInfoCard(
              'Pricing/Plans',
              'We offer flexible pricing options to suit every student\'s needs:\n\n• Free Tier: Access to 1 full-length test and basic analytics\n• Standard Plan (\$29/month): 10+ practice tests, section drills, and progress tracking\n• Premium Plan (\$49/month): All features plus personalized coaching, college matching, and priority support\n• Family Plan (\$79/month): Support for up to 3 siblings\n\nAnnual subscriptions include a 20% discount. We offer need-based scholarships for eligible students.',
            ),
          ),
          AutoScrollTag(
            key: const ValueKey(6),
            controller: _scrollController,
            index: 6,
            child: _buildInfoCard(
              'Study Materials',
              'Our comprehensive study resources include:\n\n• 25+ full-length adaptive practice tests\n• 5000+ authentic SAT-style questions\n• Section-specific drills (Math, Reading, Writing)\n• Video lessons on all SAT concepts\n• Strategy guides and cheat sheets\n• Vocabulary builders with 1000+ words\n• Official SAT study plan templates\n\nAll materials are regularly updated to reflect the latest SAT format and content changes.',
            ),
          ),
          AutoScrollTag(
            key: const ValueKey(7),
            controller: _scrollController,
            index: 7,
            child: _buildInfoCard(
              'FAQs',
              'Common questions about our platform:\n\nQ: How accurate are your practice tests?\nA: Our tests are developed by SAT experts and statistically validated to match official exam difficulty.\n\nQ: Can I access materials offline?\nA: Yes, our mobile app allows download of tests and resources for offline use.\n\nQ: Do you offer score guarantees?\nA: Students completing our 3-month Premium program typically improve by 200+ points.\n\nQ: How often is new content added?\nA: We add new practice questions weekly and full tests monthly.\n\nQ: What devices are supported?\nA: Our platform works on all web browsers, iOS, and Android devices.',
            ),
          ),

          // Support Section
          AutoScrollTag(
            key: const ValueKey(8),
            controller: _scrollController,
            index: 8,
            child: _buildSectionHeader('Support'),
          ),
          AutoScrollTag(
            key: const ValueKey(9),
            controller: _scrollController,
            index: 9,
            child: _buildInfoCard(
              'Contact Us',
              'Reach our support team through multiple channels:\n\n• Email: support@mocksatexam.com\n• Phone: 1-800-SAT-PREP (1-800-728-7737)\n• Live Chat: Available 9AM-9PM EST\n• In-App Support: Use the help button in your dashboard\n\nOur average response time is under 2 hours during business hours. For technical issues, include your device model and app version.',
            ),
          ),
          AutoScrollTag(
            key: const ValueKey(10),
            controller: _scrollController,
            index: 10,
            child: _buildInfoCard(
              'Help Center',
              'Our comprehensive help resources include:\n\n• Step-by-step setup guides\n• Video tutorials for all features\n• Troubleshooting documentation\n• Practice test walkthroughs\n• Account management instructions\n\nVisit help.mocksatexam.com for 24/7 access to our knowledge base. You can also schedule a 1-on-1 onboarding session with our support team.',
            ),
          ),
          AutoScrollTag(
            key: const ValueKey(11),
            controller: _scrollController,
            index: 11,
            child: _buildInfoCard(
              'System Status',
              'Current platform status:\n\n• Practice Tests: Operational\n• Analytics Dashboard: Operational\n• Mobile Apps: iOS (v3.2.1), Android (v3.1.8)\n• API: Operational\n• Uptime: 99.98% (30-day average)\n\nWe maintain a public status page at status.mocksatexam.com with real-time updates on system performance and maintenance schedules. Scheduled maintenance occurs every Sunday 2-4 AM EST.',
            ),
          ),

          // Legal Section
          AutoScrollTag(
            key: const ValueKey(12),
            controller: _scrollController,
            index: 12,
            child: _buildSectionHeader('Legal'),
          ),
          AutoScrollTag(
            key: const ValueKey(13),
            controller: _scrollController,
            index: 13,
            child: _buildInfoCard(
              'Privacy Policy',
              'We are committed to protecting your personal information:\n\n• We collect only essential data needed to provide our services\n• Student performance data is anonymized for research purposes\n• We never sell or rent personal information to third parties\n• All data is encrypted in transit and at rest\n• Payment information is processed through PCI-compliant partners\n\nWe comply with FERPA, COPPA, and GDPR regulations. Our full privacy policy is available at mocksatexam.com/privacy',
            ),
          ),
          AutoScrollTag(
            key: const ValueKey(14),
            controller: _scrollController,
            index: 14,
            child: _buildInfoCard(
              'Terms of Service',
              'By using Mock SAT Exam, you agree to:\n\n• Use materials only for personal, non-commercial study\n• Not share accounts or redistribute content\n• Accept all scoring and assessment results as advisory\n• Maintain the security of your account credentials\n• Respect intellectual property rights\n\nWe reserve the right to terminate accounts for violations of these terms. Full terms are available at mocksatexam.com/terms',
            ),
          ),
          AutoScrollTag(
            key: const ValueKey(15),
            controller: _scrollController,
            index: 15,
            child: _buildInfoCard(
              'Cookie Policy',
              'We use cookies to enhance your experience:\n\n• Essential Cookies: Required for core functionality\n• Performance Cookies: Track usage patterns to improve services\n• Functionality Cookies: Remember preferences and settings\n• Advertising Cookies: Show relevant educational offers\n\nYou can manage cookie preferences in your account settings. We participate in the IAB Europe Transparency & Consent Framework and honor Global Privacy Control signals.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 15),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF444444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}