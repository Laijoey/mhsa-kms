import 'package:flutter/material.dart';
import 'result.dart';
import 'progress.dart';
import 'student_session.dart';

class AssessmentPage extends StatefulWidget {
  final StudentSession? session;

  const AssessmentPage({Key? key, this.session}) : super(key: key);

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  Map<int, int> answers = {};
  int currentPage = 0;
  final int perPage = 7;
  String _selectedNav = 'Assessment';

  // DASS-21 Questions
  final List<String> questions = [
    "I found it hard to wind down",
    "I was aware of dryness of my mouth",
    "I couldn't seem to experience any positive feeling at all",
    "I experienced breathing difficulty",
    "I found it difficult to work up the initiative to do things",
    "I tended to over-react to situations",
    "I experienced trembling",
    "I felt that I was using a lot of nervous energy",
    "I was worried about situations in which I might panic",
    "I felt that I had nothing to look forward to",
    "I found myself getting agitated",
    "I found it difficult to relax",
    "I felt down-hearted and blue",
    "I was intolerant of anything that kept me from getting on with what I was doing",
    "I felt I was close to panic",
    "I was unable to become enthusiastic about anything",
    "I felt I wasn't worth much as a person",
    "I felt that I was rather touchy",
    "I was aware of the action of my heart in the absence of physical exertion",
    "I felt scared without any good reason",
    "I felt that life was meaningless",
  ];

  final List<String> responses = [
    "Did not apply to me at all",
    "Applied to me to some degree, or some of the time",
    "Applied to me to a considerable degree, or a good part of time",
    "Applied to me very much, or most of the time",
  ];

  int get total => questions.length;
  int get pages => (total / perPage).ceil();
  List<String> get currentQuestions => questions.sublist(
      currentPage * perPage, ((currentPage + 1) * perPage).clamp(0, total));

  int get answeredCount => answers.keys.length;
  int get progress => ((answeredCount / total) * 100).round();
  bool get pageComplete => currentQuestions
      .asMap()
      .entries
      .every((e) => answers[currentPage * perPage + e.key] != null);

  void _handleAccountAction(String? value) {
    if (value == 'logout') {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  void submitAssessment() {
    // Calculate scores
    int depression = 0, anxiety = 0, stress = 0;

    answers.forEach((q, answer) {
      if (q % 3 == 0)
        depression += answer;
      else if (q % 3 == 1)
        anxiety += answer;
      else
        stress += answer;
    });

    // Navigate to result page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          depression: depression,
          anxiety: anxiety,
          stress: stress,
          session: widget.session,
        ),
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
                          setState(() {
                            _selectedNav = 'Assessment';
                          });
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

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DASS-21',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF999999),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'How have you been, over the past week?',
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '$answeredCount / $total',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE0E0E0),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF354B0E)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Instructions
                        const Text(
                          'Read each statement and choose how much it applied to you over the past week. There are no right or wrong answers.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Questions
                        ...currentQuestions.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final question = entry.value;
                          final questionId = currentPage * perPage + idx;

                          return Column(
                            key: ValueKey(questionId),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F1EB),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: const Color(0xFFCFC7BB)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Question number and text
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0F0F0),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${questionId + 1}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF666666),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            question,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF1A1A1A),
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    // Response options
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final useTwoColumns =
                                            constraints.maxWidth >= 720;
                                        final optionWidth = useTwoColumns
                                            ? (constraints.maxWidth - 10) / 2
                                            : constraints.maxWidth;

                                        return Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: responses
                                              .asMap()
                                              .entries
                                              .map((optEntry) {
                                            final optIdx = optEntry.key;
                                            final optText = optEntry.value;
                                            final isSelected =
                                                answers[questionId] == optIdx;

                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  answers[questionId] = optIdx;
                                                });
                                              },
                                              child: SizedBox(
                                                width: optionWidth,
                                                child: Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                          minHeight: 76),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16,
                                                    vertical: 14,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? const Color(
                                                            0xFF354B0E)
                                                        : const Color(
                                                            0xFFF5EFE7),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? const Color(
                                                              0xFF354B0E)
                                                          : const Color(
                                                              0xFFCFC7BB),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 24,
                                                        height: 24,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                            color: isSelected
                                                                ? Colors.white
                                                                : const Color(
                                                                    0xFFCFC7BB),
                                                            width: 1.5,
                                                          ),
                                                        ),
                                                        child: isSelected
                                                            ? const Center(
                                                                child: Icon(
                                                                  Icons.check,
                                                                  size: 14,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              )
                                                            : null,
                                                      ),
                                                      const SizedBox(width: 14),
                                                      Expanded(
                                                        child: Text(
                                                          '$optIdx - $optText',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: isSelected
                                                                ? Colors.white
                                                                : const Color(
                                                                    0xFF1A1A1A),
                                                            height: 1.35,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }).toList(),

                        const SizedBox(height: 32),

                        // Navigation buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Back'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1A1A1A),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: const BorderSide(
                                      color: Color(0xFFDDD5CE)),
                                ),
                              ),
                            ),
                            if (currentPage < pages - 1)
                              ElevatedButton.icon(
                                onPressed: pageComplete
                                    ? () => setState(() => currentPage++)
                                    : null,
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('Next'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF354B0E),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: answeredCount == total
                                    ? submitAssessment
                                    : null,
                                icon: const Icon(Icons.check),
                                label: const Text('Submit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF354B0E),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                          ],
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
