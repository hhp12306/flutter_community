/// 数量工具类
/// 用于格式化显示数量，满足业务需求
class CountUtil {
  /// 格式化数量显示
  /// 规则：
  /// a. 不足1万按实际数量显示
  /// b. 超过10000，前端以万为单位进行显示，如1万+、1.1万
  ///    只保留1位小数，不四舍五入（向下取整）
  static String formatCount(int count) {
    if (count < 10000) {
      return count.toString();
    }

    // 超过1万，转换为万单位
    final wanCount = count / 10000.0;
    
    // 只保留1位小数，不四舍五入（向下取整）
    final floorWanCount = (wanCount * 10).floor() / 10.0;
    
    // 如果是整数，显示整数；否则显示1位小数
    if (floorWanCount == floorWanCount.floorToDouble()) {
      return '${floorWanCount.toInt()}万+';
    } else {
      return '${floorWanCount.toStringAsFixed(1)}万+';
    }
  }

  /// 格式化点赞数、收藏数等
  static String formatLikeCount(int count) {
    return formatCount(count);
  }
}

