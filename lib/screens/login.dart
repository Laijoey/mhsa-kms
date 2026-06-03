import 'package:flutter/material.dart';
import 'student_login.dart';
import 'staff_login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 48,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1680),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left Column
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
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
                                    const SizedBox(width: 8),
                                    const Text(
                                      'MHSA-KMS',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF354B0E),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 42),

                                // Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFDDD5CE),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '🧠 DASS-21 · Expert System · Knowledge Base',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7A7A7A),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 26),

                                // Main Title
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'A calm place to ',
                                        style: TextStyle(
                                          fontSize: 56,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A1A),
                                          height: 1.2,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'check in',
                                        style: TextStyle(
                                          fontSize: 56,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF354B0E),
                                          height: 1.2,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '\nwith your mind.',
                                        style: TextStyle(
                                          fontSize: 56,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A1A),
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Description
                                const Text(
                                  'MHSA-KMS combines the DASS-21 self-assessment, a rule-based expert system, and a curated counsellor knowledge base — built for university wellness teams.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF666666),
                                    height: 1.6,
                                  ),
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 28),

                                // Action Buttons
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const StudentLoginPage(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.arrow_forward),
                                      label:
                                          const Text('Start self-assessment'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF354B0E),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(32),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const StaffLoginPage(role: 'counsellor'),
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Color(0xFFDDD5CE),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(32),
                                        ),
                                      ),
                                      child: const Text(
                                        'Counsellor view',
                                        style: TextStyle(
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 42),

                                // Feature keywords
                                const Text(
                                  'Built for everyday campus support',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF354B0E),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    _FeatureChip(
                                      icon: Icons.fact_check,
                                      label: 'DASS-21 screening',
                                    ),
                                    _FeatureChip(
                                      icon: Icons.psychology_alt,
                                      label: 'Expert rules',
                                    ),
                                    _FeatureChip(
                                      icon: Icons.trending_up,
                                      label: 'Progress tracking',
                                    ),
                                    _FeatureChip(
                                      icon: Icons.warning_amber,
                                      label: 'Risk insights',
                                    ),
                                    _FeatureChip(
                                      icon: Icons.menu_book,
                                      label: 'Knowledge base',
                                    ),
                                    _FeatureChip(
                                      icon: Icons.groups,
                                      label: 'Counsellor review',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 80),

                          // Right Column - Role Selection
                          Flexible(
                            flex: 1,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'CHOOSE A ROLE',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF999999),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 500),
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: const Color(0xFFD0D0D0),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        _RoleCard(
                                          icon: Icons.school,
                                          title: 'Student',
                                          description:
                                              'Take the DASS-21, view your result and track progress over time.',
                                          isSelected: selectedRole == 'student',
                                          backgroundColor:
                                              const Color(0xFFF0F8F5),
                                          onTap: () {
                                            setState(() {
                                              selectedRole = 'student';
                                            });
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const StudentLoginPage(),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        _RoleCard(
                                          icon: Icons.health_and_safety,
                                          title: 'Counsellor',
                                          description:
                                              'Monitor risk levels, review flagged students and access the knowledge base.',
                                          isSelected:
                                              selectedRole == 'counsellor',
                                          backgroundColor:
                                              const Color(0xFFF5F8F0),
                                          onTap: () {
                                            setState(() {
                                              selectedRole = 'counsellor';
                                            });
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const StaffLoginPage(role: 'counsellor'),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        _RoleCard(
                                          icon: Icons.admin_panel_settings,
                                          title: 'Admin',
                                          description:
                                              'Manage assessment questions, expert rules, and knowledge resources.',
                                          isSelected: selectedRole == 'admin',
                                          backgroundColor:
                                              const Color(0xFFF8F5F0),
                                          onTap: () {
                                            setState(() {
                                              selectedRole = 'admin';
                                            });
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const StaffLoginPage(role: 'admin'),
                                              ),
                                            );
                                          },
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
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x9EFFFFFF),
        border: Border.all(
          color: const Color(0xFFE1D8CF),
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF354B0E),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5F625F),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color:
                isSelected ? const Color(0xFF354B0E) : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF354B0E),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward,
              color: const Color(0xFF354B0E),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
