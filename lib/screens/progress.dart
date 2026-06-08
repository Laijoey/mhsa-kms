import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'assessment.dart';
import 'result.dart';
import 'student_session.dart';

class ProgressPage extends StatefulWidget {
  final StudentSession? session;

  const ProgressPage({Key? key, this.session}) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  String _selectedNav = 'Progress';

  static const Color _depressionColor = Color(0xFF5E966B);
  static const Color _anxietyColor = Color(0xFF00888A);
  static const Color _stressColor = Color(0xFFE0834F);

  List<_ProgressRecord> _progressRecords = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await ApiService.getMyHistory();
      setState(() {
        _progressRecords = history.map((entry) {
          // Convert risk level to display-friendly label
          String overallLabel = _riskLevelToDisplay(entry.riskLevel);
          return _ProgressRecord(
            date: _formatDate(entry.takenAt),
            depression: entry.normalisedScores['dep'] ?? 0,
            anxiety: entry.normalisedScores['anx'] ?? 0,
            stress: entry.normalisedScores['str'] ?? 0,
            overall: overallLabel,
          );
        }).toList();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.month}/${dt.day}/${dt.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _riskLevelToDisplay(String riskLevel) {
    switch (riskLevel) {
      case 'CRITICAL':
        return 'Extremely Severe';
      case 'HIGH':
        return 'Severe';
      case 'MODERATE':
        return 'Moderate';
      case 'LOW':
        return 'Mild';
      case 'NORMAL':
        return 'Normal';
      default:
        return 'Unknown';
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
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, anim1, anim2) => ResultPage(
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
                        label: 'Progress',
                        isActive: _selectedNav == 'Progress',
                        onTap: () {
                          setState(() {
                            _selectedNav = 'Progress';
                          });
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Text(
                            'Error loading history: $_errorMessage',
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : SingleChildScrollView(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 60, vertical: 54),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1220),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                        const Text(
                          'PROGRESS',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF354B0E),
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Your check-ins over time.',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10221F),
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const SizedBox(
                          width: 620,
                          child: Text(
                            'Tracking small changes is more useful than any single result. \nAim for a regular check-in every 2-4 weeks.',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF4B5350),
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(height: 52),
                        Container(
                          height: 460,
                          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F1EB),
                            border: Border.all(
                              color: const Color(0xFFCFC7BB),
                            ),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  _LegendItem(
                                    color: _depressionColor,
                                    label: 'Depression',
                                  ),
                                  SizedBox(width: 24),
                                  _LegendItem(
                                    color: _anxietyColor,
                                    label: 'Anxiety',
                                  ),
                                  SizedBox(width: 24),
                                  _LegendItem(
                                    color: _stressColor,
                                    label: 'Stress',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              Expanded(
                                child: CustomPaint(
                                  painter: _ProgressChartPainter(
                                    depressionScores: _progressRecords.reversed
                                        .map((record) =>
                                            record.depression.toDouble())
                                        .toList(),
                                    anxietyScores: _progressRecords.reversed
                                        .map((record) =>
                                            record.anxiety.toDouble())
                                        .toList(),
                                    stressScores: _progressRecords.reversed
                                        .map((record) =>
                                            record.stress.toDouble())
                                        .toList(),
                                    depressionColor: _depressionColor,
                                    anxietyColor: _anxietyColor,
                                    stressColor: _stressColor,
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        _ProgressTable(records: _progressRecords),
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

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            color: Color(0xFF4B5350),
          ),
        ),
      ],
    );
  }
}

class _ProgressTable extends StatelessWidget {
  final List<_ProgressRecord> records;

  const _ProgressTable({
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F1EB),
          border: Border.all(color: const Color(0xFFCFC7BB)),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.05),
            1: FlexColumnWidth(1.2),
            2: FlexColumnWidth(0.95),
            3: FlexColumnWidth(0.9),
            4: FlexColumnWidth(1.4),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(
                color: Color(0xFFE9EDE3),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFCFC7BB)),
                ),
              ),
              children: [
                _ProgressTableHeader('DATE'),
                _ProgressTableHeader('DEPRESSION'),
                _ProgressTableHeader('ANXIETY'),
                _ProgressTableHeader('STRESS'),
                _ProgressTableHeader('OVERALL'),
              ],
            ),
            for (var index = 0; index < records.length; index++)
              TableRow(
                decoration: BoxDecoration(
                  border: index == records.length - 1
                      ? null
                      : const Border(
                          bottom: BorderSide(color: Color(0xFFCFC7BB)),
                        ),
                ),
                children: [
                  _ProgressTableCell(records[index].date),
                  _ProgressTableCell('${records[index].depression}'),
                  _ProgressTableCell('${records[index].anxiety}'),
                  _ProgressTableCell('${records[index].stress}'),
                  _ProgressOverallCell(records[index].overall),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressTableHeader extends StatelessWidget {
  final String label;

  const _ProgressTableHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: Color(0xFF43504B),
        ),
      ),
    );
  }
}

