import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/project_service.dart';
import '../services/issue_service.dart';
import '../services/api_service.dart';
import '../widgets/issue_row.dart';

class BacklogPage extends StatefulWidget {
  final int projectId;
  const BacklogPage({super.key, required this.projectId});

  @override
  State<BacklogPage> createState() => _BacklogPageState();
}

class _BacklogPageState extends State<BacklogPage> {
  final Set<int> _expanded = {};
  
  Map<String, dynamic>? _project;
  List<Map<String, dynamic>> _sprints = [];
  List<Map<String, dynamic>> _backlogIssues = [];
  Map<int, List<Map<String, dynamic>>> _sprintIssues = {};
  
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await Future.wait([
        ProjectService().getProject(widget.projectId),
        ProjectService().getSprints(widget.projectId),
        IssueService().getIssues(widget.projectId),
      ]);
      
      if (!mounted) return;
      
      final proj = res[0] as Map<String, dynamic>;
      final sprts = List<Map<String, dynamic>>.from(res[1] as List);
      final allIssues = List<Map<String, dynamic>>.from(res[2] as List);
      
      final backlog = allIssues.where((i) => i['sprint_id'] == null).toList();
      final Map<int, List<Map<String, dynamic>>> spIssues = {};
      for (final s in sprts) {
        spIssues[s['id']] = allIssues.where((i) => i['sprint_id'] == s['id']).toList();
      }

