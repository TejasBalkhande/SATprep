// practice_session_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:cfdptest/mock_practice.dart';

class Question {
  final String questionId;
  final String assessment;
  final String test;
  final String domain;
  final String skill;
  final String difficulty;
  final String questionText;
  final List<String> options;
  final String correctOption;
  final String explanation;
  final String? imagePath;

  Question({
    required this.questionId,
    required this.assessment,
    required this.test,
    required this.domain,
    required this.skill,
    required this.difficulty,
    required this.questionText,
    required this.options,
    required this.correctOption,
    required this.explanation,
    this.imagePath,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    final requiredFields = [
      'question_id', 'assessment', 'test', 'domain', 'skill',
      'difficulty', 'question_text', 'options', 'correct_option', 'explanation'
    ];

    for (final field in requiredFields) {
      if (json[field] == null) {
        throw FormatException('Field $field is missing in question JSON');
      }
    }

    // Validate options list
    final options = (json['options'] as List).map((e) => e?.toString() ?? '').toList();
    if (options.isEmpty) {
      throw FormatException('Options list is empty');
    }

    // Handle image field - only include path if it's not empty
    String? imagePath;
    if (json['image'] != null && json['image'].toString().trim().isNotEmpty) {
      imagePath = json['image'] as String;
    }

    return Question(
      questionId: json['question_id'] as String,
      assessment: json['assessment'] as String,
      test: json['test'] as String,
      domain: json['domain'] as String,
      skill: json['skill'] as String,
      difficulty: json['difficulty'] as String,
      questionText: json['question_text'] as String,
      options: options,
      correctOption: json['correct_option'] as String,
      explanation: json['explanation'] as String,
      imagePath: imagePath,
    );
  }
}

class PracticeSessionScreen extends StatefulWidget {
  final Map<String, Map<String, Map<String, bool>>> selectedTopics;

  const PracticeSessionScreen({super.key, required this.selectedTopics});

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  String? selectedOption;
  bool showExplanation = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final String data = await rootBundle.loadString('assets/practice_question.json');
      final List<dynamic> jsonList = json.decode(data);

      final List<Question> validQuestions = [];

      for (final jsonItem in jsonList) {
        try {
          final question = Question.fromJson(jsonItem);

          // Normalize strings for case-insensitive comparison
          final normalize = (String str) => str.trim().toLowerCase();

          for (final domain in widget.selectedTopics.keys) {
            if (normalize(domain) == normalize(question.test)) {
              for (final subdomain in widget.selectedTopics[domain]!.keys) {
                if (normalize(subdomain) == normalize(question.domain)) {
                  for (final topic in widget.selectedTopics[domain]![subdomain]!.keys) {
                    if (normalize(topic) == normalize(question.skill) &&
                        widget.selectedTopics[domain]![subdomain]![topic]!) {
                      validQuestions.add(question);
                      break;
                    }
                  }
                }
              }
            }
          }
        } catch (e) {
          print('Skipping invalid question: $e');
        }
      }

      setState(() {
        questions = validQuestions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
    }
  }

