// practice_session_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
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
    return Question(
      questionId: json['question_id'],
      assessment: json['assessment'],
      test: json['test'],
      domain: json['domain'],
      skill: json['skill'],
      difficulty: json['difficulty'],
      questionText: json['question_text'],
      options: List<String>.from(json['options']),
      correctOption: json['correct_option'],
      explanation: json['explanation'],
      imagePath: json['image_path'],
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
      final String data = await rootBundle.loadString('assets/questions.json');
      final List<dynamic> jsonList = json.decode(data);

      // Corrected filtering logic
      final filteredQuestions = jsonList.map((json) => Question.fromJson(json)).where((question) {
        for (final domain in widget.selectedTopics.keys) {
          // Match top-level domain (test)
          if (domain == question.test) {
            for (final subdomain in widget.selectedTopics[domain]!.keys) {
              // Match subdomain (domain)
              if (subdomain == question.domain) {
                for (final topic in widget.selectedTopics[domain]![subdomain]!.keys) {
                  // Match topic (skill) and check if selected
                  if (topic == question.skill && widget.selectedTopics[domain]![subdomain]![topic]!) {
                    return true;
                  }
                }
              }
            }
          }
        }
        return false;
      }).toList();

      setState(() {
        questions = filteredQuestions;
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
      currentQuestionIndex++;
      selectedOption = null;
      showExplanation = false;
    });
  }

  void _finishSession() {
    Navigator.pop(context);
  }

  Color _getOptionColor(Question question, String option) {
    if (!showExplanation) return Colors.transparent;

    if (option.startsWith(question.correctOption)) {
      return const Color(0xFFE8F5E9).withOpacity(0.8); // Green for correct
    } else if (option == selectedOption) {
      return const Color(0xFFFFEBEE).withOpacity(0.8); // Red for incorrect
    }
    return Colors.transparent;
  }

  IconData? _getOptionIcon(Question question, String option) {
    if (!showExplanation) return null;

    if (option.startsWith(question.correctOption)) {
      return Icons.check_circle;
    } else if (option == selectedOption) {
      return Icons.cancel;
    }
    return null;
  }

  Color _getOptionIconColor(Question question, String option) {
    if (!showExplanation) return Colors.grey;

    if (option.startsWith(question.correctOption)) {
      return const Color(0xFF4A7C59); // Green
    } else if (option == selectedOption) {
      return Colors.red;
    }
    return Colors.grey;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                      fontSize: 44,
                    ),
                  ),
                  TextSpan(
                    text: question.skill,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 44,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Question text
            Text(
              question.questionText,
              style: const TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Image container (if available)
            if (question.imagePath != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    question.imagePath!,
                    fit: BoxFit.cover,
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

            // Explanation
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
                    Text(
                      question.explanation,
                      style: const TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),

            // Next/Finish button
            Center(
              child: ElevatedButton(
                onPressed: showExplanation
                    ? (isLastQuestion ? _finishSession : _nextQuestion)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C59),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isLastQuestion ? 'Finish Session' : 'Next Question',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
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
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected
                      ? const Color(0xFF2B463C)
                      : Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}