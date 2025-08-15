// practice_mock_test_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart'; // Added for LaTeX
import 'package:intl/intl.dart';

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
  final String? image;

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
    this.image,
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
      image: json['image'],
    );
  }
}

class AnswerState {
  String? selectedOption;
  bool marked;

  AnswerState({this.selectedOption, this.marked = false});
}

class PracticeMockTestScreen extends StatefulWidget {
  final String mockTestId;

  const PracticeMockTestScreen({super.key, required this.mockTestId});

  @override
  State<PracticeMockTestScreen> createState() => _PracticeMockTestScreenState();
}

class _PracticeMockTestScreenState extends State<PracticeMockTestScreen> {
  List<Question> readingWritingQuestions = [];
  List<Question> mathQuestions = [];
  int currentSectionIndex = 0;
  int currentQuestionIndex = 0;
  List<AnswerState> readingWritingAnswerStates = [];
  List<AnswerState> mathAnswerStates = [];
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _testCompleted = false;
  bool _isLoading = true;
  bool _isSidebarOpen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Question> get currentSectionQuestions =>
      currentSectionIndex == 0 ? readingWritingQuestions : mathQuestions;

  List<AnswerState> get currentAnswerStates =>
      currentSectionIndex == 0 ? readingWritingAnswerStates : mathAnswerStates;

  int get totalReadingWritingTime => 100 * 60;
  int get totalMathTime => 80 * 60;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final String data = await rootBundle.loadString('assets/${widget.mockTestId}.json');
      final List<dynamic> jsonList = json.decode(data);

      final allQuestions = jsonList.map((json) => Question.fromJson(json)).toList();

      setState(() {
        readingWritingQuestions = allQuestions.where((q) => q.test == "Reading and Writing").toList();
        mathQuestions = allQuestions.where((q) => q.test == "Math").toList();

        readingWritingAnswerStates = List.generate(
            readingWritingQuestions.length,
                (index) => AnswerState()
        );

        mathAnswerStates = List.generate(
            mathQuestions.length,
                (index) => AnswerState()
        );

        _remainingSeconds = totalReadingWritingTime;
        _isLoading = false;
      });

