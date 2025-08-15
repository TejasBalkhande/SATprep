import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:cfdptest/main.dart';

class CollegeScreen extends StatefulWidget {
  const CollegeScreen({super.key});

  @override
  State<CollegeScreen> createState() => _CollegeScreenState();
}

class _CollegeScreenState extends State<CollegeScreen> {
  List<College> colleges = [];
  List<College> filteredColleges = [];
  String searchQuery = '';
  String? selectedMajor;

  @override
  void initState() {
    super.initState();
    _loadColleges();
  }

  Future<void> _loadColleges() async {
    final jsonString = await rootBundle.loadString('assets/colleges.json');
    final jsonData = json.decode(jsonString) as List<dynamic>;
    setState(() {
      colleges = jsonData.map((e) => College.fromJson(e)).toList();
      filteredColleges = colleges;
    });
  }

  void _filterColleges() {
    setState(() {
      filteredColleges = colleges.where((college) {
        final nameMatch = college.name.toLowerCase().contains(searchQuery.toLowerCase());
        final majorMatch = selectedMajor == null ||
            college.stats.popularMajors.contains(selectedMajor);
        return nameMatch && majorMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('College Explorer'),
        backgroundColor: Theme.of(context).primaryColor,
        leading: isMobile
            ? IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                      (route) => false
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search colleges...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                searchQuery = value;
                _filterColleges();
              },
            ),
            const SizedBox(height: 16),

            // Major Filter Chips
            const Text('Filter by Major:'),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // "All Majors" chip
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: selectedMajor == null,
                      onSelected: (selected) {
                        setState(() {
                          selectedMajor = null;
                          _filterColleges();
                        });
                      },
                    ),
                  ),
                  // Major chips
                  ..._getAllMajors().map((major) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(major),
                        selected: selectedMajor == major,
                        onSelected: (selected) {
                          setState(() {
                            selectedMajor = selected ? major : null;
                            _filterColleges();
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Content
            Expanded(
              child: isMobile
                  ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: filteredColleges.length,
                itemBuilder: (context, index) {
                  final college = filteredColleges[index];
                  return _buildCollegeCard(college, context);
                },
              )
                  : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // College Cards Grid
                  Expanded(
                    flex: 9,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: filteredColleges.length,
                      itemBuilder: (context, index) {
                        final college = filteredColleges[index];
                        return _buildCollegeCard(college, context);
                      },
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Sidebar - Desktop only (FIXED)
                  Expanded(
                    flex: 3,
                    child: ListView(
                      children: [
                        // Start Mock Section - Now first
                        _buildStartMockSection(),
                        const SizedBox(height: 24),
                        // Top Colleges Section - Now second
                        _buildTopCollegesSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollegeCard(College college, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // College Header
            Row(
              children: [
                // Logo
                if (college.logoUrl.isNotEmpty)
                  Image.network(
                    college.logoUrl,
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) => const Icon(Icons.school),
                  ),
                const SizedBox(width: 12),
                // Name
                Expanded(
                  child: Text(
                    college.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Basic Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('SAT', college.satRange),
                _buildInfoItem('Acceptance', '${college.acceptanceRate}%'),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow(Icons.location_on, college.location, context),
            _buildDetailRow(Icons.policy,
                '${college.testPolicy.type} (Updated ${college.testPolicy.lastUpdated})', context),
            _buildDetailRow(Icons.attach_money,
                'Out-State Tuition: \$${college.tuition.outState?.toStringAsFixed(0) ?? 'N/A'}', context),
            _buildDetailRow(Icons.people,
                'Student-Faculty Ratio: ${college.stats.studentFacultyRatio}', context),
            _buildDetailRow(Icons.school,
                'Graduation Rate: ${college.stats.graduationRate}%', context),
            _buildDetailRow(Icons.work,
                'Avg Salary: \$${college.outcomes.avgStartingSalary.toStringAsFixed(0)}', context),
            const SizedBox(height: 12),
            Text('Popular Majors: ${college.stats.popularMajors.join(', ')}'),
            const SizedBox(height: 12),
            Text('Rankings: Niche #${college.stats.ranking.niche}, WSJ #${college.stats.ranking.wsj}'),
            const SizedBox(height: 16),
            // Official Link
            InkWell(
              onTap: () {},
              child: Text(
                'Official Website',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Flexible(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildTopCollegesSection() {
    // Get top 5 colleges by Niche ranking
    final topColleges = (colleges.toList()
      ..sort((a, b) => a.stats.ranking.niche.compareTo(b.stats.ranking.niche)))
        .take(5)
        .toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Colleges',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView(
                shrinkWrap: true,
                children: topColleges.map((college) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.school, size: 16,
                          color: Color(0xFF4A7C59)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(college.name)),
                      Chip(
                        label: Text('#${college.stats.ranking.niche}'),
                        backgroundColor: const Color(0xFF8FCB9B).withOpacity(0.2),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartMockSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start Mock Test',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Practice with our simulated college entrance exams',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/mock-practice');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Start Test',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  List<String> _getAllMajors() {
    final allMajors = <String>{};
    for (var college in colleges) {
      allMajors.addAll(college.stats.popularMajors);
    }
    return allMajors.toList()..sort();
  }
}

// College Model Classes (remain unchanged)
class College {
  final String name;
  final String location;
  final String logoUrl;
  final double acceptanceRate;
  final String satRange;
  final TestPolicy testPolicy;
  final Tuition tuition;
  final Stats stats;
  final Outcomes outcomes;
  final Links links;

  College({
    required this.name,
    required this.location,
    required this.logoUrl,
    required this.acceptanceRate,
    required this.satRange,
    required this.testPolicy,
    required this.tuition,
    required this.stats,
    required this.outcomes,
    required this.links,
  });

  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      name: json['name'] as String,
      location: json['location'] as String,
      logoUrl: json['logoUrl'] as String,
      acceptanceRate: (json['acceptanceRate'] as num).toDouble(),
      satRange: json['satRange'] as String,
      testPolicy: TestPolicy.fromJson(json['testPolicy'] as Map<String, dynamic>),
      tuition: Tuition.fromJson(json['tuition'] as Map<String, dynamic>),
      stats: Stats.fromJson(json['stats'] as Map<String, dynamic>),
      outcomes: Outcomes.fromJson(json['outcomes'] as Map<String, dynamic>),
      links: Links.fromJson(json['links'] as Map<String, dynamic>),
    );
  }
}

class TestPolicy {
  final String type;
  final String lastUpdated;

  TestPolicy({required this.type, required this.lastUpdated});

  factory TestPolicy.fromJson(Map<String, dynamic> json) {
    return TestPolicy(
      type: json['type'] as String,
      lastUpdated: json['lastUpdated'] as String,
    );
  }
}

class Tuition {
  final double? inState;
  final double outState;
  final double avgNetPrice;

  Tuition({this.inState, required this.outState, required this.avgNetPrice});

  factory Tuition.fromJson(Map<String, dynamic> json) {
    return Tuition(
      inState: json['inState']?.toDouble(),
      outState: (json['outState'] as num).toDouble(),
      avgNetPrice: (json['avgNetPrice'] as num).toDouble(),
    );
  }
}

class Stats {
  final String studentFacultyRatio;
  final double graduationRate;
  final List<String> popularMajors;
  final Ranking ranking;

  Stats({
    required this.studentFacultyRatio,
    required this.graduationRate,
    required this.popularMajors,
    required this.ranking,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      studentFacultyRatio: json['studentFacultyRatio'] as String,
      graduationRate: (json['graduationRate'] as num).toDouble(),
      popularMajors: (json['popularMajors'] as List<dynamic>).cast<String>(),
      ranking: Ranking.fromJson(json['ranking'] as Map<String, dynamic>),
    );
  }
}

class Ranking {
  final int niche;
  final int wsj;

  Ranking({required this.niche, required this.wsj});

  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      niche: json['niche'] as int,
      wsj: json['wsj'] as int,
    );
  }
}

class Outcomes {
  final double avgStartingSalary;
  final String mobilityIndex;

  Outcomes({required this.avgStartingSalary, required this.mobilityIndex});

  factory Outcomes.fromJson(Map<String, dynamic> json) {
    return Outcomes(
      avgStartingSalary: (json['avgStartingSalary'] as num).toDouble(),
      mobilityIndex: json['mobilityIndex'] as String,
    );
  }
}

class Links {
  final String official;

  Links({required this.official});

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(official: json['official'] as String);
  }
}