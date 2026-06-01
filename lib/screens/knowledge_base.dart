import 'package:flutter/material.dart';

class KnowledgeBasePage extends StatefulWidget {
  final String userRole; // 'counsellor' or 'admin'
  const KnowledgeBasePage({Key? key, required this.userRole}) : super(key: key);

  @override
  State<KnowledgeBasePage> createState() => _KnowledgeBasePageState();
}

class _KnowledgeBasePageState extends State<KnowledgeBasePage> {
  String _selectedNav = 'Knowledge';
  String _searchQuery = '';

  // Knowledge base resources
  final List<Map<String, dynamic>> resources = [
    {
      'title': 'Depression: Recognition & Management',
      'category': 'Clinical Guide',
      'date': '2026-05-01',
      'readTime': '12 min',
      'description': 'Comprehensive guide on identifying depression symptoms and evidence-based interventions for counsellors.',
    },
    {
      'title': 'Anxiety Disorders in University Students',
      'category': 'Research',
      'date': '2026-04-28',
      'readTime': '18 min',
      'description': 'Research findings on anxiety prevalence among students and effective coping strategies.',
    },
    {
      'title': 'Crisis Intervention Protocols',
      'category': 'Procedure',
      'date': '2026-04-15',
      'readTime': '8 min',
      'description': 'Step-by-step protocols for handling mental health crises on campus.',
    },
    {
      'title': 'Stress Management Techniques',
      'category': 'Resource',
      'date': '2026-04-10',
      'readTime': '10 min',
      'description': 'Evidence-based stress management techniques to recommend to students.',
    },
  ];

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Clinical Guide':
        return const Color(0xFF354B0E);
      case 'Research':
        return const Color(0xFFF57C00);
      case 'Procedure':
        return const Color(0xFFD32F2F);
      case 'Resource':
        return const Color(0xFF1976D2);
      default:
        return const Color(0xFF999999);
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
                        label: widget.userRole == 'counsellor' ? 'Dashboard' : 'Dashboard',
                        isActive: _selectedNav == 'Dashboard',
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 40),
                      if (widget.userRole == 'counsellor')
                        _NavButton(
                          label: 'High Risk',
                          isActive: _selectedNav == 'HighRisk',
                          onTap: () {},
                        )
                      else
                        _NavButton(
                          label: 'Questions',
                          isActive: _selectedNav == 'Questions',
                          onTap: () {},
                        ),
                      const SizedBox(width: 40),
                      _NavButton(
                        label: 'Knowledge Base',
                        isActive: _selectedNav == 'Knowledge',
                        onTap: () {},
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
                          value: widget.userRole == 'counsellor'
                              ? 'Counsellor'
                              : 'Admin',
                          underline: const SizedBox(),
                          items: [
                            DropdownMenuItem(
                              value: widget.userRole == 'counsellor'
                                  ? 'Counsellor'
                                  : 'Admin',
                              child: Text(
                                widget.userRole == 'counsellor'
                                    ? 'Counsellor'
                                    : 'Admin',
                                style: const TextStyle(
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
                    // Title Section
                    const Text(
                      'KNOWLEDGE BASE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF999999),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Expert Resources & Guidelines',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Access curated clinical guidelines, research, and resources for mental health support.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Search Box
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Color(0xFF999999),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search resources...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Resources List
                    ...resources.map((resource) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    resource['title'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _getCategoryColor(resource['category'])
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    resource['category'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          _getCategoryColor(resource['category']),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Description
                            Text(
                              resource['description'],
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Meta Info
                            Row(
                              children: [
                                Text(
                                  resource['date'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  '📖 ${resource['readTime']} read',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.open_in_new, size: 16),
                                  label: const Text('Read'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF354B0E),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ],
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
                color: const Color(0xFF354B0E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
