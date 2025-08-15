// mock_practice.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:cfdptest/practice_session_screen.dart';
import 'package:cfdptest/practice_mock_test_screen.dart';

class MockPracticeScreen extends StatefulWidget {
  final bool scrollToMockTests;
  final String? section;

  const MockPracticeScreen({
    super.key,
    this.scrollToMockTests = false,
    this.section
  });

  @override
  State<MockPracticeScreen> createState() => _MockPracticeScreenState();
}

class _MockPracticeScreenState extends State<MockPracticeScreen> {
  final Map<String, Map<String, Map<String, List<String>>>> _domainStructure = {
    'Reading and Writing': {
      'Craft and Structure': {
        'Words in Context': [
          'Context clues',
          'Word choice analysis',
          'Tone interpretation',
          'Meaning of words/phrases in context',
          'Connotation and denotation',
        ],
        'Text Structure and Purpose': [
          'Author\'s purpose',
          'Text structure',
          'Persuasive techniques',
          'Evaluate argument effectiveness',
          'Analyze stylistic devices',
        ],
        'Cross-text Connections': [
          'Compare viewpoints',
          'Analyze arguments',
          'Synthesize information',
          'Understand relationships between paired passages',
        ],
      },
      'Information and Ideas': {
        'Central Ideas and Details': [
          'Main idea identification',
          'Theme analysis',
          'Summary creation',
          'Identify relationships between ideas',
        ],
        'Command of Evidence': [
          'Textual support',
          'Graphical support',
          'Evidence evaluation',
          'Use evidence to support claims',
          'Distinguish relevant from irrelevant evidence',
        ],
        'Inferences': [
          'Making logical inferences',
          'Drawing conclusions from text',
          'Inferring implied meanings',
          'Predicting outcomes based on text',
        ],
      },
      'Expression of Ideas': {
        'Transitions': [
          'Effective transitions',
          'Logical connection between ideas',
          'Using transitional words and phrases',
          'Coherence between sentences and paragraphs',
        ],
        'Rhetorical Synthesis': [
          'Combining information from multiple sources',
          'Creating coherent sentences/paragraphs',
          'Synthesizing ideas',
          'Selecting relevant information',
        ],
      },
      'Standard English Conventions': {
        'Boundaries': [
          'Avoid run-ons and fragments',
          'Correct comma usage',
          'Correct semicolon/colon usage',
          'Appropriate sentence separation',
        ],
        'Form, Structure, and Sense': [
          'Subject-verb agreement',
          'Pronoun usage',
          'Verb tense consistency',
          'Modifier placement',
          'Parallel structure',
        ],
      },
    },
    "Math": {
      "Geometry and Trigonometry": {
        "Area and Volume": [
          "Calculate area of polygons",
          "Calculate surface area of 3D shapes",
          "Calculate volume of prisms/pyramids",
          "Apply area/volume formulas to real-world problems",
          "Solve problems with composite shapes"
        ],
        "Circles": [
          "Apply circle theorems",
          "Calculate circumference/arc length",
          "Calculate area of circles/sectors",
          "Solve problems with tangent lines",
          "Find equations of circles"
        ],
        "Lines, Angles, and Triangles": [
          "Classify angle types",
          "Apply angle relationships (vertical, adjacent)",
          "Use triangle congruence theorems",
          "Apply similarity principles",
          "Use parallel/perpendicular line properties"
        ],
        "Right Triangles and Trigonometry": [
          "Apply Pythagorean theorem",
          "Solve special right triangles (30-60-90, 45-45-90)",
          "Use trigonometric ratios (SOHCAHTOA)",
          "Solve trigonometric equations",
          "Apply laws of sines/cosines"
        ]
      },
      "Advanced Math": {
        "Equivalent Expressions": [
          "Factor algebraic expressions",
          "Simplify rational expressions",
          "Rewrite expressions using exponent rules",
          "Identify equivalent polynomial forms",
          "Simplify radical expressions"
        ],
        "Nonlinear Equations and Systems of Equations": [
          "Solve quadratic equations",
          "Solve exponential equations",
          "Solve radical equations",
          "Solve systems with nonlinear equations",
          "Use substitution/elimination methods"
        ],
        "Nonlinear Functions": [
          "Analyze quadratic functions",
          "Graph exponential functions",
          "Model with logarithmic functions",
          "Interpret function transformations",
          "Analyze polynomial end behavior"
        ]
      },
      "Algebra": {
        "Linear Equations in One Variable": [
          "Solve multi-step equations",
          "Solve equations with variables on both sides",
          "Solve literal equations",
          "Identify equations with no/infinite solutions",
          "Model real-world scenarios"
        ],
        "Linear Equations in Two Variables": [
          "Graph linear equations",
          "Calculate slope from points/graphs",
          "Write equations in slope-intercept form",
          "Convert between equation forms",
          "Interpret slope and intercepts"
        ],
        "Linear Functions": [
          "Evaluate linear functions",
          "Determine domain and range",
          "Identify function characteristics",
          "Compare linear rates of change",
          "Model with linear functions"
        ],
        "Linear Inequalities": [
          "Solve/graph one-variable inequalities",
          "Solve compound inequalities",
          "Graph two-variable inequalities",
          "Solve systems of inequalities",
          "Interpret inequality solutions"
        ],
        "Systems of Linear Equations": [
          "Solve by graphing",
          "Solve by substitution",
          "Solve by elimination",
          "Classify dependent/independent systems",
          "Model real-world systems"
        ]
      },
      "Problem-Solving and Data Analysis": {
        "Observational Studies and Experiments": [
          "Distinguish study types",
          "Identify sampling methods",
          "Recognize bias in data collection",
          "Design controlled experiments",
          "Interpret study conclusions"
        ],
        "One-Variable Data": [
          "Calculate measures of center (mean, median)",
          "Calculate measures of spread (range, IQR)",
          "Interpret box plots/histograms",
          "Identify distribution shapes",
          "Analyze skewed distributions"
        ],
        "Percentages": [
          "Calculate percent change",
          "Solve markup/discount problems",
          "Solve compound interest problems",
          "Analyze proportional relationships",
          "Interpret percentage points"
        ],
        "Probability": [
          "Calculate theoretical probabilities",
          "Calculate experimental probabilities",
          "Apply counting principles",
          "Analyze compound events",
          "Use conditional probability"
        ],
        "Ratios, Rates, Proportions, and Units": [
          "Convert measurement units",
          "Calculate unit rates",
          "Solve proportion problems",
          "Analyze scale drawings/maps",
          "Solve dimensional analysis problems"
        ],
        "Sample Statistics and Margin of Error": [
          "Interpret confidence intervals",
          "Calculate margin of error",
          "Analyze sampling distributions",
          "Determine required sample sizes",
          "Interpret statistical significance"
        ],
        "Two-Variable Data": [
          "Interpret scatterplots",
          "Calculate correlation coefficients",
          "Determine regression lines",
          "Analyze residual plots",
          "Distinguish correlation vs causation"
        ]
      },
    },
  };