class _ProgressTableCell extends StatelessWidget {
  final String value;

  const _ProgressTableCell(this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          color: Color(0xFF10221F),
        ),
      ),
    );
  }
}

class _ProgressOverallCell extends StatelessWidget {
  final String value;

  const _ProgressOverallCell(this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE5DF),
            border: Border.all(color: const Color(0xFFFFA79C)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFE2251D),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRecord {
  final String date;
  final int depression;
  final int anxiety;
  final int stress;
  final String overall;

  const _ProgressRecord({
    required this.date,
    required this.depression,
    required this.anxiety,
    required this.stress,
    required this.overall,
  });
}

class _ProgressChartPainter extends CustomPainter {
  final List<double>? depressionScores;
  final List<double>? anxietyScores;
  final List<double>? stressScores;
  final Color depressionColor;
  final Color anxietyColor;
  final Color stressColor;

  const _ProgressChartPainter({
    required this.depressionScores,
    required this.anxietyScores,
    required this.stressScores,
    required this.depressionColor,
    required this.anxietyColor,
    required this.stressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final depression = depressionScores ?? const [17, 17, 15];
    final anxiety = anxietyScores ?? const [18, 18, 14];
    final stress = stressScores ?? const [15, 10, 18];

    const left = 54.0;
    const right = 26.0;
    const top = 26.0;
    const bottom = 34.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    final gridPaint = Paint()
      ..color = const Color(0xFFD4D0C0)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 5; i++) {
      final y = top + chartHeight * i / 4;
      _drawDashedLine(
        canvas,
        Offset(left, y),
        Offset(left + chartWidth, y),
        gridPaint,
      );
    }

    _drawSeries(
      canvas,
      depression,
      depressionColor,
      left,
      top,
      chartWidth,
      chartHeight,
    );
    _drawSeries(
      canvas,
      anxiety,
      anxietyColor,
      left,
      top,
      chartWidth,
      chartHeight,
    );
    _drawSeries(
      canvas,
      stress,
      stressColor,
      left,
      top,
      chartWidth,
      chartHeight,
    );
  }

  void _drawSeries(
    Canvas canvas,
    List<double> values,
    Color color,
    double left,
    double top,
    double chartWidth,
    double chartHeight,
  ) {
    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          left + chartWidth * i / (values.length - 1),
          top + chartHeight * (1 - values[i] / 42),
        ),
    ];

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, linePaint);

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (final point in points) {
      canvas.drawCircle(point, 6, pointPaint);
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    const dashWidth = 4.0;
    const dashSpace = 7.0;
    var currentX = start.dx;

    while (currentX < end.dx) {
      canvas.drawLine(
        Offset(currentX, start.dy),
        Offset((currentX + dashWidth).clamp(start.dx, end.dx), end.dy),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressChartPainter oldDelegate) {
    return oldDelegate.depressionScores != depressionScores ||
        oldDelegate.anxietyScores != anxietyScores ||
        oldDelegate.stressScores != stressScores;
  }
}