      setState(() {
        _project = proj;
        _sprints = sprts;
        _backlogIssues = backlog;
        _sprintIssues = spIssues;
        if (_sprints.isNotEmpty) _expanded.add(_sprints.first['id']);
        _expanded.add(-1); // backlog section
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.ocean), onPressed: () => Navigator.pop(context)),
          title: const Text('Backlog', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ocean)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.ocean), onPressed: () => Navigator.pop(context)),
          title: const Text('Backlog', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ocean)),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 14)),
              const SizedBox(height: 16),
              ElevatedButton.icon(onPressed: _loadData, icon: const Icon(Icons.refresh), label: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.ocean), onPressed: () => Navigator.pop(context)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Proyek / ${_project?['name'] ?? ''}', style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w400)),
            const Text('Backlog', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ocean)),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _showCreateSprint(),
            icon: const Icon(Icons.add, size: 16, color: AppColors.cyan),
            label: const Text('Sprint', style: TextStyle(fontSize: 12, color: AppColors.cyan)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Sprint blocks
            ..._sprints.map((sprint) {
              final sprintId = sprint['id'] as int;
              final issues = _sprintIssues[sprintId] ?? [];
              final doneCount = issues.where((i) => i['status'] == 'done').length;
              final isExpanded = _expanded.contains(sprintId);
              return _sprintBlock(sprint, issues, doneCount, isExpanded);
            }),
            // Backlog block
            _backlogBlock(_backlogIssues),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-issue', arguments: {'projectId': widget.projectId}),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _sprintBlock(Map<String, dynamic> sprint, List<Map<String, dynamic>> issues, int doneCount, bool isExpanded) {
    final sprintId = sprint['id'] as int;
    final sprintStatus = sprint['status'] as String? ?? 'planning';
    
    DateTime? getDt(String? str) => str == null ? null : DateTime.tryParse(str);
    final startDate = getDt(sprint['start_date']);
    final endDate = getDt(sprint['end_date']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x0A0064B4), blurRadius: 8)],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => isExpanded ? _expanded.remove(sprintId) : _expanded.add(sprintId)),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.play_arrow, size: 18, color: AppColors.text2),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(sprint['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ocean)),
                      ),
                      _sprintBadge(sprintStatus),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SizedBox(width: 24),
                      if (startDate != null && endDate != null)
                        Text(
                          '${startDate.day}/${startDate.month} – ${endDate.day}/${endDate.month}',
                          style: const TextStyle(fontSize: 11, color: AppColors.muted),
                        ),
                      const Spacer(),
                      Text('$doneCount/${issues.length} done', style: const TextStyle(fontSize: 11, color: AppColors.text2, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 10),
                      if (sprintStatus == 'planning')
                        _actionChip('▶ Start', const Color(0xFFE0F2FE), AppColors.primaryBlue, () async {
                          try {
                            await ApiService().put('/api/sprints/$sprintId', body: {
                              'name': sprint['name'],
                              'goal': sprint['goal'],
                              'status': 'active',
                            });
                            _loadData();
                          } catch (_) {}
                        }),
                      if (sprintStatus == 'active')
                        _actionChip('✓ Complete', const Color(0xFFDCFCE7), const Color(0xFF15803D), () async {
                           try {
                            await ApiService().put('/api/sprints/$sprintId', body: {
                              'name': sprint['name'],
                              'goal': sprint['goal'],
                              'status': 'done',
                            });
                            _loadData();
                          } catch (_) {}
                        }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Body
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.cardBorder),
            if (issues.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('No issues in this sprint. Add some from the backlog.', style: TextStyle(fontSize: 13, color: AppColors.muted), textAlign: TextAlign.center),
              )
            else
              ...issues.map((issue) => IssueRow(
                issue: issue,
                onTap: () => Navigator.pushNamed(context, '/issue', arguments: {'issueId': issue['id']}),
              )),
          ],
        ],
      ),
    );
  }

  Widget _backlogBlock(List<Map<String, dynamic>> issues) {
    final isExpanded = _expanded.contains(-1);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => isExpanded ? _expanded.remove(-1) : _expanded.add(-1)),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.play_arrow, size: 18, color: AppColors.text2),
                  ),
                  const SizedBox(width: 6),
                  const Text('📋 Backlog', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ocean)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.bg2, borderRadius: BorderRadius.circular(10)),
                    child: Text('${issues.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text2)),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.cardBorder),
            if (issues.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('No items in backlog.', style: TextStyle(fontSize: 13, color: AppColors.muted)),
              )
            else
              ...issues.map((issue) => IssueRow(
                issue: issue,
                onTap: () => Navigator.pushNamed(context, '/issue', arguments: {'issueId': issue['id']}),
              )),
          ],
        ],
      ),
    );
  }

  Widget _sprintBadge(String status) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = const Color(0xFF475569);
    String label = 'Planning';
    if (status == 'active') { bg = const Color(0xFFEFF6FF); fg = const Color(0xFF2563EB); label = 'Active'; }
    if (status == 'done') { bg = const Color(0xFFF0FDF4); fg = const Color(0xFF16A34A); label = 'Done'; }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _actionChip(String label, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
      ),
    );
  }

  void _showCreateSprint() {
    final nameCtrl = TextEditingController();
    final goalCtrl = TextEditingController();
    DateTime? start;
    DateTime? end;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Buat Sprint Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ocean)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Sprint (contoh: Sprint 1)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: goalCtrl,
                  decoration: const InputDecoration(labelText: 'Tujuan Sprint', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(start == null ? 'Mulai' : '${start!.day}/${start!.month}/${start!.year}'),
                        onPressed: () async {
                          final d = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                          if (d != null) setModalState(() => start = d);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(end == null ? 'Selesai' : '${end!.day}/${end!.month}/${end!.year}'),
                        onPressed: () async {
                          final d = await showDatePicker(context: ctx, initialDate: DateTime.now().add(const Duration(days: 14)), firstDate: DateTime(2020), lastDate: DateTime(2030));
                          if (d != null) setModalState(() => end = d);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty) return;
                      Navigator.pop(ctx);
                      try {
                        await ApiService().post('/api/projects/${widget.projectId}/sprints', body: {
                          'name': nameCtrl.text.trim(),
                          'goal': goalCtrl.text.trim(),
                          'start_date': start?.toIso8601String(),
                          'end_date': end?.toIso8601String(),
                        });
                        _loadData();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                        }
                      }
                    },
                    child: const Text('Buat Sprint', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
