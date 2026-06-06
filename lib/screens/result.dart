import 'package:flutter/material.dart';
import 'assessment.dart';
import 'progress.dart';
import 'student_session.dart';
import '../expert_system/recommendation_engine.dart';
import '../expert_system/risk_classifier.dart';

class ResultPage extends StatefulWidget {
  final int depression;
  final int anxiety;
  final int stress;
  final StudentSession? session;

  const ResultPage({
    Key? key,
    this.depression = 0,
    this.anxiety = 0,
    this.stress = 0,
    this.session,
  }) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String _selectedNav = 'Result';

  late Map<String, dynamic> resultData;

  String _getSeverity(int score, String type) {
    switch (type) {
      case 'depression':
        return RiskClassifier.classifyDepression(score).name;
      case 'anxiety':
        return RiskClassifier.classifyAnxiety(score).name;
      case 'stress':
        return RiskClassifier.classifyStress(score).name;
      default:
        return "normal";
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Normal':
        return const Color(0xFF4CAF50);
      case 'Mild':
        return const Color(0xFF8BC34A);
      case 'Moderate':
        return const Color(0xFFF57C00);
      case 'Severe':
        return const Color(0xFFD32F2F);
      case 'Extremely Severe':
        return const Color(0xFF7B1FA2);
      default:
        return const Color(0xFF999999);
    }
  }

  void _handleAccountAction(String? value) {
    if (value == 'logout') {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  void initState() {
    super.initState();

    resultData = RecommendationEngine.generate(
      depression: widget.depression,
      anxiety: widget.anxiety,
      stress: widget.stress,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF5EFE7),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo and Title
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF354B0E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MHSA-KMS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            'MENTAL HEALTH KNOWLEDGE SYSTEM',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF999999),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Navigation and Dropdown
                  Row(
                    children: [
                      _NavButton(
                        label: 'Dashboard',
                        isActive: _selectedNav == 'Dashboard',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 30),
                      _NavButton(
                        label: 'Assessment',
                        isActive: _selectedNav == 'Assessment',
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, anim1, anim2) => AssessmentPage(
                                session: widget.session,
                              ),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 30),
                      _NavButton(
                        label: 'Result',
                        isActive: _selectedNav == 'Result',
                        onTap: () {
                          setState(() {
                            _selectedNav = 'Result';
                          });
                        },
                      ),
                      const SizedBox(width: 30),
                      _NavButton(
                        label: 'Progress',
                        isActive: _selectedNav == 'Progress',
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, anim1, anim2) => ProgressPage(
                                session: widget.session,
                              ),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 60),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFDDD5CE)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: DropdownButton<String>(
                          value: 'Student',
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: 'Student',
                              child: Text(
                                'Student',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'logout',
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                          ],
                          onChanged: _handleAccountAction,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 54),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1220),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Result Title Section
                        const Text(
                          'YOUR RESULT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF999999),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'A snapshot of your past week.',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Taken 5/17/2026, 12:36:10 PM',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Metrics Cards
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                label: 'DEPRESSION',
                                score: '${widget.depression}',
                                maxScore: '42',
                                status: _getSeverity(widget.depression, 'depression'),
                                statusColor: _getSeverityColor(
                                    _getSeverity(widget.depression, 'depression')),
                                progressColor: _getSeverityColor(
                                    _getSeverity(widget.depression, 'depression')),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _MetricCard(
                                label: 'ANXIETY',
                                score: '${widget.anxiety}',
                                maxScore: '42',
                                status: _getSeverity(widget.anxiety, 'anxiety'),
                                statusColor: _getSeverityColor(
                                    _getSeverity(widget.anxiety, 'anxiety')),
                                progressColor: _getSeverityColor(
                                    _getSeverity(widget.anxiety, 'anxiety')),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _MetricCard(
                                label: 'STRESS',
                                score: '${widget.stress}',
                                maxScore: '42',
                                status: _getSeverity(widget.stress, 'stress'),
                                statusColor: _getSeverityColor(
                                    _getSeverity(widget.stress, 'stress')),
                                progressColor: _getSeverityColor(
                                    _getSeverity(widget.stress, 'stress')),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Recommendation Section
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F1EB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFBFB8AD),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    '✨ Personalised recommendation',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEBEE),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFD32F2F),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      'Severe',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFD32F2F),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Generated by Expert System Rule Engine',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),

                              const SizedBox(height: 16),

                              Text(
                                'Risk Level: ${resultData["riskLevel"]}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD32F2F),
                                ),
                              ),

                              const SizedBox(height: 16),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: (resultData["recommendations"] as List<String>)
                                    .map((r) => Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Text("• $r"),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProgressPage(
                                            session: widget.session,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.arrow_forward),
                                    label: const Text('View progress'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF354B0E),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AssessmentPage(
                                            session: widget.session,
                                          ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFFDDD5CE),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                    ),
                                    child: const Text(
                                      'Re-take assessment',
                                      style: TextStyle(
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF354B0E) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : const Color(0xFF999999),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String score;
  final String maxScore;
  final String status;
  final Color statusColor;
  final Color progressColor;

  const _MetricCard({
    required this.label,
    required this.score,
    required this.maxScore,
    required this.status,
    required this.statusColor,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    double progress = double.parse(score) / double.parse(maxScore);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1EB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBFB8AD),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF354B0E)),
          ),
          child: const Text(
            "Rule Engine Active ✔",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF354B0E),
            ),
          ),
        ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF999999),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '/ $maxScore',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            score,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              height: 1,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
