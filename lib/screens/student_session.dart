class StudentSession {
  final String name;
  final String matricNumber;
  final String? token;
  final String? userId;

  const StudentSession({
    required this.name,
    required this.matricNumber,
    this.token,
    this.userId,
  });
}
