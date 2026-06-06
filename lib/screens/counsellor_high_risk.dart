import 'package:flutter/material.dart';
import 'knowledge_base.dart';

class CounsellorHighRisk extends StatefulWidget {
  const CounsellorHighRisk({Key? key}) : super(key: key);

  @override
  State<CounsellorHighRisk> createState() => _CounsellorHighRiskState();
}

class _CounsellorHighRiskState extends State<CounsellorHighRisk> {
  final String _selectedNav = 'HighRisk';
  Map<String, dynamic>? _selectedStudent;

  void _handleAccountAction(String? value) {
    if (value == 'logout') {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  // Campus distress history data for Weeks 1 to 14
  final List<Map<String, dynamic>> _campusWeeklyHistory = [
    {'week': 1, 'depression': 10, 'anxiety': 8, 'stress': 12},
    {'week': 2, 'depression': 11, 'anxiety': 9, 'stress': 13},
    {'week': 3, 'depression': 11, 'anxiety': 10, 'stress': 14},
    {'week': 4, 'depression': 12, 'anxiety': 11, 'stress': 13},
    {'week': 5, 'depression': 13, 'anxiety': 12, 'stress': 15},
    {'week': 6, 'depression': 15, 'anxiety': 14, 'stress': 18}, // Midterms start
    {'week': 7, 'depression': 17, 'anxiety': 16, 'stress': 22}, // Midterms peak
    {'week': 8, 'depression': 16, 'anxiety': 15, 'stress': 19},
    {'week': 9, 'depression': 14, 'anxiety': 13, 'stress': 16},
    {'week': 10, 'depression': 15, 'anxiety': 14, 'stress': 18},
    {'week': 11, 'depression': 17, 'anxiety': 16, 'stress': 20},
    {'week': 12, 'depression': 19, 'anxiety': 18, 'stress': 24}, // Projects peak
    {'week': 13, 'depression': 21, 'anxiety': 20, 'stress': 27}, // Study week
    {'week': 14, 'depression': 22, 'anxiety': 21, 'stress': 28}, // Exams peak
  ];

  // High-risk student alerts queue data
  final List<Map<String, dynamic>> _highRiskQueue = [
    {
      'uuid': 'd3b07384-d113-4c32-a5b5-0c841e21b212',
      'riskLevel': 'CRITICAL',
      'timestamp': '2026-06-04 15:32',
      'depression': 32, // Extremely Severe (>= 28)
      'anxiety': 28,    // Extremely Severe (>= 20)
      'stress': 36,     // Extremely Severe (>= 34)
      'ruleTriggered': 'Rule R-001: CRITICAL',
      'ruleDescription': 'Triggered by Extremely Severe score (Depression >= 28, Anxiety >= 20, or Stress >= 34) indicating high risk of acute distress and potential self-harm.',
      'tacitBadges': ['Rule R-C03: Repeat High-Risk Override', 'Rule R-C02: Academic Stress Peak'],
      'intervention': 'CRITICAL INTERVENTION PROTOCOL ACTIVATED:\n\n1. Immediate Outbound Contact: Initiate emergency phone contact immediately.\n2. Crisis Hotline Referral: Provide University Suicide & Crisis Lifeline contact detail (+603-7967-3245).\n3. Coping Packet: Dispatch Coping Packet C-01 (Crisis Management, Breathing Exercises, and Grounding Techniques).\n4. Clinical Consultation: Schedule mandatory face-to-face evaluation with the lead wellness counsellor within 12 hours.',
      'contacted': false,
    },
    {
      'uuid': '8f27ab3e-2b1d-4074-9c88-e21b9c9f28a3',
      'riskLevel': 'CRITICAL',
      'timestamp': '2026-06-04 11:15',
      'depression': 14, // Moderate (14-20)
      'anxiety': 22,    // Extremely Severe (>= 20)
      'stress': 18,     // Mild (15-18)
      'ruleTriggered': 'Rule R-001: CRITICAL',
      'ruleDescription': 'Triggered by Extremely Severe Anxiety (Anxiety >= 20), indicating potential panic disorder or severe somatic distress.',
      'tacitBadges': ['Rule R-C02: Academic Stress Peak'],
      'intervention': 'CRITICAL ANXIETY INTERVENTION:\n\n1. Immediate Referral: Recommend immediate consultation with campus health physician for somatic symptoms.\n2. Coping Packet: Dispatch Coping Packet A-02 (Somatic Calmness & Breathing Exercises).\n3. Support Contact: Assign case officer and schedule intake interview within 24 hours.',
      'contacted': false,
    },
    {
      'uuid': 'c2b7a9e0-d85c-412e-9d2a-f3e1b0a5c4d6',
      'riskLevel': 'HIGH',
      'timestamp': '2026-06-03 16:45',
      'depression': 24, // Severe (21-27)
      'anxiety': 12,    // Moderate (10-14)
      'stress': 22,     // Moderate (19-25)
      'ruleTriggered': 'Rule R-002: HIGH',
      'ruleDescription': 'Triggered by Severe Depression score (Depression 21-27), indicating persistent low mood and withdrawal.',
      'tacitBadges': ['Rule R-C01: Multi-Domain Moderate Escalation'],
      'intervention': 'HIGH RISK DEPRESSION STRATEGY:\n\n1. Counselling Consultation: Schedule an intake assessment within 48 hours.\n2. Academic Adjustments: Provide recommendation letter template for temporary assignment extensions.\n3. Coping Packet: Dispatch Coping Packet D-03 (Cognitive Reframing for Academic Success).',
      'contacted': false,
    },
    {
      'uuid': 'fa82b9c0-128a-4d7e-9081-3e4b2d1c0a8f',
      'riskLevel': 'HIGH',
      'timestamp': '2026-06-03 09:30',
      'depression': 18, // Moderate (14-20)
      'anxiety': 16,    // Severe (15-19)
      'stress': 20,     // Moderate (19-25)
      'ruleTriggered': 'Rule R-002: HIGH',
      'ruleDescription': 'Triggered by Severe Anxiety score (Anxiety 15-19), indicating high academic and social anxiety.',
      'tacitBadges': ['Rule R-C01: Multi-Domain Moderate Escalation'],
      'intervention': 'HIGH RISK ANXIETY STRATEGY:\n\n1. Mindfulness Workshop: Enroll in the weekly campus anxiety management circle.\n2. Coping Packet: Send Exam Stress Management Guide & Guided Audio Packets.\n3. Follow-up: Schedule standard progress check-in within 3 days.',
      'contacted': false,
    },
    {
      'uuid': '1d2e3f4a-5b6c-7d8e-9f0a-1b2c3d4e5f6g',
      'riskLevel': 'HIGH',
      'timestamp': '2026-06-02 14:05',
      'depression': 19, // Moderate (14-20)
      'anxiety': 13,    // Moderate (10-14)
      'stress': 25,     // Moderate (19-25)
      'ruleTriggered': 'Rule R-003: MODERATE (Escalated)',
      'ruleDescription': 'Evaluated as MODERATE but escalated to HIGH due to concurrent moderate scores across all three sub-scales indicating complex distress.',
      'tacitBadges': ['Rule R-C01: Multi-Domain Moderate Escalation', 'Rule R-C03: Repeat High-Risk Student Override'],
      'intervention': 'SYSTEMIC MULTI-DOMAIN ESCALATION STRATEGY:\n\n1. Priority Intake: Escalated due to co-occurring moderate distress in Depression, Anxiety, and Stress. Schedule intake within 72 hours.\n2. General Coping Packet: Dispatch Coping Packet G-04 (General Wellness, Sleep Hygiene, and Routine Balance).\n3. Faculty Liaison: Monitor academic performance indicators.',
      'contacted': false,
    },
  ];

  void _onStudentSelected(Map<String, dynamic> student) {
    setState(() {
      _selectedStudent = student;
    });
  }

  void _onInitiateIntervention(Map<String, dynamic> student) {
    setState(() {
      student['contacted'] = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5F1EB),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFBFB8AD)),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF354B0E)),
            SizedBox(width: 8),
            Text(
              'Intervention Initiated',
              style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'The Tacit-Derived Intervention Strategy has been logged for case:\n${student['uuid']}\n\nCopied coping packets and wellness resources have been dispatched to the student\'s portal.',
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF354B0E)),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    const Text(
                      'COUNSELLOR CONTROL CENTER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF999999),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'High-Risk Student Alert Queue',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          'Campus distress overview and high-priority cases',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF666666).withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Section 1: Student Risk Overview Dashboard (KPI Cards + Line Chart)
                    SizedBox(
                      height: 200,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Side: 3 KPI Cards
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _KpiCard(
                                    title: 'Total Assessed',
                                    value: '184',
                                    icon: Icons.people_outline,
                                    iconColor: const Color(0xFF354B0E),
                                    iconBg: const Color(0xFFE2EBE2),
                                    subtitle: const Text(
                                      '+12% assessed this semester',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF354B0E), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _KpiCard(
                                    title: 'Active Alerts',
                                    value: '${_highRiskQueue.length}',
                                    icon: Icons.warning_amber_rounded,
                                    iconColor: const Color(0xFFD32F2F),
                                    iconBg: const Color(0xFFFFEBEE),
                                    subtitle: Text(
                                      '${_highRiskQueue.where((s) => s['riskLevel'] == 'CRITICAL').length} critical, ${_highRiskQueue.where((s) => s['riskLevel'] == 'HIGH').length} high risk',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFFD32F2F), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _KpiCard(
                                    title: 'Campus Averages',
                                    value: 'Moderate',
                                    icon: Icons.analytics_outlined,
                                    iconColor: const Color(0xFFEF6C00),
                                    iconBg: const Color(0xFFFFF3E0),
                                    subtitle: const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Depression: 14.5/42 (Mod)', style: TextStyle(fontSize: 10, color: Color(0xFF666666))),
                                        Text('Anxiety: 13.2/42 (Mod)', style: TextStyle(fontSize: 10, color: Color(0xFF666666))),
                                        Text('Stress: 16.8/42 (Mild)', style: TextStyle(fontSize: 10, color: Color(0xFF666666))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Right Side: Campus Distress Line Chart
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F1EB),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFBFB8AD)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Distress Levels over Semester (Weeks 1-14)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      // Legend
                                      Row(
                                        children: [
                                          _LegendDot(color: const Color(0xFFD32F2F), label: 'D'),
                                          const SizedBox(width: 6),
                                          _LegendDot(color: const Color(0xFFEF6C00), label: 'A'),
                                          const SizedBox(width: 6),
                                          _LegendDot(color: const Color(0xFFFBC02D), label: 'S'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: CampusDistressLineChart(
                                      history: _campusWeeklyHistory,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Split Queue and Assessment Breakdown Layout
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left side: Alerts Queue Table (Scrollable)
                          Expanded(
                            flex: 3,
                            child: _AlertQueueTable(
                              queue: _highRiskQueue,
                              selectedStudent: _selectedStudent,
                              onSelect: _onStudentSelected,
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Right side: Detail Review Panel
                          Expanded(
                            flex: 2,
                            child: _selectedStudent == null
                                ? const _EmptyDetailPlaceholder()
                                : _AssessmentSummaryPanel(
                                    student: _selectedStudent!,
                                    onMarkContacted: () => _onInitiateIntervention(_selectedStudent!),
                                  ),
                          ),
                        ],
                      ),
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

// KPI Dashboard Card
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _KpiCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1EB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFB8AD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            subtitle!,
          ],
        ],
      ),
    );
  }
}

// Legend indicator dot for chart
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF666666)),
        ),
      ],
    );
  }
}

