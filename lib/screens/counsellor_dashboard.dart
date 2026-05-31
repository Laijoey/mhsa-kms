import 'package:flutter/material.dart';

class CounsellorDashboard extends StatefulWidget {
  const CounsellorDashboard({Key? key}) : super(key: key);

  @override
  State<CounsellorDashboard> createState() => _CounsellorDashboardState();
}

class _CounsellorDashboardState extends State<CounsellorDashboard> {
  String _selectedNav = 'Dashboard';

  // Sample flagged students data
  final List<Map<String, dynamic>> flaggedStudents = [
    {
      'name': 'John Doe',
      'id': 'S001',
      'severity': 'Severe',
      'date': '5/17/2026',
      'scores': {'depression': 24, 'anxiety': 20, 'stress': 28},
    },
    {
      'name': 'Jane Smith',
      'id': 'S002',
      'severity': 'Extremely Severe',
      'date': '5/16/2026',
      'scores': {'depression': 28, 'anxiety': 26, 'stress': 32},
    },
    {
      'name': 'Mike Johnson',
      'id': 'S003',
      'severity': 'Severe',
      'date': '5/15/2026',
      'scores': {'depression': 22, 'anxiety': 18, 'stress': 26},
    },
  ];

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Severe':
        return const Color(0xFFD32F2F);
      case 'Extremely Severe':
        return const Color(0xFF7B1FA2);
      default:
        return const Color(0xFFF57C00);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
              color: Colors.white,
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
                          color: const Color(0xFF6B9E7F),
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
                        onTap: () {
                          setState(() {
                            _selectedNav = 'Dashboard';
                          });
                        },
                      ),
                      const SizedBox(width: 40),
                      _NavButton(
                        label: 'High Risk',
                        isActive: _selectedNav == 'HighRisk',
                        onTap: () {
                          setState(() {
                            _selectedNav = 'HighRisk';
                          });
                        },
                      ),
                      const SizedBox(width: 40),
                      _NavButton(
                        label: 'Knowledge Base',
                        isActive: _selectedNav == 'Knowledge',
                        onTap: () {
                          setState(() {
                            _selectedNav = 'Knowledge';
                          });
                        },
                      ),
                      const SizedBox(width: 100),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
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
                          ],
                          onChanged: null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    const Text(
                      'COUNSELLOR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF999999),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Monitor & Support Student Wellbeing',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Review recent assessments, identify at-risk students, and access expert recommendations for interventions.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Statistics Cards
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Total Students',
                            value: '${128}',
                            icon: Icons.people,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _StatCard(
                            label: 'Flagged This Week',
                            value: '${flaggedStudents.length}',
                            icon: Icons.warning,
                            isAlert: true,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _StatCard(
                            label: 'Assessments',
                            value: '${342}',
                            icon: Icons.assignment,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Flagged Students Section
                    const Text(
                      'Recently Flagged Students',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...flaggedStudents.map((student) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(Icons.person, color: Color(0xFF6B9E7F)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
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
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getSeverityColor(student['severity']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getSeverityColor(student['severity']),
                                ),
                              ),
                              child: Text(
                                student['severity'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getSeverityColor(student['severity']),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.arrow_forward,
                              color: const Color(0xFF6B9E7F),
                              size: 20,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF1A1A1A) : const Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 8),
          if (isActive)
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF6B9E7F),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isAlert;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAlert ? const Color(0xFFD32F2F).withOpacity(0.3) : const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isAlert ? const Color(0xFFD32F2F) : const Color(0xFF6B9E7F),
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}