      _startTimer();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          if (currentSectionIndex == 0) {
            currentSectionIndex = 1;
            currentQuestionIndex = 0;
            _remainingSeconds = totalMathTime;
          } else {
            _timer?.cancel();
            _submitTest();
          }
        }
      });
    });
  }

  void _goToQuestion(int index) {
    setState(() {
      currentQuestionIndex = index;
    });
  }

  void _toggleMarkForReview() {
    setState(() {
      currentAnswerStates[currentQuestionIndex].marked =
      !currentAnswerStates[currentQuestionIndex].marked;
    });
  }

  void _selectOption(String option) {
    setState(() {
      currentAnswerStates[currentQuestionIndex].selectedOption = option;
    });
  }

  void _submitTest() {
    _timer?.cancel();
    setState(() {
      _testCompleted = true;
    });
  }

  void _finishTest() {
    if (currentSectionIndex == 0) {
      setState(() {
        currentSectionIndex = 1;
        currentQuestionIndex = 0;
        _remainingSeconds = totalMathTime;
      });
    } else {
      _submitTest();
    }
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getOptionColor(Question question, String option, AnswerState state) {
    if (!_testCompleted) return Colors.transparent;

    if (option.startsWith(question.correctOption)) {
      return const Color(0xFFE8F5E9).withOpacity(0.8);
    } else if (option == state.selectedOption) {
      return const Color(0xFFFFEBEE).withOpacity(0.8);
    }
    return Colors.transparent;
  }

  IconData? _getOptionIcon(Question question, String option, AnswerState state) {
    if (!_testCompleted) return null;

    if (option.startsWith(question.correctOption)) {
      return Icons.check_circle;
    } else if (option == state.selectedOption) {
      return Icons.cancel;
    }
    return null;
  }

  Color _getOptionIconColor(Question question, String option, AnswerState state) {
    if (!_testCompleted) return Colors.grey;

    if (option.startsWith(question.correctOption)) {
      return const Color(0xFF4A7C59);
    } else if (option == state.selectedOption) {
      return Colors.red;
    }
    return Colors.grey;
  }

  // LaTeX rendering functions
  Widget _buildTextWithLatex(String text, {double fontSize = 16, TextStyle? textStyle}) {
    final latexPattern = RegExp(r'\\\[.*?\\\]|\\\(.*?\\\)|\\(?:frac|sqrt|sum|int|lim|sin|cos|tan|log|ln)\b');

    if (latexPattern.hasMatch(text)) {
      return _buildMixedTextWithLatex(text, fontSize: fontSize, textStyle: textStyle);
    } else {
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
      if (match.start > lastEnd) {
        String beforeText = text.substring(lastEnd, match.start);
        if (beforeText.isNotEmpty) {
          widgets.add(Text(
            beforeText,
            style: textStyle ?? TextStyle(fontSize: fontSize, height: 1.5),
          ));
        }
      }

      String latexText = match.group(0)!;
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildTimerWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF4A7C59),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            _formatTime(_remainingSeconds),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionGrid({required bool isDrawer}) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentSectionIndex == 0 ? 'Reading & Writing' : 'Math',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A7C59),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: currentSectionQuestions.length,
              itemBuilder: (context, index) {
                final state = currentAnswerStates[index];
                return GestureDetector(
                  onTap: () {
                    _goToQuestion(index);
                    if (isDrawer) Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: state.selectedOption != null
                          ? const Color(0xFF4A7C59).withOpacity(0.2)
                          : state.marked
                          ? Colors.amber.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: index == currentQuestionIndex
                            ? const Color(0xFF4A7C59)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: state.selectedOption != null
                              ? const Color(0xFF4A7C59)
                              : state.marked
                              ? Colors.amber[800]
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (!isDrawer) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _finishTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7C59),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  'Submit Test',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('SAT Mock Test'),
          backgroundColor: const Color(0xFF4A7C59),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_testCompleted) {
      return MockTestResultsScreen(
        readingWritingQuestions: readingWritingQuestions,
        mathQuestions: mathQuestions,
        readingWritingAnswerStates: readingWritingAnswerStates,
        mathAnswerStates: mathAnswerStates,
      );
    }

    if (currentSectionQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('SAT Mock Test'),
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C59),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Back to Tests', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final question = currentSectionQuestions[currentQuestionIndex];
    final answerState = currentAnswerStates[currentQuestionIndex];
    final isLastQuestion = currentQuestionIndex == currentSectionQuestions.length - 1;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(currentSectionIndex == 0 ? 'Reading & Writing' : 'Math'),
        backgroundColor: const Color(0xFF4A7C59),
        actions: [
          _buildTimerWidget(),
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.grid_view, color: Colors.white),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
        ],
      ),
      endDrawer: isMobile ? Drawer(child: _buildQuestionGrid(isDrawer: true)) : null,
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / currentSectionQuestions.length,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF4A7C59),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Question ${currentQuestionIndex + 1}/${currentSectionQuestions.length}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

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

                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: '${question.domain} • ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A7C59),
                            fontSize: 27,
                          ),
                        ),
                        TextSpan(
                          text: question.skill,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 27,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Updated to use LaTeX rendering
                  _buildTextWithLatex(
                    question.questionText,
                    fontSize: 18,
                    textStyle: const TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  if (question.image != null && question.image!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          question.image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: question.options.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final option = question.options[index];
                      return OptionCard(
                        option: option,
                        isSelected: answerState.selectedOption == option,
                        backgroundColor: _getOptionColor(question, option, answerState),
                        icon: _getOptionIcon(question, option, answerState),
                        iconColor: _getOptionIconColor(question, option, answerState),
                        onTap: () => _selectOption(option),
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: currentQuestionIndex > 0
                            ? () => _goToQuestion(currentQuestionIndex - 1)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A7C59),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Previous', style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: _toggleMarkForReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: answerState.marked
                              ? Colors.amber[700]
                              : const Color(0xFF4A7C59),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          answerState.marked ? 'Marked' : 'Mark for Review',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (isLastQuestion) {
                            _finishTest();
                          } else {
                            _goToQuestion(currentQuestionIndex + 1);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A7C59),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isLastQuestion ? 'Finish Section' : 'Next',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          if (!isMobile)
            Container(
              width: 300,
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey)),
              ),
              child: _buildQuestionGrid(isDrawer: false),
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

  // LaTeX rendering for options
  Widget _buildOptionTextWithLatex(String text) {
    final latexPattern = RegExp(r'\\\[.*?\\\]|\\\(.*?\\\)|\\(?:frac|sqrt|sum|int|lim|sin|cos|tan|log|ln|cdot|pm|leq|geq|neq|times|div)\{[^}]*\}(?:\{[^}]*\})*|\\(?:frac|sqrt|sum|int|lim|sin|cos|tan|log|ln|cdot|pm|leq|geq|neq|times|div)\s*[a-zA-Z0-9_]+');

    if (latexPattern.hasMatch(text)) {
      List<Widget> widgets = [];
      int lastEnd = 0;

      for (final match in latexPattern.allMatches(text)) {
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

class MockTestResultsScreen extends StatelessWidget {
  final List<Question> readingWritingQuestions;
  final List<Question> mathQuestions;
  final List<AnswerState> readingWritingAnswerStates;
  final List<AnswerState> mathAnswerStates;

  const MockTestResultsScreen({
    super.key,
    required this.readingWritingQuestions,
    required this.mathQuestions,
    required this.readingWritingAnswerStates,
    required this.mathAnswerStates,
  });

  // LaTeX rendering functions
  Widget _buildTextWithLatex(String text, {double fontSize = 16, TextStyle? textStyle}) {
    final latexPattern = RegExp(r'\\\[.*?\\\]|\\\(.*?\\\)|\\(?:frac|sqrt|sum|int|lim|sin|cos|tan|log|ln)\b');

    if (latexPattern.hasMatch(text)) {
      return _buildMixedTextWithLatex(text, fontSize: fontSize, textStyle: textStyle);
    } else {
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
      if (match.start > lastEnd) {
        String beforeText = text.substring(lastEnd, match.start);
        if (beforeText.isNotEmpty) {
          widgets.add(Text(
            beforeText,
            style: textStyle ?? TextStyle(fontSize: fontSize, height: 1.5),
          ));
        }
      }

      String latexText = match.group(0)!;
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

  int _calculateScore(List<Question> questions, List<AnswerState> answerStates) {
    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (answerStates[i].selectedOption != null &&
          answerStates[i].selectedOption!.startsWith(questions[i].correctOption)) {
        score++;
      }
    }
    return score;
  }

  Map<String, dynamic> _calculateSectionStats(List<Question> questions, List<AnswerState> answerStates) {
    int correct = 0;
    int incorrect = 0;
    int omitted = 0;

    for (int i = 0; i < questions.length; i++) {
      if (answerStates[i].selectedOption == null) {
        omitted++;
      } else if (answerStates[i].selectedOption!.startsWith(questions[i].correctOption)) {
        correct++;
      } else {
        incorrect++;
      }
    }

    return {
      'correct': correct,
      'incorrect': incorrect,
      'omitted': omitted,
      'total': questions.length,
      'accuracy': questions.isEmpty ? 0 : (correct / questions.length * 100).round(),
    };
  }

  Map<String, double> _calculateSkillAccuracy(List<Question> questions, List<AnswerState> answerStates) {
    Map<String, List<bool>> skillResults = {};

    for (int i = 0; i < questions.length; i++) {
      final skill = questions[i].skill;
      final isCorrect = answerStates[i].selectedOption != null &&
          answerStates[i].selectedOption!.startsWith(questions[i].correctOption);

      skillResults.putIfAbsent(skill, () => []);
      skillResults[skill]!.add(isCorrect);
    }

    Map<String, double> skillAccuracy = {};
    skillResults.forEach((skill, results) {
      final correctCount = results.where((r) => r).length;
      skillAccuracy[skill] = results.isEmpty ? 0 : (correctCount / results.length * 100);
    });

    return skillAccuracy;
  }

  Widget _buildScoreCard(String title, int score, int maxScore, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: const Color(0xFFF5F9F2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$score / $maxScore',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionStatsCard(Map<String, dynamic> stats, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: const Color(0xFFF5F9F2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.bar_chart, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Performance Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatRow('Correct', stats['correct'], Colors.green),
            _buildStatRow('Incorrect', stats['incorrect'], Colors.red),
            _buildStatRow('Omitted', stats['omitted'], Colors.amber),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Accuracy',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${stats['accuracy']}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillPerformance(String title, Map<String, double> skillAccuracy, Color color) {
    final sortedSkills = skillAccuracy.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final weakestSkills = sortedSkills.take(3).toList();
    final strongestSkills = sortedSkills.reversed.take(3).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: const Color(0xFFF5F9F2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.insights, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Areas to Improve',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 12),
            if (weakestSkills.isEmpty)
              const Text('No skills to display')
            else
              ...weakestSkills.map((skill) =>
                  _buildSkillRow(skill.key, skill.value, Colors.red)
              ),

            const SizedBox(height: 20),

            const Text(
              'Strongest Areas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 12),
            if (strongestSkills.isEmpty)
              const Text('No skills to display')
            else
              ...strongestSkills.map((skill) =>
                  _buildSkillRow(skill.key, skill.value, Colors.green)
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillRow(String skill, double accuracy, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              skill,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${accuracy.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readingWritingScore = _calculateScore(
        readingWritingQuestions,
        readingWritingAnswerStates
    );

    final mathScore = _calculateScore(
        mathQuestions,
        mathAnswerStates
    );

    final totalScore = readingWritingScore + mathScore;
    final maxReadingWritingScore = readingWritingQuestions.length;
    final maxMathScore = mathQuestions.length;
    final maxTotalScore = maxReadingWritingScore + maxMathScore;

    final rwStats = _calculateSectionStats(readingWritingQuestions, readingWritingAnswerStates);
    final mathStats = _calculateSectionStats(mathQuestions, mathAnswerStates);

    final rwSkillAccuracy = _calculateSkillAccuracy(readingWritingQuestions, readingWritingAnswerStates);
    final mathSkillAccuracy = _calculateSkillAccuracy(mathQuestions, mathAnswerStates);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Test Results'),
          backgroundColor: const Color(0xFF4A7C59),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 16,
            ),
            tabs: [
              Tab(text: 'Summary'),
              Tab(text: 'Reading & Writing'),
              Tab(text: 'Math'),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Test Summary',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2B463C)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildScoreCard(
                        'Reading & Writing',
                        readingWritingScore,
                        maxReadingWritingScore,
                        Icons.menu_book,
                        const Color(0xFF4A7C59),
                      ),
                      _buildScoreCard(
                        'Math',
                        mathScore,
                        maxMathScore,
                        Icons.calculate,
                        const Color(0xFF2196F3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSectionStatsCard(
                          rwStats,
                          const Color(0xFF4A7C59),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildSectionStatsCard(
                          mathStats,
                          const Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSkillPerformance(
                          'Reading & Writing Skills',
                          rwSkillAccuracy,
                          const Color(0xFF4A7C59),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildSkillPerformance(
                          'Math Skills',
                          mathSkillAccuracy,
                          const Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF5F9F2), Color(0xFFE8F5E9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Score',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B463C),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$totalScore / $maxTotalScore',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A7C59),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '${((totalScore / maxTotalScore) * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Color(0xFF2B463C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A7C59),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF4A7C59).withOpacity(0.3),
                      ),
                      child: const Text(
                        'Back to Tests',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Updated to use LaTeX rendering
            _buildReviewTab(readingWritingQuestions, readingWritingAnswerStates),

            // Updated to use LaTeX rendering
            _buildReviewTab(mathQuestions, mathAnswerStates),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewTab(List<Question> questions, List<AnswerState> answerStates) {
    return ListView.builder(
      itemCount: questions.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final question = questions[index];
        final answerState = answerStates[index];
        final isCorrect = answerState.selectedOption != null &&
            answerState.selectedOption!.startsWith(question.correctOption);

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          margin: const EdgeInsets.only(bottom: 16),
          color: const Color(0xFFF5F9F2),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isCorrect ? const Color(0xFF4A7C59).withOpacity(0.2) : Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCorrect ? Icons.check : Icons.close,
                        color: isCorrect ? const Color(0xFF4A7C59) : Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Question ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF2B463C),
                      ),
                    ),
                    const Spacer(),
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
                  ],
                ),
                const SizedBox(height: 16),

                // Updated to use LaTeX rendering
                _buildTextWithLatex(
                  question.questionText,
                  fontSize: 16,
                  textStyle: const TextStyle(height: 1.5, color: Color(0xFF2B463C)),
                ),
                const SizedBox(height: 16),

                if (question.image != null && question.image!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Image.asset(question.image!),
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                          children: [
                            const TextSpan(
                              text: 'Your answer: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            // Updated to use LaTeX rendering
                            WidgetSpan(
                              child: _buildTextWithLatex(
                                answerState.selectedOption ?? 'Not answered',
                                fontSize: 16,
                                textStyle: TextStyle(
                                  color: isCorrect ? const Color(0xFF4A7C59) : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                          children: [
                            const TextSpan(
                              text: 'Correct answer: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            // Updated to use LaTeX rendering
                            WidgetSpan(
                              child: _buildTextWithLatex(
                                question.correctOption,
                                fontSize: 16,
                                textStyle: const TextStyle(
                                  color: Color(0xFF4A7C59),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Explanation:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2B463C)),
                ),
                const SizedBox(height: 8),

                // Updated to use LaTeX rendering
                _buildTextWithLatex(
                  question.explanation,
                  fontSize: 16,
                  textStyle: const TextStyle(height: 1.5, color: Color(0xFF555555)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}