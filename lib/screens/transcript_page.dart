import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/mock_data.dart';

class TranscriptPage extends StatefulWidget {
  final int projectId;
  const TranscriptPage({super.key, required this.projectId});

  @override
  State<TranscriptPage> createState() => _TranscriptPageState();
}

class _TranscriptPageState extends State<TranscriptPage> {
  String _downloadOption = 'pdf';

  @override
  Widget build(BuildContext context) {
    final project = MockData.projects.firstWhere((p) => p.id == widget.projectId, orElse: () => MockData.projects.first);
    final issues = MockData.getIssuesForProject(widget.projectId);
    final doneCount = issues.where((i) => i.status == 'done').length;
    final openCount = issues.where((i) => i.status != 'done').length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.ocean), onPressed: () => Navigator.pop(context)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Proyek / ${project.name}', style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w400)),
            const Text('Transcript', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ocean)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Project Info Card ──
            _infoCard('🗂️ Info Proyek', [
              _infoRow('Nama', project.name),
              _infoRow('Key', project.key),
              _infoRow('Tipe', project.type),
              _infoRow('Status', project.status),
              _infoRow('Owner', project.owner ?? '-'),
              if (project.startDate != null)
                _infoRow('Mulai', '${project.startDate!.day}/${project.startDate!.month}/${project.startDate!.year}'),
              if (project.endDate != null)
                _infoRow('Selesai', '${project.endDate!.day}/${project.endDate!.month}/${project.endDate!.year}'),
            ]),
            const SizedBox(height: 12),

            // ── Summary Card ──
            _infoCard('📊 Ringkasan', [
              Wrap(
                spacing: 8, runSpacing: 8,
                children: [
                  _statChip('${issues.length} Issues', const Color(0xFFE0F2FE), const Color(0xFF0369A1)),
                  _statChip('$doneCount Done', const Color(0xFFDCFCE7), const Color(0xFF15803D)),
                  _statChip('$openCount Open', const Color(0xFFFEF3C7), const Color(0xFFB45309)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Issue by Type:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text2)),
              const SizedBox(height: 6),
              ...['task', 'story', 'bug', 'epic'].map((t) {
                final count = issues.where((i) => i.type == t).length;
                if (count == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    Text('${AppColors.typeIcon[t]} ', style: const TextStyle(fontSize: 14)),
                    Text('$t: ', style: const TextStyle(fontSize: 13, color: AppColors.text2)),
                    Text('$count', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ocean)),
                  ]),
                );
              }),
            ]),
            const SizedBox(height: 12),

            // ── Document Preview ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFFF0F7FF), Color(0xFFE8F4FF)]),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const Row(
                      children: [
                        Text('📄', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Text('Preview Transcript', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ocean)),
                      ],
                    ),
                  ),
                  // A4 Paper simulation
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(2, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Center(
                          child: Text('TRANSKRIP PROJECT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFE0E0E0), letterSpacing: 1)),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text('Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: const TextStyle(fontSize: 10, color: Color(0xFF9BADC0))),
                        ),
                        const Divider(color: Color(0xFF4A5A6A), thickness: 2, height: 20),

                        // Planning section
                        if (project.deployment != null || project.maintenance != null) ...[
                          const Text('PLANNING', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFB0C4DE))),
                          const Divider(color: Color(0xFF4A5A6A), height: 12),
                          if (project.deployment != null)
                            _docRow('Deployment:', project.deployment!),
                          if (project.maintenance != null)
                            _docRow('Maintenance:', project.maintenance!),
                          if (project.operations != null)
                            _docRow('Operations:', project.operations!),
                          const SizedBox(height: 12),
                        ],

                        // Objectives
                        if (project.orgObjective != null) ...[
                          const Text('OBJECTIVES', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFB0C4DE))),
                          const Divider(color: Color(0xFF4A5A6A), height: 12),
                          _docRow('Objective:', project.orgObjective!),
                          if (project.orgHow != null) _docRow('How:', project.orgHow!),
                          if (project.orgMeasure != null) _docRow('Measure:', project.orgMeasure!),
                          const SizedBox(height: 12),
                        ],

                        // Issues
                        const Text('ISSUES', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFB0C4DE))),
                        const Divider(color: Color(0xFF4A5A6A), height: 12),
                        ...issues.take(5).map((issue) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF333333)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${issue.key} — ${issue.title}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE0E0E0))),
                              const SizedBox(height: 2),
                              Text('Status: ${AppColors.statusLabel[issue.status]} | Priority: ${issue.priority}',
                                style: const TextStyle(fontSize: 10, color: Color(0xFF9BADC0))),
                              if (issue.description.isNotEmpty)
                                Text(issue.description, style: const TextStyle(fontSize: 10, color: Color(0xFFD4D4D4), height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        )),
                        if (issues.length > 5)
                          Text('... and ${issues.length - 5} more issues', style: const TextStyle(fontSize: 10, color: Color(0xFF666666), fontStyle: FontStyle.italic)),

                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text('IntRing PM © 2026', style: const TextStyle(fontSize: 8, color: Color(0xFF444444), fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Download Card ──
            _infoCard('⬇️ Download', [
              _radioOption('pdf', '📄 Dokumen (.pdf)'),
              const SizedBox(height: 8),
              _radioOption('zip', '📦 Transkrip + File Upload (.zip)'),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.teal, AppColors.tealLight]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Download ${_downloadOption.toUpperCase()} dimulai...'), backgroundColor: AppColors.success),
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text('⬇️ Download Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x0A0064B4), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF0F7FF), Color(0xFFE8F4FF)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ocean)),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text))),
        ],
      ),
    );
  }

  Widget _statChip(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
    );
  }

  Widget _docRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9BADC0), fontStyle: FontStyle.italic))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 10, color: Color(0xFFE0E0E0), height: 1.4))),
        ],
      ),
    );
  }

  Widget _radioOption(String value, String label) {
    return GestureDetector(
      onTap: () => setState(() => _downloadOption = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _downloadOption == value ? const Color(0xFFE0F2FE) : const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _downloadOption == value ? AppColors.cyan : AppColors.cardBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              _downloadOption == value ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20, color: _downloadOption == value ? AppColors.cyan : AppColors.muted,
            ),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _downloadOption == value ? AppColors.ocean : AppColors.text2)),
          ],
        ),
      ),
    );
  }
}