// Custom Painter Line Chart Widget
class CampusDistressLineChart extends StatefulWidget {
  final List<Map<String, dynamic>> history;
  const CampusDistressLineChart({Key? key, required this.history}) : super(key: key);

  @override
  State<CampusDistressLineChart> createState() => _CampusDistressLineChartState();
}

class _CampusDistressLineChartState extends State<CampusDistressLineChart> {
  int? hoveredWeek;
  Offset? hoverPosition;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final size = renderBox.size;
        const double paddingLeft = 30.0;
        const double paddingRight = 10.0;
        final double chartWidth = size.width - paddingLeft - paddingRight;
        final double xRatio = chartWidth / 13.0;

        final double localX = event.localPosition.dx;
        if (localX >= paddingLeft && localX <= size.width - paddingRight) {
          final int week = ((localX - paddingLeft) / xRatio).round() + 1;
          if (week >= 1 && week <= 14) {
            setState(() {
              hoveredWeek = week;
              hoverPosition = event.localPosition;
            });
            return;
          }
        }
        setState(() {
          hoveredWeek = null;
          hoverPosition = null;
        });
      },
      onExit: (_) {
        setState(() {
          hoveredWeek = null;
          hoverPosition = null;
        });
      },
      child: CustomPaint(
        size: Size.infinite,
        painter: LineChartPainter(
          history: widget.history,
          hoveredWeek: hoveredWeek,
          hoverPosition: hoverPosition,
        ),
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> history;
  final int? hoveredWeek;
  final Offset? hoverPosition;

  LineChartPainter({
    required this.history,
    this.hoveredWeek,
    this.hoverPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double paddingLeft = 30.0;
    const double paddingRight = 10.0;
    const double paddingTop = 10.0;
    const double paddingBottom = 20.0;

    final double width = size.width;
    final double height = size.height;
    final double chartWidth = width - paddingLeft - paddingRight;
    final double chartHeight = height - paddingTop - paddingBottom;

    final double xRatio = chartWidth / 13.0;
    final double yRatio = chartHeight / 42.0;

    // Draw Grid Lines (Y axis values: 0, 10, 20, 30, 42)
    final gridPaint = Paint()
      ..color = const Color(0xFFDDD5CE).withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final List<int> yGridValues = [0, 10, 20, 30, 42];
    for (var val in yGridValues) {
      double y = height - paddingBottom - val * yRatio;
      // Draw grid line
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(width - paddingRight, y),
        gridPaint,
      );

      // Draw label
      textPainter.text = TextSpan(
        text: '$val',
        style: const TextStyle(
          color: Color(0xFF999999),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(paddingLeft - textPainter.width - 6, y - textPainter.height / 2),
      );
    }

    // Draw Weeks Labels on X-axis (Weeks 1, 4, 7, 10, 14)
    final List<int> xGridWeeks = [1, 4, 7, 10, 14];
    for (var wk in xGridWeeks) {
      double x = paddingLeft + (wk - 1) * xRatio;
      textPainter.text = TextSpan(
        text: 'W$wk',
        style: const TextStyle(
          color: Color(0xFF999999),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, height - paddingBottom + 4),
      );
    }

    // Draw lines for Depression (Crimson), Anxiety (Orange), Stress (Amber)
    final depPaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final anxPaint = Paint()
      ..color = const Color(0xFFEF6C00)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final strPaint = Paint()
      ..color = const Color(0xFFFBC02D)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final depPath = Path();
    final anxPath = Path();
    final strPath = Path();

    // Create paths
    for (int i = 0; i < history.length; i++) {
      final item = history[i];
      final int wk = item['week'] as int;
      final double x = paddingLeft + (wk - 1) * xRatio;

      final double depY = height - paddingBottom - (item['depression'] as int) * yRatio;
      final double anxY = height - paddingBottom - (item['anxiety'] as int) * yRatio;
      final double strY = height - paddingBottom - (item['stress'] as int) * yRatio;

      if (i == 0) {
        depPath.moveTo(x, depY);
        anxPath.moveTo(x, anxY);
        strPath.moveTo(x, strY);
      } else {
        depPath.lineTo(x, depY);
        anxPath.lineTo(x, anxY);
        strPath.lineTo(x, strY);
      }
    }

    // Draw paths
    canvas.drawPath(depPath, depPaint);
    canvas.drawPath(anxPath, anxPaint);
    canvas.drawPath(strPath, strPaint);

    // Draw little dots on vertices
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < history.length; i++) {
      final item = history[i];
      final int wk = item['week'] as int;
      final double x = paddingLeft + (wk - 1) * xRatio;

      final double depY = height - paddingBottom - (item['depression'] as int) * yRatio;
      final double anxY = height - paddingBottom - (item['anxiety'] as int) * yRatio;
      final double strY = height - paddingBottom - (item['stress'] as int) * yRatio;

      // Draw Depression Dot
      dotPaint.color = Colors.white;
      canvas.drawCircle(Offset(x, depY), 2.5, dotPaint);
      dotPaint.color = const Color(0xFFD32F2F);
      canvas.drawCircle(Offset(x, depY), 1.5, dotPaint);

      // Draw Anxiety Dot
      dotPaint.color = Colors.white;
      canvas.drawCircle(Offset(x, anxY), 2.5, dotPaint);
      dotPaint.color = const Color(0xFFEF6C00);
      canvas.drawCircle(Offset(x, anxY), 1.5, dotPaint);

      // Draw Stress Dot
      dotPaint.color = Colors.white;
      canvas.drawCircle(Offset(x, strY), 2.5, dotPaint);
      dotPaint.color = const Color(0xFFFBC02D);
      canvas.drawCircle(Offset(x, strY), 1.5, dotPaint);
    }

    // Draw Hover Dash Line & Tooltip
    if (hoveredWeek != null) {
      final double x = paddingLeft + (hoveredWeek! - 1) * xRatio;
      final dashPaint = Paint()
        ..color = const Color(0xFFBFB8AD)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      // Draw dashed line
      double startY = paddingTop;
      double endY = height - paddingBottom;
      const double dashLength = 4.0;
      const double spaceLength = 4.0;
      while (startY < endY) {
        canvas.drawLine(
          Offset(x, startY),
          Offset(x, startY + dashLength),
          dashPaint,
        );
        startY += dashLength + spaceLength;
      }

      // Find the data for this week
      final weekData = history.firstWhere((element) => element['week'] == hoveredWeek);
      final int dep = weekData['depression'] as int;
      final int anx = weekData['anxiety'] as int;
      final int str = weekData['stress'] as int;

      // Draw tooltip box
      final double tooltipWidth = 100.0;
      final double tooltipHeight = 65.0;
      double tooltipX = x + 10;
      double tooltipY = paddingTop + 10;

      // Adjust tooltip position if it overflows the right edge
      if (tooltipX + tooltipWidth > width - paddingRight) {
        tooltipX = x - tooltipWidth - 10;
      }

      final tooltipRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(tooltipX, tooltipY, tooltipWidth, tooltipHeight),
        const Radius.circular(6),
      );

      final tooltipBgPaint = Paint()
        ..color = const Color(0xFF354B0E)
        ..style = PaintingStyle.fill;
      final tooltipBorderPaint = Paint()
        ..color = const Color(0xFFBFB8AD)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      canvas.drawRRect(tooltipRect, tooltipBgPaint);
      canvas.drawRRect(tooltipRect, tooltipBorderPaint);

      // Write text inside tooltip
      final textSpan = TextSpan(
        text: 'Week $hoveredWeek\n',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: 'Depression: $dep\n',
            style: const TextStyle(
              color: Color(0xFFFFCDD2),
              fontSize: 8.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: 'Anxiety: $anx\n',
            style: const TextStyle(
              color: Color(0xFFFFFFE0),
              fontSize: 8.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: 'Stress: $str',
            style: const TextStyle(
              color: Color(0xFFFFE0B2),
              fontSize: 8.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );

      textPainter.text = textSpan;
      textPainter.layout(maxWidth: tooltipWidth - 16);
      textPainter.paint(canvas, Offset(tooltipX + 8, tooltipY + 6));
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.hoveredWeek != hoveredWeek ||
        oldDelegate.hoverPosition != hoverPosition ||
        oldDelegate.history != history;
  }
}

// High-Risk Student Urgent Alert Queue Table View
class _AlertQueueTable extends StatelessWidget {
  final List<Map<String, dynamic>> queue;
  final Map<String, dynamic>? selectedStudent;
  final ValueChanged<Map<String, dynamic>> onSelect;

  const _AlertQueueTable({
    Key? key,
    required this.queue,
    required this.selectedStudent,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1EB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFB8AD)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Title Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Urgent Alert Queue',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF354B0E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${queue.length} Active Alerts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFBFB8AD)),
          // Data Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: const Color(0xFFDDD5CE),
                ),
                child: DataTable(
                  showCheckboxColumn: false,
                  columnSpacing: 16,
                  columns: const [
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Anonymized User ID',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Risk Flag',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Date/Time Stamp',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Action',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                  ],
                  rows: queue.map((student) {
                    final isSelected = selectedStudent != null && selectedStudent!['uuid'] == student['uuid'];
                    final isCritical = student['riskLevel'] == 'CRITICAL';
                    final isContacted = student['contacted'] as bool;
                    
                    return DataRow(
                      selected: isSelected,
                      onSelectChanged: (_) => onSelect(student),
                      color: MaterialStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(MaterialState.selected)) {
                          return const Color(0xFFE2EBE2); // Muted selected green
                        }
                        if (states.contains(MaterialState.hovered)) {
                          return const Color(0xFFEFECE6); // Muted hover cream
                        }
                        return null; // Default
                      }),
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              Text(
                                _truncateUuid(student['uuid']),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12.5,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              if (isContacted) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF354B0E),
                                  size: 14,
                                ),
                              ],
                            ],
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCritical ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isCritical ? const Color(0xFFD32F2F) : const Color(0xFFEF6C00),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 10,
                                  color: isCritical ? const Color(0xFFD32F2F) : const Color(0xFFEF6C00),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  student['riskLevel'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isCritical ? const Color(0xFFD32F2F) : const Color(0xFFEF6C00),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            student['timestamp'],
                            style: const TextStyle(fontSize: 12.5, color: Color(0xFF666666)),
                          ),
                        ),
                        DataCell(
                          ElevatedButton(
                            onPressed: () => onSelect(student),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: isSelected ? const Color(0xFF354B0E) : Colors.white,
                              foregroundColor: isSelected ? Colors.white : const Color(0xFF354B0E),
                              side: BorderSide(
                                color: isSelected ? Colors.transparent : const Color(0xFF354B0E),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              isSelected ? 'Reviewing' : 'Review Case',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _truncateUuid(String uuid) {
    if (uuid.length <= 16) return uuid;
    return '${uuid.substring(0, 8)}...${uuid.substring(uuid.length - 6)}';
  }
}

// Detailed Assessment Summary & Recommendation Review Panel
class _AssessmentSummaryPanel extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onMarkContacted;

  const _AssessmentSummaryPanel({
    Key? key,
    required this.student,
    required this.onMarkContacted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCritical = student['riskLevel'] == 'CRITICAL';
    final isContacted = student['contacted'] as bool;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1EB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFB8AD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Panel Title Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Diagnostic Breakdown',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'UUID: ${student['uuid']}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCritical ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isCritical ? const Color(0xFFD32F2F) : const Color(0xFFEF6C00),
                  ),
                ),
                child: Text(
                  student['riskLevel'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isCritical ? const Color(0xFFD32F2F) : const Color(0xFFEF6C00),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assessed: ${student['timestamp']}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
              ),
              if (isContacted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2EBE2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Color(0xFF354B0E), size: 10),
                      SizedBox(width: 4),
                      Text(
                        'Intervention Logged',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF354B0E)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFBFB8AD)),
          const SizedBox(height: 12),

          // Scrollable diagnostic contents
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // DASS-21 Score Meters
                  const Text(
                    'DASS-21 Sub-scale Scores',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF354B0E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ScoreMeter(
                    label: 'Depression',
                    score: student['depression'],
                    severity: _getDepressionSeverity(student['depression']),
                    color: const Color(0xFFD32F2F),
                  ),
                  const SizedBox(height: 12),
                  _ScoreMeter(
                    label: 'Anxiety',
                    score: student['anxiety'],
                    severity: _getAnxietySeverity(student['anxiety']),
                    color: const Color(0xFFEF6C00),
                  ),
                  const SizedBox(height: 12),
                  _ScoreMeter(
                    label: 'Stress',
                    score: student['stress'],
                    severity: _getStressSeverity(student['stress']),
                    color: const Color(0xFFFBC02D),
                  ),
                  const SizedBox(height: 16),

                  // Explicit Production Rules
                  const Text(
                    'Triggered Rules (Explicit)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF354B0E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFDDD5CE)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.rule,
                              size: 14,
                              color: isCritical ? const Color(0xFFD32F2F) : const Color(0xFFEF6C00),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              student['ruleTriggered'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCritical ? const Color(0xFFD32F2F) : const Color(0xFFEF6C00),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          student['ruleDescription'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF666666),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tacit Knowledge Heuristics Badges
                  const Text(
                    'Tacit Heuristics (Combination)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF354B0E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if ((student['tacitBadges'] as List).isEmpty)
                    const Text(
                      'No combinations rules triggered.',
                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF999999)),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: (student['tacitBadges'] as List<String>).map((badge) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF354B0E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF354B0E),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                size: 10,
                                color: Color(0xFF354B0E),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                badge.length > 28 ? badge.substring(0, 28) + '...' : badge,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF354B0E),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),

                  // Support Advice Display
                  const Text(
                    'Tacit-Derived Intervention Strategy',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF354B0E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF5F0),
                      border: Border.all(color: const Color(0xFFF0E8DF)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      student['intervention'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF333333),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons in Details Panel
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onMarkContacted,
                          icon: Icon(isContacted ? Icons.check : Icons.assignment_turned_in),
                          label: Text(isContacted ? 'Logged Successfully' : 'Initiate Intervention'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isContacted ? const Color(0xFF354B0E).withOpacity(0.8) : const Color(0xFF354B0E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Intervention report copied to clipboard.'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Color(0xFF354B0E),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFBFB8AD)),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.copy, color: Color(0xFF666666), size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Severity labels
  String _getDepressionSeverity(int score) {
    if (score <= 9) return 'Normal';
    if (score <= 13) return 'Mild';
    if (score <= 20) return 'Moderate';
    if (score <= 27) return 'Severe';
    return 'Extremely Severe';
  }

  String _getAnxietySeverity(int score) {
    if (score <= 7) return 'Normal';
    if (score <= 9) return 'Mild';
    if (score <= 14) return 'Moderate';
    if (score <= 19) return 'Severe';
    return 'Extremely Severe';
  }

  String _getStressSeverity(int score) {
    if (score <= 14) return 'Normal';
    if (score <= 18) return 'Mild';
    if (score <= 25) return 'Moderate';
    if (score <= 33) return 'Severe';
    return 'Extremely Severe';
  }
}

// Progress Score Meter Widget
class _ScoreMeter extends StatelessWidget {
  final String label;
  final int score;
  final String severity;
  final Color color;

  const _ScoreMeter({
    Key? key,
    required this.label,
    required this.score,
    required this.severity,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double fraction = score / 42.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              '$score / 42',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFDDD5CE),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fraction.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          severity,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Empty state details review panel placeholder
class _EmptyDetailPlaceholder extends StatelessWidget {
  const _EmptyDetailPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1EB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFB8AD)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE2EBE2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_ind_outlined,
                size: 40,
                color: Color(0xFF354B0E),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Student Selected',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a flagged profile from the urgent alert queue on the left to display its full diagnostic breakdown, rules evaluated, and intervention strategy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
