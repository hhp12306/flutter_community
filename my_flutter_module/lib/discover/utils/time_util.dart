import 'package:intl/intl.dart';

/// 时间工具类
/// 用于格式化显示时间，满足业务需求
class TimeUtil {
  /// 格式化时间显示
  /// 规则：
  /// a. 一分钟内显示"刚刚"；
  /// b. 一小时内的显示XX分钟前；
  /// c. 一天内的显示XX小时前；
  /// d. 超过24小时的直接显示为月-日 时:分，如04-09 14:39
  /// e. 超过一年显示年-月-日 时:分，如2020-04-09 14:39
  static String formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    // 一分钟内
    if (difference.inMinutes < 1) {
      return '刚刚';
    }

    // 一小时内
    if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    }

    // 一天内
    if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    }

    // 超过24小时，判断是否超过一年
    final sameYear = now.year == time.year;
    if (sameYear) {
      // 同一年的显示：月-日 时:分，如04-09 14:39
      return DateFormat('MM-dd HH:mm').format(time);
    } else {
      // 不同年的显示：年-月-日 时:分，如2020-04-09 14:39
      return DateFormat('yyyy-MM-dd HH:mm').format(time);
    }
  }

  /// 格式化时间戳（毫秒）
  static String formatTimestamp(int timestamp) {
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return formatTime(time);
  }

  /// 格式化时间戳（秒）
  static String formatTimestampSeconds(int timestamp) {
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return formatTime(time);
  }

  /// 格式化日期时间（自定义格式）
  /// format: 格式字符串，如 'yyyy/MM/dd HH:mm'
  static String formatDateTime(DateTime time, {String format = 'yyyy-MM-dd HH:mm'}) {
    return DateFormat(format).format(time);
  }
}

