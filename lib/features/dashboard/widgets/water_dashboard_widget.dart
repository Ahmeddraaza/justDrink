import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class WaterDashboardWidget extends StatefulWidget {
  final int currentIntakeMl;
  final int dailyGoalMl;
  final VoidCallback onAddWater;

  const WaterDashboardWidget({
    super.key,
    required this.currentIntakeMl,
    required this.dailyGoalMl,
    required this.onAddWater,
  });

  @override
  State<WaterDashboardWidget> createState() => _WaterDashboardWidgetState();
}

class _WaterDashboardWidgetState extends State<WaterDashboardWidget> {
  late Stream<String> _timeStream;

  @override
  void initState() {
    super.initState();
    _timeStream = Stream.periodic(const Duration(minutes: 1), (_) => _formatTime())
        .map((time) => time);
  }

  String _formatTime() {
    return DateFormat('hh:mm a').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final double fillPercentage = (widget.currentIntakeMl / widget.dailyGoalMl).clamp(0.0, 1.0);
    final int glasses = (widget.currentIntakeMl / 250).floor(); // Assuming 250ml per glass

    return Container(
      width: double.infinity,
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Waves
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutCubic,
              height: 100 + (120 * fillPercentage),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/widget_water_waves.png',
                      fit: BoxFit.cover,
                      color: const Color(0xFF5DCCFC).withOpacity(0.6),
                    ),
                  ),
                  Positioned.fill(
                    top: 20,
                    child: Container(
                      color: const Color(0xFF5DCCFC).withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Water Drops Assets
          Positioned(
            top: 20,
            right: 30,
            child: Image.asset(
              'assets/images/widget_water_drops.png',
              width: 100,
              fit: BoxFit.contain,
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time
                StreamBuilder<String>(
                  stream: _timeStream,
                  initialData: _formatTime(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? '',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Color(0xFF1A1C1E),
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                // Stats
                Text(
                  '${widget.currentIntakeMl}ml water ($glasses Glass)',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF8E9199),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Add Button
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: widget.onAddWater,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1A1C1E),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Tap to Add Water',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
