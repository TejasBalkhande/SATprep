import 'package:flutter/material.dart';
import 'package:cfdptest/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
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

  Future<void> _login() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userData = await AuthService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (userData != null) {
        Navigator.pushReplacementNamed(
          context,
          '/',
          arguments: userData,
        );
      }
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('Failed to fetch')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('User not found')) {
        errorMessage = 'Account not found';
      } else if (e.toString().contains('Invalid credentials')) {
        errorMessage = 'Incorrect email or password';
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
          // Left Panel - Login Form
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
                            'assets/sat_logo.png',
                            height: 60,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'SAT PREP PRO',
                            style: headlineMedium.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Welcome Back',
                        style: headlineMedium.copyWith(
                          fontSize: 32,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Continue your journey to SAT success',
                        style: bodyLarge,
                      ),
                      const SizedBox(height: 40),

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
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                          child: Text(
                            'Forgot Password?',
                            style: titleMedium.copyWith(
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
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
                            'Login',
                            style: labelLarge,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Signup Redirect
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: bodyLarge.copyWith(
                                fontSize: 16,
                                color: textTertiary,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
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
                      'Master the SAT',
                      style: headlineLarge.copyWith(
                        fontSize: 42,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Join thousands of students who achieved their dream scores',
                      style: bodyLarge.copyWith(
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 60),

                    // SAT Tips
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
                            'Proven Strategies:',
                            style: headlineMedium.copyWith(
                              fontSize: 24,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildLoginTip(text: 'Time management is key - practice pacing for each section'),
                          _buildLoginTip(text: 'Learn to eliminate wrong answers quickly'),
                          _buildLoginTip(text: 'Master the evidence-based reading approach'),
                          _buildLoginTip(text: 'Use official College Board materials for authentic practice'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

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
                      ],
                    ),
                    const SizedBox(height: 40),

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
                            '"The practice tests and analytics helped me identify my weak areas. '
                                'I improved my math score by 150 points in just 2 months!"',
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
                                    image: AssetImage('assets/student2.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Michael Chen',
                                    style: titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Scored 1520 | Admitted to MIT',
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

  Widget _buildLoginTip({required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: secondaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: bodyLarge.copyWith(
                color: textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}