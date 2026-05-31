import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _selectedNav = 'Dashboard';

  // Sample questions data
  final List<Map<String, dynamic>> questions = [
    {
      'id': 'Q1',
      'text': 'I found it hard to wind down',
      'category': 'DASS-21',
      'subscale': 'Stress',
      'status': 'Active',
    },
    {
      'id': 'Q2',
      'text': 'I was aware of dryness of my mouth',
      'category': 'DASS-21',
      'subscale': 'Anxiety',
      'status': 'Active',
    },
    {
      'id': 'Q3',
      'text': 'I couldn\'t seem to experience any positive feeling at all',
      'category': 'DASS-21',
      'subscale': 'Depression',
      'status': 'Active',
    },
  ];

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
                        label: 'Questions',
                        isActive: _selectedNav == 'Questions',
                        onTap: () {
                          setState(() {
                            _selectedNav = 'Questions';
                          });
                        },
                      ),
                      const SizedBox(width: 40),
                      _NavButton(
                        label: 'Rules',
                        isActive: _selectedNav == 'Rules',
                        onTap: () {
                          setState(() {
                            _selectedNav = 'Rules';
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
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Update assessment questions, configure expert rules, and maintain the knowledge base for optimal system performance.',
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
                            label: 'Total Questions',
                            value: '${21}',
                            icon: Icons.help_outline,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _StatCard(
                            label: 'Expert Rules',
                            value: '${12}',
                            icon: Icons.psychology_alt,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _StatCard(
                            label: 'Resources',
                            value: '${85}',
                            icon: Icons.library_books,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Questions Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'DASS-21 Assessment Questions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text('Add Question'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B9E7F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ...questions.map((question) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    question['id'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B9E7F),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    question['text'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1A1A1A),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F0F0),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          question['subscale'],
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF666666),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5E6E8),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          question['status'],
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF6B9E7F),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: const Color(0xFF6B9E7F),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: const Color(0xFFD32F2F),
                              onPressed: () {},
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
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF6B9E7F),
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
