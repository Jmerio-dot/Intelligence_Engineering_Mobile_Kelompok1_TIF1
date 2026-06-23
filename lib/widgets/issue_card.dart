import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/issue.dart';

class IssueCard extends StatelessWidget {
  final Issue issue;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const IssueCard({super.key, required this.issue, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
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
                  AppColors.typeIcon[issue.type] ?? '✅',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                Text(
                  issue.key,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Title
            Text(
              issue.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            // Labels
            if (issue.labels.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4, runSpacing: 4,
                children: issue.labels.map((l) => Container(
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
                  AppColors.priorityIcon[issue.priority] ?? '🟡',
                  style: const TextStyle(fontSize: 10),
                ),
                if (issue.storyPoints != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${issue.storyPoints}sp',
                      style: const TextStyle(fontSize: 10, color: AppColors.text2, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                const Spacer(),
                if (issue.assigneeName != null)
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradient2,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      issue.assigneeName![0].toUpperCase(),
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
}
