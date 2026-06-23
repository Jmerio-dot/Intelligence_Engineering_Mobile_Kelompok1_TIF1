import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTapBoard;
  final VoidCallback? onTapBacklog;
  final VoidCallback? onTapTranscript;
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTapBoard,
    this.onTapBacklog,
    this.onTapTranscript,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x1A0064B4), blurRadius: 16, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    project.keyInitials,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.ocean),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${project.key} · ${project.type}',
                        style: const TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                _statusBadge(project.status),
              ],
            ),
          ),
          // Description
          if (project.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                project.description,
                style: const TextStyle(fontSize: 12, color: AppColors.text2, height: 1.4),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 8),
          // Stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FBFF),
              border: Border.symmetric(horizontal: BorderSide(color: AppColors.cardBorder, width: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 7, color: Color(0xFFCA8A04)),
                const SizedBox(width: 4),
                Text('${project.openIssues} open', style: const TextStyle(fontSize: 11, color: AppColors.text2)),
                const SizedBox(width: 16),
                const Icon(Icons.circle, size: 7, color: Color(0xFF16A34A)),
                const SizedBox(width: 4),
                Text('${project.totalIssues} total', style: const TextStyle(fontSize: 11, color: AppColors.text2)),
              ],
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _actionBtn('📋 Board', const Color(0xFFE0F2FE), AppColors.cyan, onTapBoard),
                const SizedBox(width: 6),
                _actionBtn('📁 Backlog', const Color(0xFFF1F5F9), AppColors.text2, onTapBacklog),
                const SizedBox(width: 6),
                _actionBtn('📄 Transcript', AppColors.teal, Colors.white, onTapTranscript, filled: true),
                const SizedBox(width: 6),
                if (onDelete != null)
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(7),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: const Text('🗑', style: TextStyle(fontSize: 12)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String text, Color bg, Color textColor, VoidCallback? onTap, {bool filled = false}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: filled ? null : bg,
            gradient: filled ? LinearGradient(colors: [bg, AppColors.tealLight]) : null,
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textColor),
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color textColor;
    String label;
    switch (status) {
      case 'active':
        bg = const Color(0xFFE0F2FE);
        textColor = const Color(0xFF0369A1);
        label = 'Active';
        break;
      case 'planning':
        bg = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        label = 'Planning';
        break;
      case 'completed':
        bg = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        label = 'Completed';
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
