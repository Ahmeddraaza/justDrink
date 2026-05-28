import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ReminderTile extends StatelessWidget {
  final TimeOfDay time;
  final bool isActive;
  final Function(bool) onToggle;
  final VoidCallback onTap;
  final bool isLocked;

  const ReminderTile({
    super.key,
    required this.time,
    required this.isActive,
    required this.onToggle,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Colors.white;
    const textColor = AppColors.heading;
    final subTextColor = isLocked ? AppColors.primary : AppColors.body.withValues(alpha: 0.8);
    final iconColor = isLocked
        ? AppColors.primary
        : (isActive ? AppColors.primary : AppColors.body);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isLocked ? AppColors.primary.withValues(alpha: 0.3) : AppColors.card,
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
                    color: iconColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLocked ? Icons.lock_rounded : Icons.access_time_rounded,
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
                        isLocked
                            ? 'Locked (Premium Only)'
                            : (isActive ? 'Active' : 'Disabled'),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLocked)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  )
                else
                  Switch.adaptive(
                    value: isActive,
                    onChanged: onToggle,
                    activeTrackColor: AppColors.primary,
                    activeThumbColor: Colors.white,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
