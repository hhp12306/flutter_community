import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

/**
 * 用户信息接口
 */
export interface UserInfo {
  userId: string;
  userName: string;
  avatar: string;
}

/**
 * 数据存储工具类
 * 用于存储用户信息、登录状态等数据
 */
export class DataPreferencesUtil {
  private static readonly PREF_NAME_USER = 'user_prefs';
  private static readonly PREF_NAME_SHARED = 'shared_data';

  /**
   * 获取用户偏好设置实例
   */
  private static async getUserPreferences(context: common.UIAbilityContext): Promise<preferences.Preferences> {
    return await preferences.getPreferences(context, DataPreferencesUtil.PREF_NAME_USER);
  }

  /**
   * 获取共享数据偏好设置实例
   */
  private static async getSharedPreferences(context: common.UIAbilityContext): Promise<preferences.Preferences> {
    return await preferences.getPreferences(context, DataPreferencesUtil.PREF_NAME_SHARED);
  }

  /**
   * 检查登录状态
   */
  static async checkLoginStatus(context: common.UIAbilityContext): Promise<boolean> {
    try {
      const prefs = await DataPreferencesUtil.getUserPreferences(context);
      const value = await prefs.get('is_logged_in', false);
      return value as boolean;
    } catch (error) {
      console.error('检查登录状态失败:', error);
      return false;
    }
  }

  /**
   * 设置登录状态
   */
  static async setLoginStatus(context: common.UIAbilityContext, isLoggedIn: boolean): Promise<void> {
    try {
      const prefs = await DataPreferencesUtil.getUserPreferences(context);
      await prefs.put('is_logged_in', isLoggedIn);
      await prefs.flush();
    } catch (error) {
      console.error('设置登录状态失败:', error);
    }
  }

  /**
   * 获取用户信息
   */
  static async getUserInfo(context: common.UIAbilityContext): Promise<UserInfo | null> {
    try {
      const prefs = await DataPreferencesUtil.getUserPreferences(context);
      const isLoggedInValue = await prefs.get('is_logged_in', false);
      const isLoggedIn = isLoggedInValue as boolean;
      
      if (!isLoggedIn) {
        return null;
      }

      const userIdValue = await prefs.get('user_id', '');
      const userNameValue = await prefs.get('user_name', '');
      const avatarValue = await prefs.get('avatar', '');
      
      const userInfo: UserInfo = {
        userId: userIdValue as string,
        userName: userNameValue as string,
        avatar: avatarValue as string,
      };
      return userInfo;
    } catch (error) {
      console.error('获取用户信息失败:', error);
      return null;
    }
  }

  /**
   * 保存用户信息
   */
  static async saveUserInfo(context: common.UIAbilityContext, userInfo: UserInfo): Promise<void> {
    try {
      const prefs = await DataPreferencesUtil.getUserPreferences(context);
      await prefs.put('user_id', userInfo.userId || '');
      await prefs.put('user_name', userInfo.userName || '');
      await prefs.put('avatar', userInfo.avatar || '');
      await prefs.put('is_logged_in', true);
      await prefs.flush();
    } catch (error) {
      console.error('保存用户信息失败:', error);
    }
  }

  /**
   * 清除用户信息（登出）
   */
  static async clearUserInfo(context: common.UIAbilityContext): Promise<void> {
    try {
      const prefs = await DataPreferencesUtil.getUserPreferences(context);
      await prefs.delete('is_logged_in');
      await prefs.delete('user_id');
      await prefs.delete('user_name');
      await prefs.delete('avatar');
      await prefs.flush();
    } catch (error) {
      console.error('清除用户信息失败:', error);
    }
  }

  /**
   * 获取共享数据
   */
  static async getSharedData(context: common.UIAbilityContext, key: string): Promise<Object | null> {
    try {
      const prefs = await DataPreferencesUtil.getSharedPreferences(context);
      const value = await prefs.get(key, null);
      return value as Object | null;
    } catch (error) {
      console.error('获取共享数据失败:', error);
      return null;
    }
  }

  /**
   * 设置共享数据
   */
  static async setSharedData(context: common.UIAbilityContext, key: string, value: Object): Promise<void> {
    try {
      const prefs = await DataPreferencesUtil.getSharedPreferences(context);
      await prefs.put(key, value);
      await prefs.flush();
    } catch (error) {
      console.error('设置共享数据失败:', error);
    }
  }
}
