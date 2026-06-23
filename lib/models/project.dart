class Project {
  final int id;
  final String name;
  final String key;
  final String type;
  final String description;
  final String status;
  final String? owner;
  final DateTime? startDate;
  final DateTime? endDate;
  final int openIssues;
  final int totalIssues;
  // Meaningful Objectives
  final String? orgObjective;
  final String? orgHow;
  final String? orgMeasure;
  final List<Map<String, String>>? leadingIndicators;
  final String? userOutcome;
  final String? userHow;
  final String? userMeasure;
  final String? modelProperty;
  final String? modelHow;
  final String? modelMeasure;
  // Planning
  final String? deployment;
  final String? maintenance;
  final String? operations;
  final List<String>? supervisors;

  Project({
    required this.id,
    required this.name,
    required this.key,
    this.type = 'scrum',
    this.description = '',
    this.status = 'active',
    this.owner,
    this.startDate,
    this.endDate,
    this.openIssues = 0,
    this.totalIssues = 0,
    this.orgObjective,
    this.orgHow,
    this.orgMeasure,
    this.leadingIndicators,
    this.userOutcome,
    this.userHow,
    this.userMeasure,
    this.modelProperty,
    this.modelHow,
    this.modelMeasure,
    this.deployment,
    this.maintenance,
    this.operations,
    this.supervisors,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Untitled Project',
      key: json['key'] as String? ?? '',
      type: json['type'] as String? ?? 'scrum',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      owner: json['owner_name'] as String?,
      openIssues: json['open_issues'] as int? ?? 0,
      totalIssues: json['issue_count'] as int? ?? 0,
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      orgObjective: json['org_objective'],
      orgHow: json['org_how'],
      orgMeasure: json['org_measure'],
      userOutcome: json['user_outcome'],
      userHow: json['user_how'],
      userMeasure: json['user_measure'],
      modelProperty: json['model_property'],
      modelHow: json['model_how'],
      modelMeasure: json['model_measure'],
      deployment: json['deployment'],
    );
  }

  String get keyInitials => key.substring(0, key.length >= 2 ? 2 : key.length);

  Project copyWith({
    int? id,
    String? name,
    String? key,
    String? type,
    String? description,
    String? status,
    String? owner,
    DateTime? startDate,
    DateTime? endDate,
    int? openIssues,
    int? totalIssues,
    String? orgObjective,
    String? orgHow,
    String? orgMeasure,
    List<Map<String, String>>? leadingIndicators,
    String? userOutcome,
    String? userHow,
    String? userMeasure,
    String? modelProperty,
    String? modelHow,
    String? modelMeasure,
    String? deployment,
    String? maintenance,
    String? operations,
    List<String>? supervisors,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      key: key ?? this.key,
      type: type ?? this.type,
      description: description ?? this.description,
      status: status ?? this.status,
      owner: owner ?? this.owner,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      openIssues: openIssues ?? this.openIssues,
      totalIssues: totalIssues ?? this.totalIssues,
      orgObjective: orgObjective ?? this.orgObjective,
      orgHow: orgHow ?? this.orgHow,
      orgMeasure: orgMeasure ?? this.orgMeasure,
      leadingIndicators: leadingIndicators ?? this.leadingIndicators,
      userOutcome: userOutcome ?? this.userOutcome,
      userHow: userHow ?? this.userHow,
      userMeasure: userMeasure ?? this.userMeasure,
      modelProperty: modelProperty ?? this.modelProperty,
      modelHow: modelHow ?? this.modelHow,
      modelMeasure: modelMeasure ?? this.modelMeasure,
      deployment: deployment ?? this.deployment,
      maintenance: maintenance ?? this.maintenance,
      operations: operations ?? this.operations,
      supervisors: supervisors ?? this.supervisors,
    );
  }
}
