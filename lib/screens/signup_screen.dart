import 'package:flutter/material.dart';
import 'package:cfdptest/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  final _formKey = GlobalKey<FormState>();

  // Updated color palette from design spec
  static const Color primaryColor = Color(0xFF2B463C);       // deep forest green
  static const Color secondaryColor = Color(0xFF4A7C59);     // vibrant emerald green
  static const Color accentColor = Color(0xFF8FCB9B);        // soft mint
  static const Color surfaceColor = Color(0xFFF5F9F2);       // light green-tinted surface
  static const Color backgroundColor = Color(0xFFF8F9F5);    // off-white with green undertone
  static const Color errorColor = Color(0xFFE57373);         // soft red
  static const Color textPrimary = Color(0xFF333333);        // dark grey primary text
  static const Color textSecondary = Color(0xFF444444);      // secondary text
  static const Color textTertiary = Color(0xFF777777);       // tertiary text
  static const Color prizeGold = Color(0xFFD4AF37);          // gold for highlights
  static const Color lightGreen = Color(0xFFE6F4EA);         // light green tint
  static const Color lightYellow = Color(0xFFFFF8E1);        // yellowish tint

  // Typography constants
  static const String fontFamily = 'Inter';

  TextStyle get headlineLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: primaryColor,
    letterSpacing: -1.5,
  );

  TextStyle get headlineMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: secondaryColor,
    letterSpacing: -0.8,
  );

  TextStyle get bodyLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.6,
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
    letterSpacing: 0.5,
  );

  TextStyle get appBarTitle => TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: -0.5,
  );

  Future<void> _signup() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await AuthService.createAccount(
        _emailController.text,
        _passwordController.text,
        _usernameController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account created successfully!'),
            backgroundColor: secondaryColor,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account creation failed'),
            backgroundColor: errorColor,
          ),
        );
      }
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('Failed to fetch')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('User already exists')) {
        errorMessage = 'Email already registered';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: errorColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 900;

    return Scaffold(
      body: Row(
        children: [
          // Left Panel - Signup Form
          Expanded(
            flex: isSmallScreen ? 1 : 2,
            child: Container(
              color: backgroundColor,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 24 : 40,
                vertical: 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: isSmallScreen ? 20 : 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/LOGO_SAT.png',
                            height: 60,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Mock SAT Exam',
                            style: headlineMedium.copyWith(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Create Your Account',
                        style: headlineMedium.copyWith(
                          fontSize: 32,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Join the elite of SAT achievers',
                        style: bodyLarge,
                      ),
                      const SizedBox(height: 40),

                      // Username Field
                      _buildInputField(
                        controller: _usernameController,
                        label: 'Username',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      _buildInputField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email cannot be empty';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      _buildPasswordField(
                        controller: _passwordController,
                        label: 'Password',
                        obscure: _obscurePassword,
                        onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password cannot be empty';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password Field
                      _buildPasswordField(
                        controller: _confirmController,
                        label: 'Confirm Password',
                        obscure: _obscureConfirm,
                        onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 4,
                            shadowColor: secondaryColor.withOpacity(0.3),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            'Create Account',
                            style: labelLarge,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Login Redirect
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: bodyLarge.copyWith(
                                fontSize: 16,
                                color: textTertiary,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: titleMedium.copyWith(
                                    color: secondaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Right Panel - Features (hidden on small screens)
          if (!isSmallScreen) Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, const Color(0xFF3A5E4A)],
                ),
              ),
              padding: const EdgeInsets.all(50),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Elevate Your SAT Score',
                      style: headlineLarge.copyWith(
                        fontSize: 42,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Join 50,000+ students who improved their scores by 200+ points',
                      style: bodyLarge.copyWith(
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Features Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 30,
                      childAspectRatio: 3,
                      children: [
                        _buildFeatureTile(
                          icon: Icons.assignment,
                          title: 'Official SAT Practice Tests',
                          description: '8 full-length exams developed by College Board experts',
                        ),
                        _buildFeatureTile(
                          icon: Icons.analytics,
                          title: 'Score Analytics',
                          description: 'Detailed breakdown of strengths and weaknesses',
                        ),
                        _buildFeatureTile(
                          icon: Icons.timeline,
                          title: 'Personalized Roadmap',
                          description: 'AI-powered study plan tailored to your goals',
                        ),
                        _buildFeatureTile(
                          icon: Icons.library_books,
                          title: 'Question Bank',
                          description: '12,000+ practice questions with video explanations',
                        ),
                        _buildFeatureTile(
                          icon: Icons.timer,
                          title: 'Time Management',
                          description: 'Section-specific pacing strategies and drills',
                        ),
                        _buildFeatureTile(
                          icon: Icons.bar_chart,
                          title: 'Score Predictor',
                          description: 'Accurate score forecasts with improvement tips',
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),

                    // Testimonial
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"This platform helped me improve my SAT score by 320 points! '
                                'The practice tests are incredibly realistic and the analytics '
                                'showed me exactly where to focus."',
                            style: bodyLarge.copyWith(
                              fontStyle: FontStyle.italic,
                              color: textPrimary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage('assets/student1.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Emily Richardson',
                                    style: titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Scored 1580 | Admitted to Stanford',
                                    style: bodyLarge.copyWith(
                                      fontSize: 14,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: titleMedium.copyWith(color: textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: titleMedium.copyWith(color: textTertiary),
        prefixIcon: Icon(icon, color: secondaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A7C59), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        errorStyle: TextStyle(color: errorColor),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: titleMedium.copyWith(color: textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: titleMedium.copyWith(color: textTertiary),
        prefixIcon: Icon(Icons.lock_outline, color: secondaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: textTertiary,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A7C59), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        errorStyle: TextStyle(color: errorColor),
      ),
      validator: validator,
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: secondaryColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleMedium.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: bodyLarge.copyWith(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}