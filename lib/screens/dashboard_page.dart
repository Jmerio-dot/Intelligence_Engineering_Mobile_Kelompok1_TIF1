import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../services/project_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/stat_card.dart';
import '../widgets/section_header.dart';
import '../widgets/status_badge.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = ProjectService().getDashboard();
  }

  void _retry() {
    setState(() {
      _dashboardFuture = ProjectService().getDashboard();
    });
  }

  // ── Helper: compute status counts from myIssues ──
  Map<String, int> _computeStatusCounts(List<dynamic> issues) {
    final counts = {'todo': 0, 'in_progress': 0, 'in_review': 0, 'done': 0};
    for (final issue in issues) {
      final status = issue['status'] as String? ?? 'todo';
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  // ── Helper: compute priority counts from myIssues ──
  Map<String, int> _computePriorityCounts(List<dynamic> issues) {
    final counts = {'critical': 0, 'high': 0, 'medium': 0, 'low': 0};
    for (final issue in issues) {
      final priority = issue['priority'] as String? ?? 'medium';
      counts[priority] = (counts[priority] ?? 0) + 1;
    }
    return counts;
  }

  // ── Helper: time ago ──
  static String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('🏠 Dashboard'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.ocean),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: AppColors.cyan, size: 22),
            onPressed: () => _showUsersModal(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Error: ${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text2)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final totalProjects = data['totalProjects'] ?? 0;
          final assignedToMe = data['assignedToMe'] ?? 0;
          final inProgress = data['inProgress'] ?? 0;
          final completedToday = data['completedToday'] ?? 0;
          final myIssues = List<Map<String, dynamic>>.from(data['myIssues'] ?? []);
          final recentProjects = List<Map<String, dynamic>>.from(data['recentProjects'] ?? []);
          final recentActivity = List<Map<String, dynamic>>.from(data['recentActivity'] ?? []);

          final statusCounts = _computeStatusCounts(myIssues);
          final priorityCounts = _computePriorityCounts(myIssues);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Stat Cards ──
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      StatCard(label: 'Total Proyek', value: '$totalProjects', subtitle: 'Proyek aktif'),
                      const SizedBox(width: 10),
                      StatCard(label: 'Ditugaskan', value: '$assignedToMe', subtitle: 'Issue terbuka'),
                      const SizedBox(width: 10),
                      StatCard(label: 'In Progress', value: '$inProgress', subtitle: 'Sedang dikerjakan'),
                      const SizedBox(width: 10),
                      StatCard(label: 'Selesai', value: '$completedToday', subtitle: 'Selesai hari ini'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Charts ──
                Column(
                  children: [
                    SizedBox(width: double.infinity, child: _chartCard('📊 Status Issue (Keseluruhan)', _buildPieChartWithLegend(context, statusCounts))),
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, child: _chartCard('🎯 Distribusi Prioritas Issue', _buildBarChart(context, priorityCounts))),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Recent Projects ──
                SectionHeader(
                  title: 'Proyek Terbaru',
                  actionText: 'Lihat semua →',
                  onAction: () {},
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.3,
                  ),
                  itemCount: recentProjects.length > 4 ? 4 : recentProjects.length,
                  itemBuilder: (context, i) {
                    final p = recentProjects[i];
                    final projectId = p['id'];
                    final name = p['name'] ?? '';
                    final key = p['key'] ?? '';
                    final type = p['type'] ?? '';
                    final openIssues = p['open_issues'] ?? 0;
                    final keyInitials = key.isNotEmpty ? key.substring(0, key.length > 2 ? 2 : key.length).toUpperCase() : '??';
                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/board', arguments: {'projectId': projectId}),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: const [BoxShadow(color: Color(0x0A0064B4), blurRadius: 8)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(gradient: AppColors.gradient, borderRadius: BorderRadius.circular(8)),
                                  alignment: Alignment.center,
                                  child: Text(keyInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ocean), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text('$key · $type', style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                            const SizedBox(height: 2),
                            Text('$openIssues open issues', style: const TextStyle(fontSize: 11, color: AppColors.text2)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // ── My Open Issues ──
                const SectionHeader(title: 'Issue Saya yang Terbuka'),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: myIssues.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: Text('Tidak ada issue terbuka 🎉', style: TextStyle(color: AppColors.muted))),
                        )
                      : Column(
                          children: myIssues.map((issue) {
                            final issueId = issue['id'];
                            final issueKey = issue['issue_key'] ?? '';
                            final title = issue['title'] ?? '';
                            final priority = issue['priority'] ?? 'medium';
                            final status = issue['status'] ?? 'todo';
                            return InkWell(
                              onTap: () => Navigator.pushNamed(context, '/issue', arguments: {'issueId': issueId}),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 0.5))),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(issueKey, style: const TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.4,
                                          child: Text(title, style: const TextStyle(fontSize: 13, color: AppColors.text), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    PriorityBadge(priority: priority, isSmall: true),
                                    const SizedBox(width: 6),
                                    StatusBadge(status: status, isSmall: true),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 20),

                // ── Recent Activity ──
                const SectionHeader(title: 'Aktivitas Terkini'),
                ...recentActivity.take(5).map((a) {
                  final userName = a['user_name'] ?? a['userName'] ?? 'User';
                  final detail = a['detail'] ?? a['description'] ?? '';
                  final timestamp = a['created_at'] ?? a['timestamp'] ?? '';
                  final avatar = a['user_avatar'] ?? a['userEmoji'] ?? '👤';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Text(avatar, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ocean)),
                              Text(detail, style: const TextStyle(fontSize: 12, color: AppColors.text2)),
                            ],
                          ),
                        ),
                        Text(_timeAgo(timestamp), style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chartCard(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x0A0064B4), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ocean)),
          const SizedBox(height: 12),
          SizedBox(height: 140, child: chart),
        ],
      ),
    );
  }

  Widget _buildPieChartWithLegend(BuildContext context, Map<String, int> counts) {
    final total = counts.values.fold(0, (a, b) => a + b);
    if (total == 0) return const Center(child: Text('No data'));
    
    void showData(String label, int count) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label: $count issues'), duration: const Duration(seconds: 1), backgroundColor: AppColors.ocean));
    }

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: PieChart(PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 28,
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) return;
                final index = pieTouchResponse.touchedSection!.touchedSectionIndex;
                final keys = ['To Do', 'In Progress', 'In Review', 'Done'];
                final keyStr = ['todo', 'in_progress', 'in_review', 'done'];
                if (index >= 0 && index < 4) {
                  showData(keys[index], counts[keyStr[index]]!);
                }
              },
            ),
            sections: [
              PieChartSectionData(value: counts['todo']!.toDouble(), color: AppColors.chartTodo, radius: 24, title: '', showTitle: false),
              PieChartSectionData(value: counts['in_progress']!.toDouble(), color: AppColors.chartInProgress, radius: 24, title: '', showTitle: false),
              PieChartSectionData(value: counts['in_review']!.toDouble(), color: AppColors.chartInReview, radius: 24, title: '', showTitle: false),
              PieChartSectionData(value: counts['done']!.toDouble(), color: AppColors.chartDone, radius: 24, title: '', showTitle: false),
            ],
          )),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _legendItem('To Do', AppColors.chartTodo, () => showData('To Do', counts['todo']!)),
            const SizedBox(height: 4),
            _legendItem('In Progress', AppColors.chartInProgress, () => showData('In Progress', counts['in_progress']!)),
            const SizedBox(height: 4),
            _legendItem('In Review', AppColors.chartInReview, () => showData('In Review', counts['in_review']!)),
            const SizedBox(height: 4),
            _legendItem('Done', AppColors.chartDone, () => showData('Done', counts['done']!)),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.rectangle)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.text2)),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, Map<String, int> counts) {
    final maxVal = counts.values.fold(0, (a, b) => a > b ? a : b);
    return BarChart(BarChartData(
      maxY: (maxVal + 2).toDouble(),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => AppColors.ocean,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final labels = ['Critical', 'High', 'Medium', 'Low'];
            return BarTooltipItem(
              '${labels[group.x.toInt()]}\n${rod.toY.toInt()} issues',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
          const labels = ['C', 'H', 'M', 'L'];
          return Text(labels[v.toInt()], style: const TextStyle(fontSize: 10, color: AppColors.muted));
        })),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: [
        _bar(0, counts['critical']!.toDouble(), AppColors.chartCritical),
        _bar(1, counts['high']!.toDouble(), AppColors.chartHigh),
        _bar(2, counts['medium']!.toDouble(), AppColors.chartMedium),
        _bar(3, counts['low']!.toDouble(), AppColors.chartLow),
      ],
    ));
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(toY: y, color: color, width: 18, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
    ]);
  }

  void _showUsersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (modalContext) => FutureBuilder<List<Map<String, dynamic>>>(
        future: ProjectService().getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.text2)),
                  ],
                ),
              ),
            );
          }
          final users = snapshot.data!;
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            builder: (_, scrollCtrl) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                  child: Row(
                    children: [
                      Text('👥 Manajemen Pengguna (${users.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ocean)),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(modalContext)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(12),
                    itemCount: users.length,
                    itemBuilder: (_, i) {
                      final u = users[i];
                      final name = u['name'] ?? '';
                      final email = u['email'] ?? '';
                      final role = u['role'] ?? 'member';
                      final initials = name.isNotEmpty
                          ? name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
                          : '??';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: const BoxDecoration(gradient: AppColors.gradient2, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ocean)),
                                  Text(email, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.roleBg[role],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(role, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.roleText[role])),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
