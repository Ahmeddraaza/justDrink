import 'package:timezone/timezone.dart' as tz;

class NotificationScheduler {
  /// Generates [count] evenly-spaced TZDateTime instances
  /// strictly within the [wakeTime]–[sleepTime] window.
  static List<tz.TZDateTime> generate({
    required String wakeTime,   // 'HH:mm'
    required String sleepTime,  // 'HH:mm'
    required int count,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    final wakeParts  = wakeTime.split(':').map(int.parse).toList();
    final sleepParts = sleepTime.split(':').map(int.parse).toList();

    final wakeMinutes  = wakeParts[0] * 60 + wakeParts[1];
    final sleepMinutes = sleepParts[0] * 60 + sleepParts[1];
    
    // Handle sleep time after midnight
    int endMinutes = sleepMinutes;
    if (endMinutes <= wakeMinutes) {
      endMinutes += 24 * 60;
    }
    
    final awakeMinutes = endMinutes - wakeMinutes;

    // interval between each reminder (not before first, not after last)
    final intervalMinutes = awakeMinutes ~/ (count + 1);

    return List.generate(count, (i) {
      final minutesFromMidnight = wakeMinutes + (intervalMinutes * (i + 1));
      final hour   = (minutesFromMidnight ~/ 60) % 24;
      final minute = minutesFromMidnight % 60;

      var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute,
      );
      // If already passed today, schedule for tomorrow
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    });
  }
}
