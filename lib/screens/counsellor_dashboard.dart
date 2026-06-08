import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'counsellor_high_risk.dart';
import 'knowledge_base.dart';

class CounsellorDashboard extends StatefulWidget {
  const CounsellorDashboard({Key? key}) : super(key: key);

  @override
  State<CounsellorDashboard> createState() => _CounsellorDashboardState();
}

class _CounsellorDashboardState extends State<CounsellorDashboard> {
  String _selectedNav = 'Dashboard';
  Map<String, dynamic>? _analytics;
  List<Map<String, dynamic>> flaggedStudents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.getCampusAnalytics(),
        ApiService.getHighRiskQueue(),
      ]);

      if (mounted) {
        setState(() {
          _analytics = results[0] as Map<String, dynamic>;
          flaggedStudents = results[1] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleAccountAction(String? value) {
    if (value == 'logout') {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
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
                        onTap: () {
                          setState(() {
                            _selectedNav = 'Dashboard';
                          });
                        },
                      ),
                      const SizedBox(width: 30),
                      _NavButton(
                        label: 'High Risk',
                        isActive: _selectedNav == 'HighRisk',
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, anim1, anim2) => const CounsellorHighRisk(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 30),
                      _NavButton(
                        label: 'Knowledge Base',
                        isActive: _selectedNav == 'Knowledge',
                        onTap: () {
                          Navigator.push(
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
                      'Cohort overview.',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Latest assessment per student, severity distribution, and students currently flagged for follow-up.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Statistics Cards
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: 'Students tracked',
                                  value: '${_analytics?['totalAssessed'] ?? 0}',
                                  icon: Icons.people_outline,
                                  iconBgColor: const Color(0xFFE2EBE2),
                                  iconColor: const Color(0xFF354B0E),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _StatCard(
                                  label: 'High-risk',
                                  value: '${((_analytics?['riskLevelCounts']?['HIGH'] ?? 0) as int) + ((_analytics?['riskLevelCounts']?['CRITICAL'] ?? 0) as int)}',
                                  icon: Icons.warning_amber_rounded,
                                  iconBgColor: const Color(0xFFFDE8E8),
                                  iconColor: const Color(0xFFD32F2F),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _StatCard(
                                  label: 'Avg Depression',
                                  value: '${(_analytics?['averageScores']?['dep'] as num?)?.round() ?? 0}',
                                  icon: Icons.show_chart,
                                  iconBgColor: const Color(0xFFE2EBE2),
                                  iconColor: const Color(0xFF354B0E),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _StatCard(
                                  label: 'Avg Anxiety',
                                  value: '${(_analytics?['averageScores']?['anx'] as num?)?.round() ?? 0}',
                                  icon: Icons.show_chart,
                                  iconBgColor: const Color(0xFFE2EBE2),
                                  iconColor: const Color(0xFF354B0E),
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 40),

                    // Two-Column Content
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Severity Distribution
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F1EB),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFBFB8AD)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Severity distribution',
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _SeverityRow(
                                  label: 'Normal',
                                  value: 0.0,
                                  color: const Color(0xFFE2EBE2),
                                  textColor: const Color(0xFF354B0E),
                                ),
                                const SizedBox(height: 16),
                                _SeverityRow(
                                  label: 'Mild',
                                  value: 0.0,
                                  color: const Color(0xFFE2EBE2),
                                  textColor: const Color(0xFF354B0E),
                                ),
                                const SizedBox(height: 16),
                                _SeverityRow(
                                  label: 'Moderate',
                                  value: 0.0,
                                  color: const Color(0xFFFFF3E0),
                                  textColor: const Color(0xFFEF6C00),
                                ),
                                const SizedBox(height: 16),
                                _SeverityRow(
                                  label: 'Severe',
                                  value: 0.0,
                                  color: const Color(0xFFFFEBEE),
                                  textColor: const Color(0xFFD32F2F),
                                ),
                                const SizedBox(height: 16),
                                _SeverityRow(
                                  label: 'Extremely Severe',
                                  value: 0.0,
                                  color: const Color(0xFFF3E5F5),
                                  textColor: const Color(0xFF7B1FA2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right Column: High-risk students
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F1EB),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFBFB8AD)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'High-risk students',
                                      style: TextStyle(
                                        fontFamily: 'serif',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, anim1, anim2) => const CounsellorHighRisk(),
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration: Duration.zero,
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: const [
                                          Text(
                                            'View all',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF666666),
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: 14,
                                            color: Color(0xFF666666),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _HighRiskStudentItem(
                                  name: 'Aiman Tan',
                                  id: 'S001',
                                  course: 'BSc Computer Science',
                                  severity: 'Severe',
                                  severityColor: const Color(0xFFD32F2F),
                                  severityBgColor: const Color(0xFFFFEBEE),
                                ),
                                const SizedBox(height: 12),
                                _HighRiskStudentItem(
                                  name: 'Priya Raman',
                                  id: 'S002',
                                  course: 'BA Psychology',
                                  severity: 'Extremely Severe',
                                  severityColor: const Color(0xFF7B1FA2),
                                  severityBgColor: const Color(0xFFF3E5F5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1EB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBFB8AD),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityRow extends StatelessWidget {
  final String label;
  final double value; // between 0.0 and 1.0
  final Color color; // badge background
  final Color textColor; // badge text color

  const _SeverityRow({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 130,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFE2EBE2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  color: textColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '${(value * 100).toStringAsFixed(1)}%',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }
}

class _HighRiskStudentItem extends StatelessWidget {
  final String name;
  final String id;
  final String course;
  final String severity;
  final Color severityColor;
  final Color severityBgColor;

  const _HighRiskStudentItem({
    required this.name,
    required this.id,
    required this.course,
    required this.severity,
    required this.severityColor,
    required this.severityBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1EB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFB8AD)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$id · $course',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: severityBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: severityColor),
            ),
            child: Text(
              severity,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: severityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
