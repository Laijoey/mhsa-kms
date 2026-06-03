import 'package:flutter/material.dart';
import 'knowledge_base.dart';

class CounsellorHighRisk extends StatefulWidget {
  const CounsellorHighRisk({Key? key}) : super(key: key);

  @override
  State<CounsellorHighRisk> createState() => _CounsellorHighRiskState();
}

class _CounsellorHighRiskState extends State<CounsellorHighRisk> {
  String _selectedNav = 'HighRisk';

  void _handleAccountAction(String? value) {
    if (value == 'logout') {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  // High-risk students data
  final List<Map<String, dynamic>> highRiskStudents = [
    {
      'name': 'Priya Raman',
      'id': 'S002',
      'severity': 'Extremely Severe',
      'date': '5/16/2026',
      'depression': 28,
      'anxiety': 26,
      'stress': 32,
      'recommendation': 'Immediate referral to campus health center recommended.',
    },
    {
      'name': 'Aiman Tan',
      'id': 'S001',
      'severity': 'Severe',
      'date': '5/17/2026',
      'depression': 24,
      'anxiety': 20,
      'stress': 28,
      'recommendation': 'Schedule counselling session within 48 hours.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
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
                  // Navigation Tabs
                  Row(
                    children: [
                      _NavButton(
                        label: 'Dashboard',
                        isActive: _selectedNav == 'Dashboard',
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 30),
                      _NavButton(
                        label: 'High Risk',
                        isActive: _selectedNav == 'HighRisk',
                        onTap: () {},
                      ),
                      const SizedBox(width: 30),
                      _NavButton(
                        label: 'Knowledge Base',
                        isActive: _selectedNav == 'Knowledge',
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, anim1, anim2) => const KnowledgeBasePage(
                                userRole: 'counsellor',
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
                          value: 'Counsellor',
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: 'Counsellor',
                              child: Text(
                                'Counsellor',
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
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    const Text(
                      'HIGH RISK STUDENTS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF999999),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Immediate Intervention Required',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Students flagged with severe or extremely severe mental health concerns require immediate attention and support.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Alert Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning,
                            color: Color(0xFFD32F2F),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Active Cases',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD32F2F),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${highRiskStudents.length} students require immediate support or follow-up',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFD32F2F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // High Risk Students List
                    ...highRiskStudents.map((student) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F1EB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFB8AD)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 4,
                                color: student['severity'] == 'Extremely Severe'
                                    ? const Color(0xFF7B1FA2)
                                    : const Color(0xFFD32F2F),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID: ${student['id']} · Assessed: ${student['date']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF999999),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: student['severity'] == 'Extremely Severe'
                                        ? const Color(0xFFF3E5F5)
                                        : const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: student['severity'] == 'Extremely Severe'
                                          ? const Color(0xFF7B1FA2)
                                          : const Color(0xFFD32F2F),
                                    ),
                                  ),
                                  child: Text(
                                    student['severity'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: student['severity'] == 'Extremely Severe'
                                          ? const Color(0xFF7B1FA2)
                                          : const Color(0xFFD32F2F),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Scores
                            Row(
                              children: [
                                Expanded(
                                  child: _ScoreBox(
                                    label: 'Depression',
                                    score: student['depression'],
                                    color: const Color(0xFFD32F2F),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _ScoreBox(
                                    label: 'Anxiety',
                                    score: student['anxiety'],
                                    color: const Color(0xFFF57C00),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _ScoreBox(
                                    label: 'Stress',
                                    score: student['stress'],
                                    color: const Color(0xFFF57C00),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Recommendation
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF5F0),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFF0E8DF),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Recommendation',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF354B0E),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    student['recommendation'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF333333),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Action Buttons
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.phone),
                                  label: const Text('Contact Student'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF354B0E),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.note_add),
                                  label: const Text('Add Note'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFFDDD5CE),
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
                );
                    }).toList(),
                  ],
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

class _ScoreBox extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _ScoreBox({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '/ 42',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}