  final Map<String, Map<String, Map<String, bool>>> _selectedTopics = {};
  final Map<String, Map<String, Map<String, bool>>> _topicExpanded = {};
  final Map<String, Map<String, bool>> _subdomainExpanded = {};
  final Map<String, bool?> _domainSelectionState = {};
  final Map<String, Map<String, bool?>> _subdomainSelectionState = {};
  bool _isDropdownOpen = false;
  bool _showSelectTopicWarning = false;
  int _currentIndex = 1;
  final GlobalKey _mockTestsKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeSelectionMaps();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollToMockTests) {
        _scrollToMockTests();
      }
      if (widget.section != null) {
        _selectSection(widget.section!);
      }
    });
  }

  void _selectSection(String section) {
    setState(() {
      // Reset all selections first
      _resetAllSelections();

      if (section == 'Math') {
        // Select entire Math domain
        _toggleDomainSelection('Math', true);
      }
      else if (section == 'Reading') {
        // Select specific Reading subdomains
        _toggleSubdomainSelection('Reading and Writing', 'Craft and Structure', true);
        _toggleSubdomainSelection('Reading and Writing', 'Information and Ideas', true);
      }
      else if (section == 'Writing') {
        // Select specific Writing subdomains
        _toggleSubdomainSelection('Reading and Writing', 'Expression of Ideas', true);
        _toggleSubdomainSelection('Reading and Writing', 'Standard English Conventions', true);
      }
    });
  }

  void _resetAllSelections() {
    for (final domain in _selectedTopics.keys) {
      for (final subdomain in _selectedTopics[domain]!.keys) {
        for (final topic in _selectedTopics[domain]![subdomain]!.keys) {
          _selectedTopics[domain]![subdomain]![topic] = false;
        }
      }
    }
  }

  void _scrollToMockTests() {
    if (_mockTestsKey.currentContext != null) {
      Scrollable.ensureVisible(
        _mockTestsKey.currentContext!,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
        alignment: 0.5, // Center the section in the viewport
      );
    }
  }

  void _initializeSelectionMaps() {
    for (final domain in _domainStructure.keys) {
      _subdomainExpanded[domain] = {};
      _selectedTopics[domain] = {};
      _topicExpanded[domain] = {};
      _subdomainSelectionState[domain] = {};
      _domainSelectionState[domain] = false;

      for (final subdomain in _domainStructure[domain]!.keys) {
        _subdomainExpanded[domain]![subdomain] = false;
        _selectedTopics[domain]![subdomain] = {};
        _topicExpanded[domain]![subdomain] = {};
        _subdomainSelectionState[domain]![subdomain] = false;

        for (final topic in _domainStructure[domain]![subdomain]!.keys) {
          _selectedTopics[domain]![subdomain]![topic] = false;
          _topicExpanded[domain]![subdomain]![topic] = false;
        }
      }
    }
  }

  void _toggleSubdomainExpansion(String domain, String subdomain) {
    setState(() {
      _subdomainExpanded[domain]![subdomain] =
      !_subdomainExpanded[domain]![subdomain]!;
    });
  }

  void _toggleTopicSelection(String domain, String subdomain, String topic) {
    setState(() {
      _selectedTopics[domain]![subdomain]![topic] =
      !_selectedTopics[domain]![subdomain]![topic]!;
      _updateSubdomainSelectionState(domain, subdomain);
      _updateDomainSelectionState(domain);
    });
  }

  void _updateSubdomainSelectionState(String domain, String subdomain) {
    final topics = _selectedTopics[domain]![subdomain]!;
    final selectedCount = topics.values.where((isSelected) => isSelected).length;
    final totalCount = topics.length;

    if (selectedCount == 0) {
      _subdomainSelectionState[domain]![subdomain] = false;
    } else if (selectedCount == totalCount) {
      _subdomainSelectionState[domain]![subdomain] = true;
    } else {
      _subdomainSelectionState[domain]![subdomain] = null;
    }
  }

  void _updateDomainSelectionState(String domain) {
    int totalTopics = 0;
    int selectedTopics = 0;

    for (final subdomain in _selectedTopics[domain]!.keys) {
      for (final topic in _selectedTopics[domain]![subdomain]!.keys) {
        totalTopics++;
        if (_selectedTopics[domain]![subdomain]![topic] == true) {
          selectedTopics++;
        }
      }
    }

    if (selectedTopics == 0) {
      _domainSelectionState[domain] = false;
    } else if (selectedTopics == totalTopics) {
      _domainSelectionState[domain] = true;
    } else {
      _domainSelectionState[domain] = null;
    }
  }

  void _toggleDomainSelection(String domain, bool? value) {
    setState(() {
      final newValue = value ?? false;
      _domainSelectionState[domain] = newValue;

      for (final subdomain in _domainStructure[domain]!.keys) {
        for (final topic in _domainStructure[domain]![subdomain]!.keys) {
          _selectedTopics[domain]![subdomain]![topic] = newValue;
        }
        _subdomainSelectionState[domain]![subdomain] = newValue;
      }
    });
  }

  void _toggleSubdomainSelection(String domain, String subdomain, bool? value) {
    setState(() {
      final newValue = value ?? false;
      _subdomainSelectionState[domain]![subdomain] = newValue;

      for (final topic in _domainStructure[domain]![subdomain]!.keys) {
        _selectedTopics[domain]![subdomain]![topic] = newValue;
      }

      _updateDomainSelectionState(domain);
    });
  }

  void _toggleTopicExpansion(String domain, String subdomain, String topic) {
    setState(() {
      _topicExpanded[domain]![subdomain]![topic] =
      !_topicExpanded[domain]![subdomain]![topic]!;
    });
  }

  void _startPractice() {
    bool anyTopicSelected = false;

    for (final domain in _selectedTopics.keys) {
      for (final subdomain in _selectedTopics[domain]!.keys) {
        for (final topic in _selectedTopics[domain]![subdomain]!.keys) {
          if (_selectedTopics[domain]![subdomain]![topic] == true) {
            anyTopicSelected = true;
            break;
          }
        }
        if (anyTopicSelected) break;
      }
      if (anyTopicSelected) break;
    }

    if (!anyTopicSelected) {
      setState(() {
        _showSelectTopicWarning = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one topic to practice'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _showSelectTopicWarning = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeSessionScreen(
          selectedTopics: _selectedTopics,
        ),
      ),
    );
  }

  void _handleMockTestSelected(String mockName, bool isPremium) {
    final userData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (isPremium && (userData == null || !(userData['isPremium'] ?? false))) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeMockTestScreen(
          mockTestId: mockName.toLowerCase(),
        ),
      ),
    );
  }


  Widget _buildMockTestButton(String label, bool isPremium) {
    return ElevatedButton(
      onPressed: () => _handleMockTestSelected(label, isPremium),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPremium ? Colors.amber[700] : const Color(0xFF4A7C59),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          if (isPremium) const SizedBox(width: 8),
          if (isPremium) const Icon(Icons.lock, size: 18, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildPremiumMockTestButton(String label) {
    return OutlinedButton(
      onPressed: () => _handleMockTestSelected(label, true),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.amber[700],
        backgroundColor: Colors.amber[50],
        side: BorderSide(
          color: Colors.amber[700]!,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.amber[800],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.lock, size: 18, color: Colors.amber),
        ],
      ),
    );
  }

  Widget _buildDomainCard(String domain, IconData icon) {
    final Color primaryColor = const Color(0xFF4A7C59);
    final Color lightColor = const Color(0xFFF0F9F1);
    final Color iconBgColor = const Color(0xFFE1F0E2);
    final Color headerColor = const Color(0xFFE8F5E9);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [lightColor, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: primaryColor.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: primaryColor.withOpacity(0.2),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    domain,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: primaryColor,
                    ),
                  ),
                ),
                Checkbox(
                  value: _domainSelectionState[domain],
                  tristate: true,
                  onChanged: (value) => _toggleDomainSelection(domain, value),
                  activeColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: _domainStructure[domain]!.keys
                  .map((subdomain) =>
                  _buildSubdomainSection(domain, subdomain, primaryColor))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubdomainSection(String domain, String subdomain, Color domainColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: domainColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              subdomain,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: domainColor,
              ),
            ),
            leading: Checkbox(
              value: _subdomainSelectionState[domain]![subdomain],
              tristate: true,
              onChanged: (value) => _toggleSubdomainSelection(domain, subdomain, value),
              activeColor: domainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              visualDensity: VisualDensity.compact,
            ),
            trailing: Container(
              decoration: BoxDecoration(
                color: domainColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _subdomainExpanded[domain]![subdomain]!
                    ? Icons.expand_less
                    : Icons.expand_more,
                color: domainColor,
              ),
            ),
            onTap: () => _toggleSubdomainExpansion(domain, subdomain),
          ),
          if (_subdomainExpanded[domain]![subdomain]!)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: _domainStructure[domain]![subdomain]!.keys
                    .map((topic) =>
                    _buildTopicRow(domain, subdomain, topic, domainColor))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopicRow(String domain, String subdomain, String topic, Color domainColor) {
    final isSelected = _selectedTopics[domain]![subdomain]![topic]!;
    final isExpanded = _topicExpanded[domain]![subdomain]![topic]!;
    final subtopics = _domainStructure[domain]![subdomain]![topic]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? domainColor.withOpacity(0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? domainColor.withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: Checkbox(
              value: isSelected,
              onChanged: (_) =>
                  _toggleTopicSelection(domain, subdomain, topic),
              activeColor: domainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              visualDensity: VisualDensity.compact,
            ),
            title: Text(
              topic,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: isSelected
                    ? domainColor
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                color: domainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: domainColor,
                ),
                onPressed: () => _toggleTopicExpansion(domain, subdomain, topic),
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Subtopics:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: domainColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...subtopics.map((subtopic) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 8, right: 12),
                            decoration: BoxDecoration(
                              color: domainColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              subtopic,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMockTestsSection() {
    return Container(
      key: _mockTestsKey,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4A7C59).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Full SAT Mock Tests',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E4E36),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Practice with full-length mock tests',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FBF8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4A7C59).withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_open, size: 20, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'FREE MOCK TESTS',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildMockTestButton('Mock1', false),
                    _buildMockTestButton('Mock2', false),
                    _buildMockTestButton('Mock3', false),
                  ],
                ),
                const SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4A7C59).withOpacity(0.3),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _isDropdownOpen = !_isDropdownOpen),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'More Mock Tests',
                              style: TextStyle(
                                color: const Color(0xFF4A7C59),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              _isDropdownOpen ? Icons.expand_less : Icons.expand_more,
                              color: const Color(0xFF4A7C59),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_isDropdownOpen) ...[
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 20, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Text(
                    'PREMIUM MOCK TESTS',
                    style: TextStyle(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                for (int i = 4; i <= 8; i++)
                  _buildPremiumMockTestButton('Mock $i'),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Unlock all premium mock tests with SAT Pro subscription',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Practice'),
        centerTitle: false,
        backgroundColor: const Color(0xFF2B463C),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Targeted Practice',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E4E36),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select specific domains and topics to focus on your weak areas',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  return Column(
                    children: [
                      _buildDomainCard('Math', Icons.calculate),
                      const SizedBox(height: 16),
                      _buildDomainCard('Reading and Writing', Icons.menu_book),
                    ],
                  );
                } else {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDomainCard('Math', Icons.calculate),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDomainCard('Reading and Writing', Icons.menu_book),
                      ),
                    ],
                  );
                }
              },
            ),

            if (_showSelectTopicWarning)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Text(
                    'Please select at least one topic to practice',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _startPractice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C59),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  shadowColor: const Color(0xFF4A7C59).withOpacity(0.4),
                ),
                child: const Text(
                  'Start Practice Session',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 40),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  return Column(
                    children: [
                      _buildMockTestsSection(),
                      const SizedBox(height: 16),
                      const MockTestCountdownSection(),
                    ],
                  );
                } else {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildMockTestsSection(),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: MockTestCountdownSection(),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class MockTestCountdownSection extends StatefulWidget {
  const MockTestCountdownSection({super.key});

  @override
  State<MockTestCountdownSection> createState() => _MockTestCountdownSectionState();
}

class _MockTestCountdownSectionState extends State<MockTestCountdownSection> {
  late DateTime _nextEvent;
  Duration _remaining = Duration.zero;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _calculateNextEvent();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remaining = _nextEvent.difference(DateTime.now());
        if (_remaining.isNegative) {
          _timer.cancel();
          _calculateNextEvent();
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            setState(() {
              _remaining = _nextEvent.difference(DateTime.now());
            });
          });
        }
      });
    });
  }

  void _calculateNextEvent() {
    final now = DateTime.now();
    int daysUntilSaturday = (DateTime.saturday - now.weekday) % 7;
    if (daysUntilSaturday == 0) {
      daysUntilSaturday = 7;
    }
    _nextEvent = DateTime(
      now.year,
      now.month,
      now.day + daysUntilSaturday,
      8,
    );
    _remaining = _nextEvent.difference(now);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4A7C59).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Upcoming Mock Test",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E4E36),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Practice with a full-length test under timed conditions",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 8),
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