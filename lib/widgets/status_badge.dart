import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isSmall;

  const StatusBadge({super.key, required this.status, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.statusBg[status] ?? AppColors.statusBg['todo']!;
    final txtColor = AppColors.statusText[status] ?? AppColors.statusText['todo']!;
    final label = AppColors.statusLabel[status] ?? status;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 10,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: txtColor,
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final String priority;
  final bool showIcon;
  final bool isSmall;

  const PriorityBadge({super.key, required this.priority, this.showIcon = true, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.priorityBg[priority] ?? AppColors.priorityBg['medium']!;
    final txtColor = AppColors.priorityText[priority] ?? AppColors.priorityText['medium']!;
    final icon = AppColors.priorityIcon[priority] ?? '🟡';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 10,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Text(icon, style: TextStyle(fontSize: isSmall ? 8 : 10)),
            const SizedBox(width: 4),
          ],
          Text(
            priority[0].toUpperCase() + priority.substring(1),
            style: TextStyle(
              color: txtColor,
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class RoleBadge extends StatelessWidget {
  final String role;
  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.roleBg[role] ?? AppColors.roleBg['member']!;
    final txtColor = AppColors.roleText[role] ?? AppColors.roleText['member']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role[0].toUpperCase() + role.substring(1),
        style: TextStyle(color: txtColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
