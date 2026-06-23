import 'api_service.dart';

/// Service for project-related API calls.
class ProjectService {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  final _api = ApiService();

  /// GET /api/projects — all projects for current user.
  Future<List<Map<String, dynamic>>> getProjects() async {
    final data = await _api.get('/api/projects');
    return List<Map<String, dynamic>>.from(data);
  }

  /// GET /api/projects/:id — single project.
  Future<Map<String, dynamic>> getProject(int id) async {
    return Map<String, dynamic>.from(await _api.get('/api/projects/$id'));
  }

  /// POST /api/projects — create a new project.
  Future<Map<String, dynamic>> createProject({
    required String name,
    required String key,
    String? description,
    String? type,
  }) async {
    return Map<String, dynamic>.from(await _api.post('/api/projects', body: {
      'name': name,
      'key': key,
      'description': description ?? '',
      'type': type ?? 'scrum',
    }));
  }

  /// PUT /api/projects/:id — update project.
  Future<Map<String, dynamic>> updateProject(int id, {
    required String name,
    required String description,
    required String status,
  }) async {
    return Map<String, dynamic>.from(await _api.put('/api/projects/$id', body: {
      'name': name,
      'description': description,
      'status': status,
    }));
  }

  /// POST /api/projects/:id/complete — mark project as done.
  Future<void> completeProject(int id) async {
    await _api.post('/api/projects/$id/complete');
  }

  /// DELETE /api/projects/:id
  Future<void> deleteProject(int id) async {
    await _api.delete('/api/projects/$id');
  }

  /// GET /api/projects/:id/members
  Future<List<Map<String, dynamic>>> getMembers(int projectId) async {
    return List<Map<String, dynamic>>.from(await _api.get('/api/projects/$projectId/members'));
  }

  /// GET /api/projects/:id/sprints
  Future<List<Map<String, dynamic>>> getSprints(int projectId) async {
    return List<Map<String, dynamic>>.from(await _api.get('/api/projects/$projectId/sprints'));
  }

  /// GET /api/projects/:id/transcript
  Future<Map<String, dynamic>> getTranscript(int projectId) async {
    return Map<String, dynamic>.from(await _api.get('/api/projects/$projectId/transcript'));
  }

  /// GET /api/dashboard
  Future<Map<String, dynamic>> getDashboard() async {
    return Map<String, dynamic>.from(await _api.get('/api/dashboard'));
  }

  /// GET /api/users — all users
  Future<List<Map<String, dynamic>>> getUsers() async {
    return List<Map<String, dynamic>>.from(await _api.get('/api/users'));
  }
}
