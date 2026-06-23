import 'api_service.dart';

/// Service for issue-related API calls.
class IssueService {
  static final IssueService _instance = IssueService._internal();
  factory IssueService() => _instance;
  IssueService._internal();

  final _api = ApiService();

  /// GET /api/projects/:id/board — board data grouped by status.
  Future<Map<String, dynamic>> getBoard(int projectId, {int? sprintId}) async {
    String path = '/api/projects/$projectId/board';
    if (sprintId != null) path += '?sprint_id=$sprintId';
    return Map<String, dynamic>.from(await _api.get(path));
  }

  /// GET /api/projects/:id/issues — list issues with filters.
  Future<List<Map<String, dynamic>>> getIssues(int projectId, {
    int? sprint,
    String? status,
    int? assignee,
    String? type,
    bool? backlog,
  }) async {
    final params = <String>[];
    if (sprint != null) params.add('sprint=$sprint');
    if (status != null) params.add('status=$status');
    if (assignee != null) params.add('assignee=$assignee');
    if (type != null) params.add('type=$type');
    if (backlog == true) params.add('backlog=true');
    String path = '/api/projects/$projectId/issues';
    if (params.isNotEmpty) path += '?${params.join('&')}';
    return List<Map<String, dynamic>>.from(await _api.get(path));
  }

  /// POST /api/projects/:id/issues — create issue.
  Future<Map<String, dynamic>> createIssue(int projectId, {
    required String title,
    String? description,
    String? type,
    String? status,
    String? priority,
    int? assigneeId,
    int? sprintId,
    String? labels,
    int? storyPoints,
    String? dueDate,
    Map<String, dynamic>? meaningfulObjectives,
    Map<String, dynamic>? intelligenceExperience,
    Map<String, dynamic>? intelligenceImplementation,
  }) async {
    return Map<String, dynamic>.from(await _api.post('/api/projects/$projectId/issues', body: {
      'title': title,
      'description': description ?? '',
      'type': type ?? 'task',
      'status': status ?? 'todo',
      'priority': priority ?? 'medium',
      'assignee_id': assigneeId,
      'sprint_id': sprintId,
      'labels': labels ?? '',
      'story_points': storyPoints,
      'due_date': dueDate,
      'meaningful_objectives': meaningfulObjectives ?? {},
      'intelligence_experience': intelligenceExperience ?? {},
      'intelligence_implementation': intelligenceImplementation ?? {},
    }));
  }

  /// GET /api/issues/:id — single issue.
  Future<Map<String, dynamic>> getIssue(int id) async {
    return Map<String, dynamic>.from(await _api.get('/api/issues/$id'));
  }

  /// PUT /api/issues/:id — full update.
  Future<Map<String, dynamic>> updateIssue(int id, Map<String, dynamic> body) async {
    return Map<String, dynamic>.from(await _api.put('/api/issues/$id', body: body));
  }

  /// PATCH /api/issues/:id/status — status-only update.
  Future<void> updateStatus(int id, String status) async {
    await _api.patch('/api/issues/$id/status', body: {'status': status});
  }

  /// DELETE /api/issues/:id
  Future<void> deleteIssue(int id) async {
    await _api.delete('/api/issues/$id');
  }

  /// GET /api/issues/:id/comments
  Future<List<Map<String, dynamic>>> getComments(int issueId) async {
    return List<Map<String, dynamic>>.from(await _api.get('/api/issues/$issueId/comments'));
  }

  /// POST /api/issues/:id/comments
  Future<Map<String, dynamic>> addComment(int issueId, String content) async {
    return Map<String, dynamic>.from(await _api.post('/api/issues/$issueId/comments', body: {
      'content': content,
    }));
  }

  /// GET /api/issues/:id/attachments
  Future<List<Map<String, dynamic>>> getAttachments(int issueId) async {
    return List<Map<String, dynamic>>.from(await _api.get('/api/issues/$issueId/attachments'));
  }
}
