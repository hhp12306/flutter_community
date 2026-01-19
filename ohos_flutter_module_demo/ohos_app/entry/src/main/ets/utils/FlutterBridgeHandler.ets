import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { DataPreferencesUtil, UserInfo } from './DataPreferencesUtil';
import { promptAction } from '@kit.ArkUI';

/**
 * 系统信息接口
 */
interface SystemInfo {
  platform: string;
  version: string;
  model: string;
}

/**
 * WebView路由参数接口
 */
interface WebViewRouteParams extends Record<string, Object> {
  url: string;
  title: string;
}

/**
 * Flutter Bridge处理器
 * 处理Flutter通过MethodChannel调用的原生方法
 */
export class FlutterBridgeHandler {
  private context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  /**
   * 处理MethodCall
   */
  async handleMethodCall(method: string, args: Record<string, Object>): Promise<Object | null> {
    console.info(`Flutter调用原生方法: ${method}, 参数:`, JSON.stringify(args));

    switch (method) {
      case 'checkLoginStatus':
        return await this.checkLoginStatus();

      case 'navigateToLogin':
        return await this.navigateToLogin();

      case 'getUserInfo': {
        const userInfo = await this.getUserInfo();
        return userInfo as Object | null;
      }

      case 'logout':
        await this.logout();
        return null;

      case 'navigateToNativePage':
        return await this.navigateToNativePage(args['pageName'] as string, args['params'] as Record<string, Object>);

      case 'openNativeWebView':
        return await this.openNativeWebView(args['url'] as string, args['title'] as string);

      case 'getSharedData': {
        const data = await this.getSharedData(args['key'] as string);
        return data as Object | null;
      }

      case 'setSharedData':
        await this.setSharedData(args['key'] as string, args['value']);
        return true;

      case 'showToast':
        this.showToast(args['message'] as string, args['duration'] as string || 'short');
        return null;

      case 'showLoading':
        this.showLoading(args['message'] as string);
        return null;

      case 'hideLoading':
        this.hideLoading();
        return null;

      case 'getSystemInfo':
        return this.getSystemInfo();

      case 'requestPermission':
        return await this.requestPermission(args['permission'] as string);

      default:
        throw new Error(`Method ${method} not implemented`);
    }
  }

  /**
   * 检查登录状态
   */
  private async checkLoginStatus(): Promise<boolean> {
    return await DataPreferencesUtil.checkLoginStatus(this.context);
  }

  /**
   * 跳转登录页
   */
  private async navigateToLogin(): Promise<boolean> {
    return new Promise((resolve) => {
      try {
        // 注意：由于鸿蒙路由的限制，不能直接传递函数作为参数
        // 使用空对象作为参数，登录结果通过DataPreferencesUtil保存
        const routeParams: Record<string, Object> = {};
        router.pushUrl({
          url: 'pages/LoginPage',
          params: routeParams
        }).then(() => {
          // 注意：由于鸿蒙路由的限制，这里使用全局回调
          // 实际实现中，可以通过EventChannel或其他方式传递结果
          // 这里简化处理，使用延迟检查登录状态
          setTimeout(async () => {
            const isLoggedIn = await DataPreferencesUtil.checkLoginStatus(this.context);
            resolve(isLoggedIn);
          }, 100);
        }).catch((error: Error) => {
          console.error('跳转登录页失败:', error);
          resolve(false);
        });
      } catch (error) {
        console.error('跳转登录页异常:', error);
        resolve(false);
      }
    });
  }

  /**
   * 获取用户信息
   */
  private async getUserInfo(): Promise<UserInfo | null> {
    return await DataPreferencesUtil.getUserInfo(this.context);
  }

  /**
   * 登出
   */
  private async logout(): Promise<void> {
    await DataPreferencesUtil.clearUserInfo(this.context);
  }

  /**
   * 跳转原生页面
   */
  private async navigateToNativePage(pageName: string, params?: Record<string, Object>): Promise<boolean> {
    try {
      // 根据pageName跳转到不同的页面
      let targetUrl = '';
      switch (pageName) {
        case 'profile':
          targetUrl = 'pages/ProfilePage';
          break;
        case 'message':
          targetUrl = 'pages/MessagePage';
          break;
        default:
          console.warn(`未知的页面名称: ${pageName}`);
          return false;
      }

      const routeParams: Record<string, Object> = params || {};
      await router.pushUrl({
        url: targetUrl,
        params: routeParams as Record<string, Object>
      });
      return true;
    } catch (error) {
      console.error('跳转原生页面失败:', error);
      return false;
    }
  }

  /**
   * 打开原生WebView
   */
  private async openNativeWebView(url: string, title?: string): Promise<boolean> {
    try {
      const routeParams: WebViewRouteParams = {
        url: url,
        title: title || '详情'
      };
      await router.pushUrl({
        url: 'pages/WebViewPage',
        params: routeParams
      });
      return true;
    } catch (error) {
      console.error('打开WebView失败:', error);
      return false;
    }
  }

  /**
   * 获取共享数据
   */
  private async getSharedData(key: string): Promise<Object | null> {
    return await DataPreferencesUtil.getSharedData(this.context, key);
  }

  /**
   * 设置共享数据
   */
  private async setSharedData(key: string, value: Object): Promise<void> {
    await DataPreferencesUtil.setSharedData(this.context, key, value);
  }

  /**
   * 显示Toast
   */
  private showToast(message: string, duration: string): void {
    promptAction.showToast({
      message: message,
      duration: duration === 'long' ? 3500 : 2000,
      bottom: 100
    });
  }

  /**
   * 显示Loading
   */
  private showLoading(message?: string): void {
    // TODO: 实现Loading显示
    // 可以使用自定义Dialog或系统API
    console.info('显示Loading:', message);
  }

  /**
   * 隐藏Loading
   */
  private hideLoading(): void {
    // TODO: 实现Loading隐藏
    console.info('隐藏Loading');
  }

  /**
   * 获取系统信息
   */
  private getSystemInfo(): SystemInfo {
    const systemInfo: SystemInfo = {
      platform: 'HarmonyOS',
      version: 'HarmonyOS Next',
      model: 'HarmonyOS Device',
    };
    return systemInfo;
  }

  /**
   * 请求权限
   */
  private async requestPermission(permission: string): Promise<boolean> {
    // TODO: 实现权限请求逻辑
    // 使用 @ohos.abilityAccessCtrl 等API
    console.info('请求权限:', permission);
    return false;
  }
}
