import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/project_service.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int? _expandedProject;
  String _search = '';
  List<Map<String, dynamic>> _projects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await ProjectService().getProjects();
      if (mounted) {
        setState(() {
          _projects = projects.where((p) => p['status'] != 'done').toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProjects = _projects
        .where((p) => (p['name'] as String).toLowerCase().contains(_search.toLowerCase()))
        .toList();

    final user = AuthService().currentUser;

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.sidebarGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Brand
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: const Text('⚡', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'IntRing PM',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ],
                ),
              ),
              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: '🔍 Cari...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      filled: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Menu Utama
              _sectionLabel('MENU UTAMA'),
              _navItem('🏠', 'Dashboard', () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              }, isActive: true),
              _navItem('📁', 'Semua Proyek', () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home', arguments: {'tab': 1});
              }),
              _navItem('📊', 'Laporan', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/report');
              }),
              const SizedBox(height: 8),
              // Proyek
              _sectionLabel('PROYEK SAYA'),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2))
                    : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: filteredProjects.length,
                  itemBuilder: (context, index) {
                    final project = filteredProjects[index];
                    final projectId = project['id'] as int;
                    final projectKey = project['key'] as String;
                    final projectName = project['name'] as String;
                    final isExpanded = _expandedProject == projectId;
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => setState(() {
                            _expandedProject = isExpanded ? null : projectId;
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    projectKey,
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFFCAF0F8)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    projectName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.72),
                                    ),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: isExpanded ? 0.25 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    '›',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded)
                          Container(
                            color: Colors.black.withValues(alpha: 0.12),
                            child: Column(
                              children: [
                                _subMenuItem('🗂️', 'Board', () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/board', arguments: {'projectId': projectId});
                                }),
                                _subMenuItem('📋', 'Backlog', () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/backlog', arguments: {'projectId': projectId});
                                }),
                                _subMenuItem('📄', 'Transcript', () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/transcript', arguments: {'projectId': projectId});
                                }),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(user?['avatar'] ?? '👨‍💻', style: const TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?['name'] ?? 'User',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Lihat Profil',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _navItem(String icon, String label, VoidCallback onTap, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withValues(alpha: 0.18) : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.72),
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _subMenuItem(String icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.65)),
            ),
          ],
        ),
      ),
    );
  }
}
