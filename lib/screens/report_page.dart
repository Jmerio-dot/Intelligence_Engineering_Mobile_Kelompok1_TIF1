import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/project_service.dart';
import '../widgets/app_drawer.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _projects = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await ProjectService().getProjects();
      if (mounted) setState(() { _projects = projects; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeProjects = _projects.where((p) => p['status'] != 'done').toList();
    final doneProjects = _projects.where((p) => p['status'] == 'done').toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bg,
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.ocean),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Laporan Proyek', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ocean)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () { setState(() { _loading = true; _error = null; }); _loadProjects(); }, child: const Text('Coba Lagi')),
                ]))
              : RefreshIndicator(
                  onRefresh: _loadProjects,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Header Summary
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ringkasan Status Proyek', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
                              const SizedBox(height: 4),
                              const Text('Laporan semua proyek berdasarkan status penyelesaiannya.', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _summaryCard(activeProjects.length.toString(), 'Dalam Pengerjaan', const Color(0xFF0284C7)),
                              const SizedBox(width: 12),
                              _summaryCard(doneProjects.length.toString(), 'Selesai', const Color(0xFF10B981)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Active Projects Section
                      _sectionTitle('Dalam Pengerjaan', Icons.rocket_launch, const Color(0xFF0284C7)),
                      const SizedBox(height: 16),
                      if (activeProjects.isEmpty)
                        _emptyState('Tidak ada proyek yang sedang dikerjakan.', Icons.rocket_launch, const Color(0xFF0284C7))
                      else
                        ...activeProjects.map((p) => _projectCard(p, false)),
                        
                      const SizedBox(height: 32),

                      // Done Projects Section
                      _sectionTitle('Sudah Selesai', Icons.check_circle_outline, const Color(0xFF10B981)),
                      const SizedBox(height: 16),
                      if (doneProjects.isEmpty)
                        _emptyState('Belum ada proyek yang diselesaikan.', Icons.check_circle_outline, const Color(0xFF10B981))
                      else
                        ...doneProjects.map((p) => _projectCard(p, true)),
                    ],
                  ),
                ),
    );
  }

  Widget _summaryCard(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x0A0064B4), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.text2, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 2))),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ocean)),
        ],
      ),
    );
  }

  Widget _emptyState(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _projectCard(Map<String, dynamic> p, bool isDone) {
    final key = p['key'] as String;
    final keyInitial = key.substring(0, key.length >= 2 ? 2 : key.length);
    final avatarColors = isDone 
        ? const [Color(0xFF059669), Color(0xFF10B981)] 
        : const [Color(0xFF023E8A), Color(0xFF0096C7), Color(0xFF48CAE4)];
    
    final badgeBg = isDone ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE);
    final badgeColor = isDone ? const Color(0xFF166534) : const Color(0xFF0284C7);
    final badgeText = isDone ? 'Selesai' : 'Aktif';

    final openIssues = p['open_issues'] ?? 0;
    final totalIssues = p['issue_count'] ?? 0;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/board', arguments: {'projectId': p['id']}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 15, offset: Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: avatarColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: avatarColors.last.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        alignment: Alignment.center,
                        child: Text(keyInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ocean, height: 1.2)),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(key, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.text2, fontSize: 11)),
                                const Text(' • ', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                                Text(p['type'] ?? 'scrum', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(12)),
                        child: Text(badgeText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    p['description'] ?? '',
                    style: const TextStyle(fontSize: 12, color: AppColors.text2, height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(isDone ? Icons.check_circle : Icons.pending_actions, size: 16, color: isDone ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                      const SizedBox(width: 6),
                      Text('$openIssues issue tertunda', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                  Text('$totalIssues total', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
