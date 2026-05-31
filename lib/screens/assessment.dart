import 'package:flutter/material.dart';
import 'result.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({Key? key}) : super(key: key);

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  Map<int, int> answers = {};
  int currentPage = 0;
  final int perPage = 7;

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

  final List<String> responses = ["Did not apply", "Applied sometimes", "Applied often", "Applied very often"];

  int get total => questions.length;
  int get pages => (total / perPage).ceil();
  List<String> get currentQuestions =>
      questions.sublist(currentPage * perPage, 
          ((currentPage + 1) * perPage).clamp(0, total));
  
  int get answeredCount => answers.keys.length;
  int get progress => ((answeredCount / total) * 100).round();
  bool get pageComplete => currentQuestions.asMap().entries.every(
      (e) => answers[currentPage * perPage + e.key] != null);

  void submitAssessment() {
    // Calculate scores
    int depression = 0, anxiety = 0, stress = 0;
    
    answers.forEach((q, answer) {
      if (q % 3 == 0) depression += answer;
      else if (q % 3 == 1) anxiety += answer;
      else stress += answer;
    });

    // Navigate to result page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          depression: depression,
          anxiety: anxiety,
          stress: stress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'DASS-21 Assessment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
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
                    const Text(
                      'DASS-21',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF999999),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'How have you been, over the past week?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
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
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6B9E7F)),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question number and text
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(16),
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
                        Column(
                          children: responses.asMap().entries.map((optEntry) {
                            final optIdx = optEntry.key;
                            final optText = optEntry.value;
                            final isSelected = answers[questionId] == optIdx;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  answers[questionId] = optIdx;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF6B9E7F) : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF6B9E7F) : const Color(0xFFE0E0E0),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected ? Colors.white : const Color(0xFFE0E0E0),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: isSelected
                                          ? const Center(
                                              child: Icon(Icons.check, size: 14, color: Colors.white),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        optText,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
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
                  onPressed: currentPage > 0
                      ? () => setState(() => currentPage--)
                      : null,
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
                      side: const BorderSide(color: Color(0xFFDDD5CE)),
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
                      backgroundColor: const Color(0xFF6B9E7F),
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
                      backgroundColor: const Color(0xFF6B9E7F),
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
    );
  }
}
