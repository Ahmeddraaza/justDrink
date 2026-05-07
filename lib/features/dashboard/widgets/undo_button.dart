import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class UndoButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool visible;

  const UndoButton({
    super.key,
    required this.onTap,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: visible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !visible,
        child: TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.undo, size: 20, color: AppColors.undo),
          label: Text(
            'Undo',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.undo),
          ),
        ),
      ),
    );
  }
}
