import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Active Tab Index: 0 = Questions, 1 = Rules, 2 = Knowledge Base
  int _activeTabIndex = 0;

  // Search & Filter States
  String _questionSearch = '';
  String _questionFilter = 'All'; // 'All', 'Depression', 'Anxiety', 'Stress'
  
  String _rulesSearch = '';
  String _rulesFilter = 'All'; // 'All', 'Core', 'Contextual', 'Escalation'

  String _kbSearch = '';
  String _kbFilter = 'All'; // 'All', 'Explicit', 'Tacit'

  // --- MOCK DATA IN LOCAL STATE ---
  late List<Map<String, dynamic>> _questions;
  late List<Map<String, dynamic>> _rules;
  late List<Map<String, dynamic>> _knowledgeResources;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.getRules(),
        ApiService.getResources(),
      ]);

      if (mounted) {
        setState(() {
          _initializeData();
          _rules = (results[0] as List<dynamic>).cast<Map<String, dynamic>>();
          _knowledgeResources = (results[1] as List<dynamic>).cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initializeData();
          _isLoading = false;
        });
      }
    }
  }

  void _initializeData() {
    // DASS-21 Validation Questions
    _questions = [
      {
        'id': 'Q1',
        'text': 'I found it hard to wind down',
        'category': 'Stress',
        'weight': 1.0,
        'status': 'Active',
        'mappedRules': ['Rule R-C02', 'Rule R-C01'],
      },
      {
        'id': 'Q2',
        'text': 'I was aware of dryness of my mouth',
        'category': 'Anxiety',
        'weight': 1.0,
        'status': 'Active',
        'mappedRules': ['Rule R-001', 'Rule R-C01'],
      },
      {
        'id': 'Q3',
        'text': 'I couldn\'t seem to experience any positive feeling at all',
        'category': 'Depression',
        'weight': 1.2,
        'status': 'Active',
        'mappedRules': ['Rule R-001', 'Rule R-C01'],
      },
      {
        'id': 'Q4',
        'text': 'I experienced breathing difficulty (e.g. excessively rapid breathing)',
        'category': 'Anxiety',
        'weight': 1.1,
        'status': 'Active',
        'mappedRules': ['Rule R-001'],
      },
      {
        'id': 'Q5',
        'text': 'I found it difficult to work up the initiative to do things',
        'category': 'Depression',
        'weight': 1.0,
        'status': 'Active',
        'mappedRules': ['Rule R-C01'],
      },
      {
        'id': 'Q6',
        'text': 'I was inclined to over-react to situations',
        'category': 'Stress',
        'weight': 0.9,
        'status': 'Active',
        'mappedRules': ['Rule R-C02'],
      },
      {
        'id': 'Q19',
        'text': 'I was aware of the action of my heart in the absence of physical exertion (e.g. sense of heart rate increase)',
        'category': 'Anxiety',
        'weight': 1.3,
        'status': 'Active',
        'mappedRules': ['Rule R-001', 'Rule R-C01'],
      },
      {
        'id': 'Q21',
        'text': 'I felt that life was meaningless',
        'category': 'Depression',
        'weight': 1.5,
        'status': 'Active',
        'mappedRules': ['Rule R-001', 'Rule R-C01'],
      },
    ];

    // Initialize rules and KB with empty lists (will be loaded from API in _loadData)
    _rules = [];
    _knowledgeResources = [];
  }

  // --- ACTIONS & DIALOGS ---

  void _handleAccountAction(String? value) {
    if (value == 'logout') {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  void _editQuestionWeight(Map<String, dynamic> question) {
    double currentWeight = question['weight'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF5F1EB),
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFBFB8AD)),
              ),
              title: Row(
                children: const [
                  Icon(Icons.tune, color: Color(0xFF354B0E)),
                  SizedBox(width: 10),
                  Text(
                    'Edit Parameters',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${question['id']}: ${question['text']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dimension Category:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A1A1A)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getDimensionBg(question['category']),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          question['category'],
                          style: TextStyle(
                            color: _getDimensionFg(question['category']),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Score Multiplier: ${currentWeight.toStringAsFixed(2)}x',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF354B0E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: currentWeight,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    activeColor: const Color(0xFF354B0E),
                    inactiveColor: const Color(0xFFDDD5CE),
                    label: '${currentWeight.toStringAsFixed(2)}x',
                    onChanged: (double value) {
                      setDialogState(() {
                        currentWeight = value;
                      });
                    },
                  ),
                  const Text(
                    'Adjusting this multiplier updates the psychometric assessment rule triggers inside the screening pipeline.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF999999)),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF666666)),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      question['weight'] = currentWeight;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Updated multiplier parameter for ${question['id']} to ${currentWeight.toStringAsFixed(2)}x.'),
                        backgroundColor: const Color(0xFF354B0E),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF354B0E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save Parameters'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _previewRuleMapping(Map<String, dynamic> question) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5F1EB),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFBFB8AD)),
          ),
          title: Row(
            children: const [
              Icon(Icons.rule_folder, color: Color(0xFF354B0E)),
              SizedBox(width: 10),
              Text(
                'Rule Mapping Preview',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${question['id']}:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 4),
              Text(
                question['text'],
                style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Active Rule Trigger Relationships:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 8),
              ...((question['mappedRules'] as List<String>).map((ruleId) {
                final rule = _rules.firstWhere((r) => r['id'] == ruleId.replaceAll('Rule ', ''), orElse: () => {});
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ruleId,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF354B0E)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: rule['isActive'] == true ? const Color(0xFFE2EBE2) : const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              rule['isActive'] == true ? 'ACTIVE' : 'INACTIVE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: rule['isActive'] == true ? const Color(0xFF354B0E) : const Color(0xFFD32F2F),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rule['title'] ?? 'Rule configuration',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rule['formula'] ?? '',
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Color(0xFF666666)),
                      ),
                    ],
                  ),
                );
              }).toList()),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Dismiss'),
            ),
          ],
        );
      },
    );
  }

  void _addNewQuestionDialog() {
    final TextEditingController idController = TextEditingController();
    final TextEditingController textController = TextEditingController();
    String category = 'Depression';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF5F1EB),
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFBFB8AD)),
              ),
              title: Row(
                children: const [
                  Icon(Icons.add_circle, color: Color(0xFF354B0E)),
                  SizedBox(width: 10),
                  Text(
                    'Add DASS-21 Question',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: idController,
                    decoration: const InputDecoration(
                      labelText: 'Question ID (e.g. Q22)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Validation Question Text',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'Clinical Subscale Dimension',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Depression', child: Text('Depression')),
                      DropdownMenuItem(value: 'Anxiety', child: Text('Anxiety')),
                      DropdownMenuItem(value: 'Stress', child: Text('Stress')),
                    ],
                    onChanged: (val) {
                      setDialogState(() {
                        category = val!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF666666)),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (idController.text.isEmpty || textController.text.isEmpty) return;
                    setState(() {
                      _questions.add({
                        'id': idController.text,
                        'text': textController.text,
                        'category': category,
                        'weight': 1.0,
                        'status': 'Active',
                        'mappedRules': ['Rule R-C01'],
                      });
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added question ${idController.text} to assessment validation list.'),
                        backgroundColor: const Color(0xFF354B0E),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF354B0E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Add Question'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addNewResourceDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController authorController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    String type = 'Explicit'; 
    String category = 'Clinical Guidelines';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF5F1EB),
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFBFB8AD)),
              ),
              title: Row(
                children: const [
                  Icon(Icons.library_add, color: Color(0xFF354B0E)),
                  SizedBox(width: 10),
                  Text(
                    'Upload Resource',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Resource Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: authorController,
                      decoration: const InputDecoration(
                        labelText: 'Author / Origin',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Brief Description & Scope',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: type,
                      decoration: const InputDecoration(
                        labelText: 'Knowledge Repository Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Explicit', child: Text('Explicit Guidelines (Clinical Standards)')),
                        DropdownMenuItem(value: 'Tacit', child: Text('Tacit Knowledge (Counselor Experiential)')),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          type = val!;
                          if (type == 'Explicit') {
                            category = 'Clinical Guidelines';
                          } else {
                            category = 'Counselor Experiential Interventions';
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: 'Resource Label',
                        border: OutlineInputBorder(),
                      ),
                      items: type == 'Explicit'
                          ? const [
                              DropdownMenuItem(value: 'Clinical Guidelines', child: Text('Clinical Guidelines')),
                              DropdownMenuItem(value: 'DSM-5-TR / Clinical Metrics', child: Text('DSM-5-TR / Clinical Metrics')),
                              DropdownMenuItem(value: 'Standard SOP', child: Text('Standard SOP')),
                            ]
                          : const [
                              DropdownMenuItem(value: 'Counselor Experiential Interventions', child: Text('Counselor Experiential Interventions')),
                              DropdownMenuItem(value: 'Cultural Somatization Filters', child: Text('Cultural Somatization Filters')),
                              DropdownMenuItem(value: 'Experiential Toolkit', child: Text('Experiential Toolkit')),
                            ],
                      onChanged: (val) {
                        setDialogState(() {
                          category = val!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF666666)),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty || authorController.text.isEmpty) return;
                    setState(() {
                      _knowledgeResources.add({
                        'id': 'KB-${_knowledgeResources.length + 101}',
                        'type': type,
                        'title': titleController.text,
                        'category': category,
                        'author': authorController.text,
                        'date': '2026-06-07',
                        'format': type == 'Explicit' ? 'Clinical PDF' : 'Intervention Guide',
                        'description': descController.text,
                      });
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Successfully uploaded resource to $type repository.'),
                        backgroundColor: const Color(0xFF354B0E),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF354B0E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Upload Assets'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _testRuleConfiguration(Map<String, dynamic> rule) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5F1EB),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFBFB8AD)),
          ),
          title: Row(
            children: const [
              Icon(Icons.playlist_play, color: Color(0xFF354B0E)),
              SizedBox(width: 10),
              Text(
                'Test Expert Rule Output',
                style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Evaluating formula parameters: "${rule['formula']}"',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF354B0E)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Calculated Evaluation Result:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFDDD5CE)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rule['isActive'] == true
                      ? 'Rule evaluated successfully.\nTriggers downstream system actions:\n' + (rule['actions'] as List).map((a) => '• $a').join('\n')
                      : 'Rule evaluations blocked. Rule status is currently INACTIVE. Live assessment flows remain unaffected.',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: rule['isActive'] == true ? const Color(0xFF1A1A1A) : const Color(0xFFD32F2F),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveRuleConfiguration(Map<String, dynamic> rule) async {
    try {
      await ApiService.updateRule(rule['id'] as String, {
        'isActive': rule['isActive'],
        'parameters': rule['parameters'],
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rule ${rule['id']} configuration saved successfully.'),
          backgroundColor: const Color(0xFF354B0E),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save rule: ${e.message}'),
          backgroundColor: const Color(0xFFD32F2F),
        ),
      );
    }
  }

  // --- STYLING HELPERS ---

  Color _getDimensionBg(String category) {
    switch (category) {
      case 'Depression':
        return const Color(0xFFFFEBEE); // soft red
      case 'Anxiety':
        return const Color(0xFFFFF3E0); // soft orange
      case 'Stress':
        return const Color(0xFFE2EBE2); // soft green
      default:
        return const Color(0xFFF5F1EB);
    }
  }

  Color _getDimensionFg(String category) {
    switch (category) {
      case 'Depression':
        return const Color(0xFFD32F2F);
      case 'Anxiety':
        return const Color(0xFFEF6C00);
      case 'Stress':
        return const Color(0xFF354B0E);
      default:
        return const Color(0xFF666666);
    }
  }

  // --- WIDGET BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE7), // Original warm layout background
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSubHeader(),
                    const SizedBox(height: 40),
                    _buildNavTabs(),
                    const SizedBox(height: 24),
                    _buildActiveTabContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header Builder matches system's layout theme
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF354B0E), // Forest green
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
          // Nav buttons
          Row(
            children: [
              _NavButton(
                label: 'Questions',
                isActive: _activeTabIndex == 0,
                onTap: () {
                  setState(() {
                    _activeTabIndex = 0;
                  });
                },
              ),
              const SizedBox(width: 40),
              _NavButton(
                label: 'Rules',
                isActive: _activeTabIndex == 1,
                onTap: () {
                  setState(() {
                    _activeTabIndex = 1;
                  });
                },
              ),
              const SizedBox(width: 40),
              _NavButton(
                label: 'Knowledge Base',
                isActive: _activeTabIndex == 2,
                onTap: () {
                  setState(() {
                    _activeTabIndex = 2;
                  });
                },
              ),
              const SizedBox(width: 100),
              // Account Actions dropdown
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
                  value: 'Admin',
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: 'Admin',
                      child: Text(
                        'Admin',
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
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  onChanged: _handleAccountAction,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Welcome sub-header containing original styling
  Widget _buildSubHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ADMINISTRATOR',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF999999),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Manage System Configuration',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Update assessment questions, configure expert recommendation rules, and maintain explicit/tacit repositories for optimal mental health knowledge management.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        // Counters
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Validation Questions',
                value: '${_questions.length}',
                icon: Icons.help_outline,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _StatCard(
                label: 'Expert Recommendation Rules',
                value: '${_rules.length}',
                icon: Icons.psychology_alt,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _StatCard(
                label: 'Knowledge Repository Assets',
                value: '${_knowledgeResources.length}',
                icon: Icons.library_books,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavTabs() {
    // Top headers labels depending on active state
    String titleText = '';
    switch (_activeTabIndex) {
      case 0:
        titleText = 'DASS-21 Assessment Validation Questions';
        break;
      case 1:
        titleText = 'Manage Recommendation Rules (Expert System Configurator)';
        break;
      case 2:
        titleText = 'Manage Knowledge Resources (Explicit & Tacit Repositories)';
        break;
    }

    return Text(
      titleText,
      style: const TextStyle(
        fontFamily: 'serif',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  // Render tab content
  Widget _buildActiveTabContent() {
    switch (_activeTabIndex) {
      case 0:
        return _buildQuestionsTab();
      case 1:
        return _buildRulesTab();
      case 2:
        return _buildKnowledgeTab();
      default:
        return _buildQuestionsTab();
    }
  }

  // --- TAB 1: QUESTIONS ---

  Widget _buildQuestionsTab() {
    final filteredQuestions = _questions.where((q) {
      final matchesSearch = q['text'].toLowerCase().contains(_questionSearch.toLowerCase()) ||
          q['id'].toLowerCase().contains(_questionSearch.toLowerCase());
      final matchesCategory = _questionFilter == 'All' || q['category'] == _questionFilter;
      return matchesSearch && matchesCategory;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Controls Row wrapped in a responsive Wrap
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              width: 350,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDDD5CE)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _questionSearch = val;
                  });
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF999999)),
                  hintText: 'Search validation questions by text or ID...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 13),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDDD5CE)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _questionFilter,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Subscales')),
                  DropdownMenuItem(value: 'Depression', child: Text('Depression')),
                  DropdownMenuItem(value: 'Anxiety', child: Text('Anxiety')),
                  DropdownMenuItem(value: 'Stress', child: Text('Stress')),
                ],
                onChanged: (val) {
                  setState(() {
                    _questionFilter = val!;
                  });
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addNewQuestionDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Question'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF354B0E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Questions Structured Table Layout
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDDD5CE)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Header Row - responsive columns matching body rows
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F1EB),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                  border: Border(bottom: BorderSide(color: Color(0xFFDDD5CE), width: 1.5)),
                ),
                child: Row(
                  children: const [
                    SizedBox(width: 60, child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)))),
                    Expanded(flex: 4, child: Text('PSYCHOMETRIC QUESTION', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)))),
                    SizedBox(width: 130, child: Text('DIMENSION', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)))),
                    SizedBox(width: 100, child: Text('WEIGHTAGE', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)))),
                    Expanded(flex: 3, child: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)))),
                  ],
                ),
              ),
              // Body Rows
              filteredQuestions.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: const Text('No validation questions match current filters.', style: TextStyle(color: Color(0xFF999999))),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredQuestions.length,
                      itemBuilder: (context, idx) {
                        final question = filteredQuestions[idx];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFDDD5CE))),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // ID
                              SizedBox(
                                width: 60,
                                child: Text(
                                  question['id'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF354B0E)),
                                ),
                              ),
                              // Question Text
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: Text(
                                    question['text'],
                                    style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                                  ),
                                ),
                              ),
                              // Category tag field
                              SizedBox(
                                width: 130,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getDimensionBg(question['category']),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      question['category'],
                                      style: TextStyle(
                                        color: _getDimensionFg(question['category']),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Score Multiplier parameter
                              SizedBox(
                                width: 100,
                                child: Text(
                                  '${question['weight'].toStringAsFixed(2)}x',
                                  style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Color(0xFF354B0E)),
                                ),
                              ),
                              // Action buttons - wrapped inside Expanded & Wrap to completely resolve overflows
                              Expanded(
                                flex: 3,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => _editQuestionWeight(question),
                                      icon: const Icon(Icons.tune, size: 12),
                                      label: const Text('Edit weightage parameters', style: TextStyle(fontSize: 11)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF354B0E),
                                        side: const BorderSide(color: Color(0xFFDDD5CE)),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => _previewRuleMapping(question),
                                      icon: const Icon(Icons.hub_outlined, size: 12),
                                      label: const Text('Preview rule mapping', style: TextStyle(fontSize: 11)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF666666),
                                        side: const BorderSide(color: Color(0xFFDDD5CE)),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 2: RECOMMENDATION RULES ---

  Widget _buildRulesTab() {
    final filteredRules = _rules.where((r) {
      final matchesSearch = r['title'].toLowerCase().contains(_rulesSearch.toLowerCase()) ||
          r['id'].toLowerCase().contains(_rulesSearch.toLowerCase());
      final matchesType = _rulesFilter == 'All' || r['type'] == _rulesFilter;
      return matchesSearch && matchesType;
    }).toList();

    return Column(
      children: [
        // Controls Row in Wrap
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            Container(
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDDD5CE)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _rulesSearch = val;
                  });
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF999999)),
                  hintText: 'Search expert rules formulas or titles...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 13),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDDD5CE)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _rulesFilter,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Rule Types')),
                  DropdownMenuItem(value: 'Escalation', child: Text('Escalation Rules')),
                  DropdownMenuItem(value: 'Contextual', child: Text('Contextual Rules')),
                  DropdownMenuItem(value: 'Core', child: Text('Core Logic')),
                ],
                onChanged: (val) {
                  setState(() {
                    _rulesFilter = val!;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Visual Rules Cards List
        filteredRules.isEmpty
            ? Container(
                padding: const EdgeInsets.all(40),
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Center(
                  child: Text('No expert rules found matching selection.', style: TextStyle(color: Color(0xFF999999))),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredRules.length,
                itemBuilder: (context, idx) {
                  final rule = filteredRules[idx];
                  return _buildRuleConfigCard(rule);
                },
              ),
      ],
    );
  }

  Widget _buildRuleConfigCard(Map<String, dynamic> rule) {
    final bool isActive = rule['isActive'] == true;
    final List<dynamic> params = rule['parameters'];
    final List<String> ruleActions = List<String>.from(rule['actions']);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF354B0E) : const Color(0xFFDDD5CE),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Title bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFF5F8F0) : const Color(0xFFF5F1EB),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              border: const Border(bottom: BorderSide(color: Color(0xFFDDD5CE))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF354B0E),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '[Card ${rule['id']}]',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule['title'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                      ),
                      Text(
                        rule['description'],
                        style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                      ),
                    ],
                  ),
                ),
                // Toggle status switch
                Row(
                  children: [
                    Text(
                      isActive ? 'ACTIVE' : 'INACTIVE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isActive ? const Color(0xFF354B0E) : const Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: isActive,
                      activeColor: const Color(0xFF354B0E),
                      onChanged: (bool val) {
                        setState(() {
                          rule['isActive'] = val;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Card Formula Condition & Action Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Conditional UI Logic Display - wrap inside LayoutBuilder for responsiveness
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 650;
                    final childrenList = [
                      Expanded(
                        flex: isMobile ? 0 : 1,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F1EB),
                            border: Border.all(color: const Color(0xFFDDD5CE)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'IF CONDITION LOGIC',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF666666)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                rule['formula'],
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 12 : 0),
                      // THEN actions panel
                      Expanded(
                        flex: isMobile ? 0 : 1,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2EBE2),
                            border: Border.all(color: const Color(0xFFBFD8BF)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'THEN ACTION DISPATCH',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF354B0E)),
                              ),
                              const SizedBox(height: 8),
                              ...ruleActions.map((act) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.arrow_forward_sharp, size: 13, color: Color(0xFF354B0E)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            act,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF354B0E)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ];

                    if (isMobile) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: childrenList.map((w) => w is Expanded ? w.child : w).toList(),
                      );
                    } else {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: childrenList,
                      );
                    }
                  },
                ),
                
                // Sliders/Dropdown ranges for thresholds tuning
                if (params.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'FINE-TUNE THRESHOLD COEFFICIENTS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF666666), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),
                  ...params.map((param) {
                    final double paramVal = param['value'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F1EB),
                        border: Border.all(color: const Color(0xFFDDD5CE)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  param['label'],
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                                ),
                                Text(
                                  'Variable: ${param['key']}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF999999), fontFamily: 'monospace'),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Slider(
                              value: paramVal,
                              min: param['min'],
                              max: param['max'],
                              divisions: (param['max'] - param['min']).round(),
                              activeColor: const Color(0xFF354B0E),
                              inactiveColor: const Color(0xFFDDD5CE),
                              label: '${paramVal.round()}',
                              onChanged: (double val) {
                                setState(() {
                                  param['value'] = val;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 60,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFDDD5CE)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${paramVal.round()}',
                              style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Color(0xFF354B0E)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                const SizedBox(height: 16),
                
                // Actions Footer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _testRuleConfiguration(rule),
                      icon: const Icon(Icons.play_arrow_sharp, size: 14),
                      label: const Text('Test rule triggers locally'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A1A1A),
                        side: const BorderSide(color: Color(0xFFDDD5CE)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _saveRuleConfiguration(rule),
                      icon: const Icon(Icons.check, size: 14),
                      label: const Text('Save configuration'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF354B0E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
  }

  // --- TAB 3: KNOWLEDGE RESOURCES ---

  Widget _buildKnowledgeTab() {
    final filteredResources = _knowledgeResources.where((res) {
      final matchesSearch = res['title'].toLowerCase().contains(_kbSearch.toLowerCase()) ||
          res['description'].toLowerCase().contains(_kbSearch.toLowerCase()) ||
          res['author'].toLowerCase().contains(_kbSearch.toLowerCase());
      final matchesRepo = _kbFilter == 'All' || res['type'] == _kbFilter;
      return matchesSearch && matchesRepo;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filter actions panel in responsive Wrap
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              width: 350,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDDD5CE)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _kbSearch = val;
                  });
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF999999)),
                  hintText: 'Search clinical keywords, indices, playbooks...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 13),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDDD5CE)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _kbFilter,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Repository Types')),
                  DropdownMenuItem(value: 'Explicit', child: Text('Explicit Guidelines Only')),
                  DropdownMenuItem(value: 'Tacit', child: Text('Tacit Interventions Only')),
                ],
                onChanged: (val) {
                  setState(() {
                    _kbFilter = val!;
                  });
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addNewResourceDialog,
              icon: const Icon(Icons.upload_file, size: 16),
              label: const Text('Upload Resource'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF354B0E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        
        // Media asset grid layout with dynamic columns depending on constraints width
        filteredResources.isEmpty
            ? Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Center(
                  child: Text('No knowledge resources match current filters.', style: TextStyle(color: Color(0xFF999999))),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 3;
                  if (constraints.maxWidth < 750) {
                    crossAxisCount = 1;
                  } else if (constraints.maxWidth < 1150) {
                    crossAxisCount = 2;
                  }
                  
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      mainAxisExtent: 310,
                    ),
                    itemCount: filteredResources.length,
                    itemBuilder: (context, idx) {
                      final res = filteredResources[idx];
                      final bool isExplicit = res['type'] == 'Explicit';
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFDDD5CE)),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Explicit Guidelines vs Tacit Knowledge Badge Label
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isExplicit ? const Color(0xFFE2EBE2) : const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isExplicit ? const Color(0xFF354B0E).withValues(alpha: 0.3) : const Color(0xFFEF6C00).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isExplicit ? Icons.gavel : Icons.psychology_alt,
                                        size: 11,
                                        color: isExplicit ? const Color(0xFF354B0E) : const Color(0xFFEF6C00),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isExplicit
                                            ? 'Explicit Guidelines'
                                            : 'Tacit Strategies',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: isExplicit ? const Color(0xFF354B0E) : const Color(0xFFEF6C00),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  res['id'],
                                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFF999999)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Title
                            Text(
                              res['title'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Subtitle Category Indicator label
                            Text(
                              res['category'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF354B0E),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Description
                            Expanded(
                              child: Text(
                                res['description'],
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            const SizedBox(height: 10),
                            // Footer Meta Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Origin: ${res['author']}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF666666)),
                                      ),
                                      Text(
                                        'Published: ${res['date']}',
                                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF999999)),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _knowledgeResources.removeWhere((item) => item['id'] == res['id']);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Removed ${res['title']} successfully.'),
                                        backgroundColor: const Color(0xFFD32F2F),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFD32F2F)),
                                  tooltip: 'Delete asset',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ],
    );
  }
}

// Nav Tab button used in header
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
                color: const Color(0xFF354B0E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

// KPI Statistics Card
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDD5CE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF354B0E),
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
