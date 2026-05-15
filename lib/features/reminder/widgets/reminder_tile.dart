import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ReminderTile extends StatelessWidget {
  final TimeOfDay time;
  final bool isActive;
  final Function(bool) onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ReminderTile({
    super.key,
    required this.time,
    required this.isActive,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Colors.white;
    const textColor = AppColors.heading;
    final subTextColor = AppColors.body.withOpacity(0.8);
    final iconColor = isActive ? AppColors.primary : AppColors.body;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.card,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time.format(context),
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 22,
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isActive ? 'Active' : 'Disabled',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isActive,
                  onChanged: onToggle,
                  activeTrackColor: AppColors.heading,
                  activeColor: Colors.white,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.delete_sweep_outlined, 
                    color: AppColors.error.withOpacity(0.8), 
                    size: 24
                  ),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Delete Reminder',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
