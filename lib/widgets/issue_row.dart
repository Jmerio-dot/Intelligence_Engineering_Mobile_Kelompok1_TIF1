import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'status_badge.dart';

class IssueRow extends StatelessWidget {
  final Map<String, dynamic> issue;
  final VoidCallback? onTap;

  const IssueRow({super.key, required this.issue, this.onTap});

  @override
  Widget build(BuildContext context) {
    final priority = issue['priority'] as String? ?? 'medium';
    final type = issue['type'] as String? ?? 'task';
    final issueKey = issue['issue_key'] as String? ?? '';
    final title = issue['title'] as String? ?? '';
    final status = issue['status'] as String? ?? 'todo';
    final assigneeName = issue['assignee_name'] as String?;
    final storyPoints = issue['story_points'];

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 0.5)),
        ),
        child: Row(
          children: [
            // Priority dot
            Icon(
              Icons.circle,
              size: 8,
              color: AppColors.priorityColor[priority] ?? AppColors.muted,
            ),
            const SizedBox(width: 8),
            // Type icon
            Text(AppColors.typeIcon[type] ?? '✅', style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            // Issue key
            SizedBox(
              width: 55,
              child: Text(
                issueKey,
                style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600),
              ),
            ),
            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 13, color: AppColors.text),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Status badge
            StatusBadge(status: status, isSmall: true),
            const SizedBox(width: 8),
            // Assignee
            if (assigneeName != null && assigneeName.isNotEmpty)
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
            // Story points
            if (storyPoints != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${storyPoints}sp',
                  style: const TextStyle(fontSize: 9, color: AppColors.text2, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
