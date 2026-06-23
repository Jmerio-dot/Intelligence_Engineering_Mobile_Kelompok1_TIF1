class Issue {
  final int id;
  final String key;
  String title;
  String description;
  final String type;
  String priority;
  String status;
  int? assigneeId;
  String? assigneeName;
  int? sprintId;
  int? storyPoints;
  List<String> labels;
  DateTime? dueDate;
  final String? reporter;
  final DateTime createdAt;
  DateTime updatedAt;
  final int projectId;
  List<Comment> comments;
  List<Attachment> attachments;
  // Intelligence fields
  Map<String, dynamic>? meaningfulObjectives;
  Map<String, dynamic>? intelligenceExperiences;
  Map<String, dynamic>? intelligenceImplementation;
  double? creationProgress;

  Issue({
    required this.id,
    required this.key,
    required this.title,
    this.description = '',
    this.type = 'task',
    this.priority = 'medium',
    this.status = 'todo',
    this.assigneeId,
    this.assigneeName,
    this.sprintId,
    this.storyPoints,
    List<String>? labels,
    this.dueDate,
    this.reporter,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.projectId,
    List<Comment>? comments,
    List<Attachment>? attachments,
    this.meaningfulObjectives,
    this.intelligenceExperiences,
    this.intelligenceImplementation,
    this.creationProgress,
  })  : labels = labels ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        comments = comments ?? [],
        attachments = attachments ?? [];
}

class Comment {
  final int id;
  final String userName;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userName,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class Attachment {
  final int id;
  final String fileName;
  final String? fileSize;
  final String? uploader;
  final DateTime? uploadedAt;

  Attachment({
    required this.id,
    required this.fileName,
    this.fileSize,
    this.uploader,
    this.uploadedAt,
  });
}
