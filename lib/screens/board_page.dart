import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/project.dart';
import '../services/issue_service.dart';
import '../services/project_service.dart';
import '../services/api_service.dart';
import 'projects_page.dart';

class BoardPage extends StatefulWidget {
  final int projectId;
  const BoardPage({super.key, required this.projectId});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  int? _selectedSprint;
  int? _selectedAssignee;

  Map<String, dynamic>? _project;
  Map<String, dynamic>? _boardData;
  List<Map<String, dynamic>> _sprints = [];
  List<Map<String, dynamic>> _members = [];
  bool _loading = true;
  String? _error;

  static const _columns = [
    {'key': 'todo', 'label': 'To Do', 'color': Color(0xFF64748B)},
    {'key': 'in_progress', 'label': 'In Progress', 'color': Color(0xFF3B82F6)},
    {'key': 'in_review', 'label': 'In Review', 'color': Color(0xFFA78BFA)},
    {'key': 'done', 'label': 'Done', 'color': Color(0xFF22C55E)},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ProjectService().getProject(widget.projectId),
        IssueService().getBoard(widget.projectId, sprintId: _selectedSprint),
        ProjectService().getSprints(widget.projectId),
        ProjectService().getMembers(widget.projectId),
      ]);
      if (!mounted) return;
      setState(() {
        _project = results[0] as Map<String, dynamic>;
        _boardData = results[1] as Map<String, dynamic>;
        _sprints = List<Map<String, dynamic>>.from(results[2] as List);
        _members = List<Map<String, dynamic>>.from(results[3] as List);
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data: $e';
        _loading = false;
      });
    }
  }

  Future<void> _reloadBoard() async {
    try {
      final board = await IssueService().getBoard(widget.projectId, sprintId: _selectedSprint);
      if (!mounted) return;
      setState(() => _boardData = board);
    } catch (_) {}
  }

  List<Map<String, dynamic>> _getColumnIssues(String statusKey) {
    if (_boardData == null) return [];
    final list = _boardData![statusKey];
    if (list == null) return [];
    List<Map<String, dynamic>> issues = List<Map<String, dynamic>>.from(list);
    if (_selectedAssignee != null) {
      issues = issues.where((i) => i['assignee_id'] == _selectedAssignee).toList();
    }
    return issues;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.ocean), onPressed: () => Navigator.pop(context)),
          title: const Text('Board', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ocean)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.ocean), onPressed: () => Navigator.pop(context)),
          title: const Text('Board', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ocean)),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 14), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final project = _project!;
    final projectStatus = project['status'] ?? 'active';
    final projectName = project['name'] ?? 'Project';
    final isDone = projectStatus == 'done';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.ocean), onPressed: () => Navigator.pop(context)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Proyek / $projectName', style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w400)),
            const Text('Board', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ocean)),
          ],
        ),
        actions: [
          if (!isDone) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: OutlinedButton.icon(
                onPressed: () {
                  final p = Project(
                    id: project['id'],
                    name: project['name'] ?? '',
                    key: project['key'] ?? '',
                    type: project['type'] ?? 'scrum',
                    description: project['description'] ?? '',
                    status: project['status'] ?? 'active',
                    owner: project['owner_name'],
                    openIssues: project['open_issues'] ?? 0,
                    totalIssues: project['issue_count'] ?? 0,
                  );
                  showProjectWizard(context, initialProject: p, onSaved: () => _loadData());
                },
                icon: const Icon(Icons.edit, size: 14, color: AppColors.ocean),
                label: const Text('Edit Proyek', style: TextStyle(fontSize: 12, color: AppColors.ocean, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: _showCompleteProjectModal,
                icon: const Text('✅', style: TextStyle(fontSize: 12)),
                label: const Text('Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(horizontal: 12)),
              ),
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.cardBorder)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: _selectedSprint,
                        hint: const Text('All Sprints', style: TextStyle(fontSize: 12)),
                        isExpanded: true,
                        style: const TextStyle(fontSize: 12, color: AppColors.text),
                        items: [
                          const DropdownMenuItem<int?>(value: null, child: Text('All Issues')),
                          ..._sprints.map((s) => DropdownMenuItem(value: s['id'] as int, child: Text(s['name']?.toString() ?? 'Sprint', overflow: TextOverflow.ellipsis))),
                        ],
                        onChanged: (v) {
                          setState(() => _selectedSprint = v);
                          _reloadBoard();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.cardBorder)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: _selectedAssignee,
                        hint: const Text('All Members', style: TextStyle(fontSize: 12)),
                        isExpanded: true,
                        style: const TextStyle(fontSize: 12, color: AppColors.text),
                        items: [
                          const DropdownMenuItem<int?>(value: null, child: Text('Semua Anggota')),
                          ..._members.map((u) => DropdownMenuItem(value: u['id'] as int, child: Text(u['name']?.toString() ?? '', overflow: TextOverflow.ellipsis))),
                        ],
                        onChanged: (v) => setState(() => _selectedAssignee = v),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Board
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _columns.map((col) {
                  final colKey = col['key'] as String;
                  final colIssues = _getColumnIssues(colKey);
                  return Container(
                    width: 260,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: col['color'] as Color, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Text(col['label'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.text)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.bg2, borderRadius: BorderRadius.circular(10)),
                                child: Text('${colIssues.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text2)),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.cardBorder),
                        // Cards
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: DragTarget<Map<String, dynamic>>(
                            onWillAcceptWithDetails: (details) => !isDone && details.data['status'] != colKey,
                            onAcceptWithDetails: (details) {
                              if (isDone) return;
                              final issueId = details.data['id'] as int;
                              _updateIssueStatus(issueId, colKey);
                            },
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                constraints: const BoxConstraints(minHeight: 60),
                                child: colIssues.isEmpty
                                    ? Container(
                                        height: 60,
                                        alignment: Alignment.center,
                                        child: const Text('Drop here', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                                      )
                                    : Column(
                                        children: colIssues.map((issue) => isDone
                                          ? Padding(
                                              padding: const EdgeInsets.only(bottom: 8),
                                              child: _buildIssueCard(
                                                issue,
                                                onTap: () => Navigator.pushNamed(context, '/issue', arguments: {'issueId': issue['id']}),
                                              ),
                                            )
                                          : LongPressDraggable<Map<String, dynamic>>(
                                              data: issue,
                                              feedback: Material(
                                                color: Colors.transparent,
                                                child: SizedBox(
                                                  width: 240,
                                                  child: _buildIssueCard(issue),
                                                ),
                                              ),
                                              childWhenDragging: Opacity(
                                                opacity: 0.3,
                                                child: _buildIssueCard(issue),
                                              ),
                                              child: _buildIssueCard(
                                                issue,
                                                onTap: () => Navigator.pushNamed(context, '/issue', arguments: {'issueId': issue['id']}),
                                                onLongPress: () => _showStatusChange(issue),
                                              ),
                                            ),
                                        ).toList(),
                                      ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: !isDone ? FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/create-issue', arguments: {'projectId': widget.projectId});
          _reloadBoard();
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildIssueCard(Map<String, dynamic> issue, {VoidCallback? onTap, VoidCallback? onLongPress}) {
    final type = issue['type']?.toString() ?? 'task';
    final issueKey = issue['issue_key']?.toString() ?? '';
    final title = issue['title']?.toString() ?? '';
    final priority = issue['priority']?.toString() ?? 'medium';
    final storyPoints = issue['story_points'];
    final assigneeName = issue['assignee_name']?.toString();
    final labelsRaw = issue['labels'];
    List<String> labels = [];
    if (labelsRaw is String && labelsRaw.isNotEmpty) {
      labels = labelsRaw.split(',').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    } else if (labelsRaw is List) {
      labels = labelsRaw.map((l) => l.toString()).toList();
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder, width: 1.5),
          boxShadow: const [
            BoxShadow(color: Color(0x0A0064B4), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key line
            Row(
              children: [
                Text(
                  AppColors.typeIcon[type] ?? '✅',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                Text(
                  issueKey,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Title
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            // Labels
            if (labels.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4, runSpacing: 4,
                children: labels.map((l) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Text(l, style: const TextStyle(fontSize: 10, color: Color(0xFF0369A1))),
                )).toList(),
              ),
            ],
            const SizedBox(height: 8),
            // Footer
            Row(
              children: [
                Text(
                  AppColors.priorityIcon[priority] ?? '🟡',
                  style: const TextStyle(fontSize: 10),
                ),
                if (storyPoints != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${storyPoints}sp',
                      style: const TextStyle(fontSize: 10, color: AppColors.text2, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                const Spacer(),
                if (assigneeName != null)
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradient2,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      assigneeName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateIssueStatus(int issueId, String newStatus) async {
    try {
      await IssueService().updateStatus(issueId, newStatus);
      await _reloadBoard();
      if (!mounted) return;
      final label = _columns.firstWhere((c) => c['key'] == newStatus)['label'] as String;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Issue moved to $label'), backgroundColor: AppColors.success),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memindahkan issue: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showStatusChange(Map<String, dynamic> issue) {
    final issueTitle = issue['title']?.toString() ?? '';
    final issueId = issue['id'] as int;
    final currentStatus = issue['status']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Move "$issueTitle"', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ocean)),
            const SizedBox(height: 16),
            ..._columns.map((col) {
              final key = col['key'] as String;
              final isActive = currentStatus == key;
              return ListTile(
                leading: Container(width: 12, height: 12, decoration: BoxDecoration(color: col['color'] as Color, shape: BoxShape.circle)),
                title: Text(col['label'] as String, style: TextStyle(fontWeight: isActive ? FontWeight.w700 : FontWeight.w500)),
                trailing: isActive ? const Icon(Icons.check, color: AppColors.success) : null,
                onTap: () {
                  Navigator.pop(context);
                  _updateIssueStatus(issueId, key);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showCompleteProjectModal() {
    // Count pending issues from the board data
    int pendingIssuesCount = 0;
    if (_boardData != null) {
      for (final key in ['todo', 'in_progress', 'in_review']) {
        final list = _boardData![key];
        if (list is List) pendingIssuesCount += list.length;
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('Selesaikan Proyek', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ocean)),
            const SizedBox(height: 8),
            const Text('Pilih jenis penyelesaian proyek ini. Syaratnya, semua issue harus berstatus "Done".', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.text2)),
            const SizedBox(height: 16),
            if (pendingIssuesCount > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)),
                child: Text('Terdapat $pendingIssuesCount issue yang belum berstatus "Done". Silakan selesaikan semua issue terlebih dahulu.', style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              )
            else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _completeProject(ctx),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('Selesaikan Proyek', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: AppColors.muted)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeProject(BuildContext dialogContext) async {
    try {
      await ProjectService().completeProject(widget.projectId);
      if (!dialogContext.mounted) return;
      Navigator.pop(dialogContext);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proyek berhasil diselesaikan! 🎉'), backgroundColor: AppColors.success));
      Navigator.pushReplacementNamed(context, '/home');
    } on ApiException catch (e) {
      if (!dialogContext.mounted) return;
      Navigator.pop(dialogContext);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } catch (e) {
      if (!dialogContext.mounted) return;
      Navigator.pop(dialogContext);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyelesaikan proyek: $e'), backgroundColor: AppColors.error),
      );
    }
  }
}
