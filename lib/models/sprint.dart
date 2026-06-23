class Sprint {
  final int id;
  final String name;
  final String? goal;
  String status; // planning, active, done
  final DateTime? startDate;
  final DateTime? endDate;
  final int projectId;

  Sprint({
    required this.id,
    required this.name,
    this.goal,
    this.status = 'planning',
    this.startDate,
    this.endDate,
    required this.projectId,
  });
}
