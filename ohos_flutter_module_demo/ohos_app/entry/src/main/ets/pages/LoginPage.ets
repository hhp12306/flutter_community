import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { DataPreferencesUtil, UserInfo } from '../utils/DataPreferencesUtil';

/**
 * 登录结果路由参数接口
 */
interface LoginResultParams extends Record<string, Object> {
  loginResult: boolean;
  userName: string;
}

/**
 * 登录页面
 * 用于演示Flutter调用原生登录页面的功能
 */
@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  build() {
    Column() {
      // 标题
      Text('登录')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 100, bottom: 60 })

      // 用户名输入框
      TextInput({ placeholder: '请输入用户名' })
        .width('80%')
        .height(50)
        .margin({ bottom: 20 })
        .onChange((value: string) => {
          this.username = value;
        })

      // 密码输入框
      TextInput({ placeholder: '请输入密码' })
        .type(InputType.Password)
        .width('80%')
        .height(50)
        .margin({ bottom: 40 })
        .onChange((value: string) => {
          this.password = value;
        })

      // 登录按钮
      Button('登录')
        .width('80%')
        .height(50)
        .enabled(!this.isLoading && this.username.length > 0 && this.password.length > 0)
        .onClick(() => {
          this.handleLogin();
        })

      // 取消按钮
      Button('取消')
        .width('80%')
        .height(50)
        .type(ButtonType.Normal)
        .margin({ top: 20 })
        .enabled(!this.isLoading)
        .onClick(() => {
          this.handleCancel();
        })

      // 加载提示
      if (this.isLoading) {
        LoadingProgress()
          .width(50)
          .height(50)
          .margin({ top: 20 })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F5F5F5')
  }

  /**
   * 处理登录
   */
  async handleLogin(): Promise<void> {
    this.isLoading = true;

    // 模拟登录请求（实际应该调用真实的登录API）
    await new Promise<void>((resolve: () => void) => setTimeout(resolve, 1500));

    // 模拟登录成功
    if (this.username && this.password) {
      // 保存用户信息
      const userInfo: UserInfo = {
        userId: 'user_' + Date.now().toString(),
        userName: this.username,
        avatar: 'https://example.com/avatar.png',
      };
      await DataPreferencesUtil.saveUserInfo(this.context, userInfo);

      // 返回登录成功结果
      // 通过路由参数传递结果
      const routeParams: LoginResultParams = {
        loginResult: true,
        userName: this.username,
      };
      router.pushUrl({
        url: 'pages/Index',
        params: routeParams
      }).catch((error: Error) => {
        console.error('返回页面失败:', error);
        // 如果返回失败，直接关闭当前页面
        router.back();
      });
    } else {
      // 登录失败提示
      // TODO: 显示错误提示
      this.isLoading = false;
    }
  }

  /**
   * 处理取消
   */
  handleCancel(): void {
    // 返回登录失败结果
    const routeParams: LoginResultParams = {
      loginResult: false,
      userName: '',
    };
    router.pushUrl({
      url: 'pages/Index',
      params: routeParams
    }).catch((error: Error) => {
      console.error('返回页面失败:', error);
      router.back();
    });
  }
}