  void _selectOption(String option) {
    setState(() {
      selectedOption = option;
      showExplanation = true;
    });
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        selectedOption = null;
        showExplanation = false;
      }
    });
  }

  void _previousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
        selectedOption = null;
        showExplanation = false;
      }
    });
  }

  void _finishSession() {
    Navigator.pop(context);
  }

  Color _getOptionColor(Question question, String option) {
    if (!showExplanation) return Colors.transparent;

    if (option == question.correctOption) {
      return const Color(0xFFE8F5E9).withOpacity(0.8); // Green for correct
    } else if (option == selectedOption) {
      return const Color(0xFFFFEBEE).withOpacity(0.8); // Red for incorrect
    }
    return Colors.transparent;
  }

  IconData? _getOptionIcon(Question question, String option) {
    if (!showExplanation) return null;

    if (option == question.correctOption) {
      return Icons.check_circle;
    } else if (option == selectedOption) {
      return Icons.cancel;
    }
    return null;
  }

  Color _getOptionIconColor(Question question, String option) {
    if (!showExplanation) return Colors.grey;

    if (option == question.correctOption) {
      return const Color(0xFF4A7C59); // Green
    } else if (option == selectedOption) {
      return Colors.red;
    }
    return Colors.grey;
  }

  // Function to detect and render LaTeX
  Widget _buildTextWithLatex(String text, {double fontSize = 16, TextStyle? textStyle}) {
    // Check if text contains LaTeX patterns
    final latexPattern = RegExp(r'\\\[.*?\\\]|\\\(.*?\\\)|\\(?:frac|sqrt|sum|int|lim|sin|cos|tan|log|ln)\b');

    if (latexPattern.hasMatch(text)) {
      // Split text into parts and render LaTeX where found
      return _buildMixedTextWithLatex(text, fontSize: fontSize, textStyle: textStyle);
    } else {
      // Regular text
      return Text(
        text,
        style: textStyle ?? TextStyle(fontSize: fontSize, height: 1.5),
      );
    }
  }

  Widget _buildMixedTextWithLatex(String text, {double fontSize = 16, TextStyle? textStyle}) {
    final latexPattern = RegExp(r'(\\\[.*?\\\]|\\\(.*?\\\)|\\(?:frac|sqrt|sum|int|lim|sin|cos|tan|log|ln|cdot|pm|leq|geq|neq|times|div)\{[^}]*\}(?:\{[^}]*\})*|\\(?:frac|sqrt|sum|int|lim|sin|cos|tan|log|ln|cdot|pm|leq|geq|neq|times|div)\s*[a-zA-Z0-9_]+)');

    List<Widget> widgets = [];
    int lastEnd = 0;

    for (final match in latexPattern.allMatches(text)) {
      // Add text before LaTeX
      if (match.start > lastEnd) {
        String beforeText = text.substring(lastEnd, match.start);
        if (beforeText.isNotEmpty) {
          widgets.add(Text(
            beforeText,
            style: textStyle ?? TextStyle(fontSize: fontSize, height: 1.5),
          ));
        }
      }

      // Add LaTeX
      String latexText = match.group(0)!;
      // Clean up LaTeX delimiters
      latexText = latexText.replaceAll(r'\[', '').replaceAll(r'\]', '');
      latexText = latexText.replaceAll(r'\(', '').replaceAll(r'\)', '');

      try {
        widgets.add(
          Math.tex(
            latexText,
            mathStyle: MathStyle.display,
            textStyle: TextStyle(fontSize: fontSize),
          ),
        );
      } catch (e) {
        // If LaTeX parsing fails, show as regular text
        widgets.add(
          Text(
            match.group(0)!,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'monospace',
              backgroundColor: Colors.grey[200],
            ),
          ),
        );
      }


      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      String remainingText = text.substring(lastEnd);
      if (remainingText.isNotEmpty) {
        widgets.add(Text(
          remainingText,
          style: textStyle ?? TextStyle(fontSize: fontSize, height: 1.5),
        ));
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Practice Session'),
          backgroundColor: const Color(0xFF4A7C59),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Practice Session'),
          backgroundColor: const Color(0xFF4A7C59),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning, size: 48, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'No questions found',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Please select different topics'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C59),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Back to Topics', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final question = questions[currentQuestionIndex];
    final isLastQuestion = currentQuestionIndex == questions.length - 1;
    final isFirstQuestion = currentQuestionIndex == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Session'),
        backgroundColor: const Color(0xFF4A7C59),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${currentQuestionIndex + 1}/${questions.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Extra bottom padding for buttons
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / questions.length,
                  backgroundColor: Colors.grey[300],
                  color: const Color(0xFF4A7C59),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 20),

                // Difficulty indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: question.difficulty == 'Easy'
                        ? Colors.green[100]
                        : question.difficulty == 'Medium'
                        ? Colors.amber[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    question.difficulty,
                    style: TextStyle(
                      color: question.difficulty == 'Easy'
                          ? Colors.green[800]
                          : question.difficulty == 'Medium'
                          ? Colors.amber[800]
                          : Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Domain and skill
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${question.domain} • ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A7C59),
                          fontSize: 18,
                        ),
                      ),
                      TextSpan(
                        text: question.skill,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Question text with LaTeX support
                _buildTextWithLatex(
                  question.questionText,
                  fontSize: 18,
                  textStyle: const TextStyle(fontSize: 18, height: 1.5),
                ),
                const SizedBox(height: 20),

                // Image container with fixed height and aspect ratio
                if (question.imagePath != null && question.imagePath!.isNotEmpty)
                  Container(
                    height: 270, // Fixed height
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        question.imagePath!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            child: const Text('Image not found'),
                          );
                        },
                      ),
                    ),
                  ),

                // Options
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: question.options.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = question.options[index];
                    return OptionCard(
                      option: option,
                      isSelected: selectedOption == option,
                      backgroundColor: _getOptionColor(question, option),
                      icon: _getOptionIcon(question, option),
                      iconColor: _getOptionIconColor(question, option),
                      onTap: () => _selectOption(option),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Explanation with LaTeX support
                if (showExplanation)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F9F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4A7C59).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Explanation:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B463C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextWithLatex(
                          question.explanation,
                          fontSize: 15,
                          textStyle: const TextStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // Fixed position navigation buttons
          Positioned(
            bottom: 16,
            right: 16,
              child: Row(
                children: [
                  // Previous button
                  if (!isFirstQuestion)
                    ElevatedButton(
                      onPressed: _previousQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF4A7C59)), // Green border
                        ),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4A7C59), // Green text
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  if (!isFirstQuestion)
                    const SizedBox(width: 12),

                  // Next/Finish button
                  ElevatedButton(
                    onPressed: isLastQuestion ? _finishSession : _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A7C59),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isLastQuestion ? 'Finish' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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

class OptionCard extends StatelessWidget {
  final String option;
  final bool isSelected;
  final Color backgroundColor;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.backgroundColor,
    this.icon,
    this.iconColor,
    required this.onTap,
  });

  // Function to detect and render LaTeX in options
  Widget _buildOptionTextWithLatex(String text) {
    final latexPattern = RegExp(r'\\\[.*?\\\]|\\\(.*?\\\)|\\(?:frac|sqrt|sum|int|lim|sin|cos|tan|log|ln|cdot|pm|leq|geq|neq|times|div)\{[^}]*\}(?:\{[^}]*\})*|\\(?:frac|sqrt|sum|int|lim|sin|cos|tan|log|ln|cdot|pm|leq|geq|neq|times|div)\s*[a-zA-Z0-9_]+');

    if (latexPattern.hasMatch(text)) {
      List<Widget> widgets = [];
      int lastEnd = 0;

      for (final match in latexPattern.allMatches(text)) {
        // Add text before LaTeX
        if (match.start > lastEnd) {
          String beforeText = text.substring(lastEnd, match.start);
          if (beforeText.isNotEmpty) {
            widgets.add(Text(
              beforeText,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? const Color(0xFF2B463C) : Colors.black,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ));
          }
        }

        // Add LaTeX
        String latexText = match.group(0)!;
        latexText = latexText.replaceAll(r'\[', '').replaceAll(r'\]', '');
        latexText = latexText.replaceAll(r'\(', '').replaceAll(r'\)', '');

        try {
          widgets.add(Math.tex(
            latexText,
            mathStyle: MathStyle.text,
            textStyle: const TextStyle(fontSize: 16),
          ));
        } catch (e) {
          widgets.add(Text(
            match.group(0)!,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'monospace',
              backgroundColor: Colors.grey[200],
              color: isSelected ? const Color(0xFF2B463C) : Colors.black,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ));
        }

        lastEnd = match.end;
      }

      // Add remaining text
      if (lastEnd < text.length) {
        String remainingText = text.substring(lastEnd);
        if (remainingText.isNotEmpty) {
          widgets.add(Text(
            remainingText,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? const Color(0xFF2B463C) : Colors.black,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ));
        }
      }

      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: widgets,
      );
    } else {
      return Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: isSelected ? const Color(0xFF2B463C) : Colors.black,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A7C59)
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(icon, color: iconColor, size: 24),
            if (icon == null)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4A7C59)
                        : Colors.grey,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4A7C59),
                    ),
                  ),
                )
                    : null,
              ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOptionTextWithLatex(option),
            ),
          ],
        ),
      ),
    );
  }
}